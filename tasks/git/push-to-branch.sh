#!/usr/bin/env bash

set -ueo pipefail

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

touch "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"
cat <<< "${GITHUB_PRIVATE_KEY}" > "${HOME}/.ssh/id_rsa"

if [[ -n ${BRANCH_NAME} ]]; then
    branch_name="${BRANCH_NAME}"
elif [[ -f "branch-info/branch-name" ]]; then
    branch_name=$(< branch-info/branch-name)
else
    echo "ERROR: no 'branch-info/branch-name' file, and no 'BRANCH_NAME' param. One must be specified. Aborting." >&2
    exit 2
fi

if [[ -n ${BASE_BRANCH} ]]; then
    base_branch="${BASE_BRANCH}"
elif [[ -f "branch-info/base-branch" ]]; then
    base_branch=$(< branch-info/base-branch)
else
    echo "ERROR: no 'branch-info/base-branch' file, and no 'BASE_BRANCH' param. One must be specified. Aborting." >&2
    exit 2
fi

find "repo" -mindepth 1 -maxdepth 1 -print0 \
    | xargs -0 -I{} cp -a {} "repo-pushed"

pushd "repo-pushed" > /dev/null
    if [[ -z $(git diff --shortstat "${base_branch}") ]]; then
        echo "INFO: current branch '${branch_name}' has no changes" \
            "compared to base branch '${base_branch}'. Nothing more to do."
        exit 0
    fi
    if git remote | grep -q '^origin$'; then
        git remote remove "origin"
    fi
    git remote add "origin" "${GIT_URI}"
    ssh-keyscan -t "rsa" "bitbucket.org" "github.com" 2> /dev/null >> "${HOME}/.ssh/known_hosts"
    (
        set -x
        git fetch "origin"
    )
    if [[ -n $(git branch --remotes --list "origin/${branch_name}") ]]; then
        (
            set -x
            git pull --rebase "origin" "${branch_name}"
        )
    fi
    (
        set -x
        git push --set-upstream "origin" "${branch_name}"
    )
popd > /dev/null
