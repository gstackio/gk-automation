#!/usr/bin/env bash

set -ueo pipefail

find bosh-io-release -ls

echo version: $(< bosh-io-release/version)
echo url:     $(< bosh-io-release/url)
echo sha1:    $(< bosh-io-release/sha1)

latest_boshrelease_version=$(< bosh-io-release/version)
url=$(< bosh-io-release/url)
sha1=$(< bosh-io-release/sha1)

git clone "repo" "repo-bumped"

pushd "repo-bumped" > /dev/null
    git checkout "${BRANCH_NAME}"
    git pull

    releases_updated=$(spruce merge <<YAML
releases: $(spruce json "${MANIFEST_PATH}" \
    | jq --compact-output \
        --arg name "${RELEASE_NAME}" \
        --arg version "${latest_boshrelease_version}" \
        --arg url "${url}" \
        --arg sha1 "${sha1}" \
        '.releases | map(
            if .name == $name
            then . + {"version":$version,"url":$url,"sha1":$sha1}
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

    git config --global "color.ui" "always"
    git status
    git diff | cat

    git config --global "user.name" "((git_user_name))"
    git config --global "user.email" "((git_user_email))"

    git add .
    git commit -m "Bump the '${RELEASE_NAME}' BOSH Release to version ${latest_boshrelease_version}"
popd > /dev/null


# Write properties to the keyval output resource

mkdir -p "bump-info"
{
    echo "latest_boshrelease_version=${latest_boshrelease_version}"
    echo "branch_name=${BRANCH_NAME}"
} >> bump-info/keyval.properties
