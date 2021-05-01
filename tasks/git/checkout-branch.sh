#!/usr/bin/env bash

set -ueo pipefail

: ${BASE_BRANCH:?required}
: ${BRANCH_NAME_TEMPLATE:?required}
: ${GITHUB_PRIVATE_KEY:?required}

artifact_version=$(< artifact-version/version)
echo "version: ${artifact_version}"

branch_name=$(eval "echo ${BRANCH_NAME_TEMPLATE}")

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

touch "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"
cat <<< "${GITHUB_PRIVATE_KEY}" > "${HOME}/.ssh/id_rsa"

find "repo" -mindepth 1 -maxdepth 1 -print0 \
    | xargs -0 -I{} cp -a {} "repo-branched"

pushd "repo-branched" > /dev/null
    ssh-keyscan -t "rsa" "bitbucket.org" "github.com" 2> /dev/null >> "${HOME}/.ssh/known_hosts"
    (
        set -x
        git fetch "origin"
    )

    if [[ -n $(git branch --remotes --list "origin/${branch_name}") ]]; then
        # If remote branch exists we check it out
        (
            set -x
            git checkout "${branch_name}"
        )
    else
        git checkout "${BASE_BRANCH}"
        if [[ ${branch_name} != "${BASE_BRANCH}" ]]; then
            (
                set -x
                git checkout -b "${branch_name}"
            )
        fi
    fi
popd > /dev/null

echo "${branch_name}" > branch-info/branch-name
echo "${BASE_BRANCH}" > branch-info/base-branch
