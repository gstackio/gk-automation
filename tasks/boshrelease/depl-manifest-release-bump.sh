#!/usr/bin/env bash

set -ueo pipefail

boshrelease_version=$(< bosh-io-release/version)
url=$(                < bosh-io-release/url)
sha1=$(               < bosh-io-release/sha1)

echo "version: ${boshrelease_version}"
echo "url:     ${url}"
echo "sha1:    ${sha1}"

(
    set -x
    git clone "repo" "repo-bumped"
)

pushd "repo-bumped" > /dev/null

    releases_updated=$(spruce merge <<YAML
releases: $(spruce json "${MANIFEST_PATH}" \
    | jq --compact-output \
        --arg name "${RELEASE_NAME}" \
        --arg version "${boshrelease_version}" \
        --arg url "${url}" \
        --arg sha1 "${sha1}" \
        '.releases | map(
            if .name == $name
            then . + { "version": $version, "url": $url, "sha1": $sha1 }
            else .
            end)'
    )
YAML
)
    releases_line_number=$(awk '/^releases:/{ print NR; exit }' "${MANIFEST_PATH}")
    opsfile_head=$(head -n $((${releases_line_number} - 1)) "${MANIFEST_PATH}")
    cat > "${MANIFEST_PATH}" <<YAML
${opsfile_head}

${releases_updated}
YAML

popd > /dev/null

echo "Bump the '${RELEASE_NAME}' BOSH Release to version ${boshrelease_version}" > commit-info/commit-message

echo "${boshrelease_version}" > bump-info/artifact-version
