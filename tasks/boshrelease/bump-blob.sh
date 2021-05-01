#!/usr/bin/env bash

set -ueo pipefail

: ${ARTIFACT_HUMAN_NAME:?required}
: ${ARTIFACT_FILE_TEMPLATE:?required}
: ${BLOB_PATH_AWK_PATTERN:?required}
: ${BLOB_PATH_TEMPLATE:?required}
: ${PACKAGE_NAME:?required}
: ${ARTIFACT_REF_VARS_PREFIX:?required}

artifact_version=$(< artifact-release/version)
echo "version: ${artifact_version}"

find "boshrelease-repo" -mindepth 1 -maxdepth 1 -print0 \
    | xargs -0 -I{} cp -a {} "boshrelease-repo-bumped"

pushd "boshrelease-repo-bumped" > /dev/null
    bosh blobs

    old_blob_sha256=$(
        bosh blobs --column "path" --column "digest" \
            | awk "/${BLOB_PATH_AWK_PATTERN}/"'{sub("^sha256:", "", $2); print $2}'
    )
    artifact_file=$(eval "echo ${ARTIFACT_FILE_TEMPLATE}")
    new_blob_sha256=$(
        shasum -a 256 "../artifact-release/${artifact_file}" \
            | awk '{print $1}'
    )
    if [[ ${new_blob_sha256} == ${old_blob_sha256} ]]; then
        echo "INFO: new blob has the same sha256 hash as the old one. Skipping blob update."
    else
        old_blob_path=$(
            bosh blobs --column "path" \
                | awk "/${BLOB_PATH_AWK_PATTERN}/"'{print $1}'
        )
        bosh remove-blob "${old_blob_path}"

        new_blob_path=$(eval "echo ${BLOB_PATH_TEMPLATE}")
        bosh add-blob "../artifact-release/${artifact_file}" "${new_blob_path}"

        bosh blobs
    fi

    packaging_file="packages/${PACKAGE_NAME}/packaging"
    echo "Updating '${packaging_file}' file."
    sed -i -re "/${ARTIFACT_REF_VARS_PREFIX}_VERSION=/s/=[0-9.]+\$/=${artifact_version}/" "${packaging_file}"
    grep -F -nC 2 "${ARTIFACT_REF_VARS_PREFIX}_VERSION=" "${packaging_file}"

    echo "Updating 'scripts/add-blobs.sh' utility."
    sed -i -re "/${ARTIFACT_REF_VARS_PREFIX}_VERSION=/s/=[0-9.]+\$/=${artifact_version}/" "scripts/add-blobs.sh"
    sed -i -re "/${ARTIFACT_REF_VARS_PREFIX}_SHA256=/s/=[0-9a-f]+\$/=${new_blob_sha256}/" "scripts/add-blobs.sh"
    grep -E -nC 2 "${ARTIFACT_REF_VARS_PREFIX}_(VERSION|SHA256)=" "scripts/add-blobs.sh"
popd > /dev/null

echo "Bump ${ARTIFACT_HUMAN_NAME} to version ${artifact_version}" > commit-info/commit-message

echo "${artifact_version}" > bump-info/artifact-version
