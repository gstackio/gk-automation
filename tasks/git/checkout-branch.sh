#!/usr/bin/env bash

set -ueo pipefail

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
    base_branch=$(git rev-parse --abbrev-ref "HEAD") # or 'git branch --show-current' when git >= 2.22

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
    elif [[ ${branch_name} != "${base_branch}" ]]; then
        (
            set -x
            git checkout -b "${branch_name}"
        )
    fi
popd > /dev/null

echo "${branch_name}" > branch-info/branch-name
echo "${base_branch}" > branch-info/base-branch
