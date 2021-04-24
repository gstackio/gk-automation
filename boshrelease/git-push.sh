#!/usr/bin/env bash

set -ueo pipefail

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

touch "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"
cat <<< "${GITHUB_PRIVATE_KEY}" > "${HOME}/.ssh/id_rsa"

if [[ -n ${BRANCH_NAME} ]]; then
    branch_name="${BRANCH_NAME}"
elif [[ -f "branch-info/keyval.properties" ]]; then
    grep -vE "^(UPDATED|UUID)=" "branch-info/keyval.properties" \
        | sed -r -e 's/"/\"/g; s/=(.*)$/="\1"/' \
        > keyval.inc.bash
    source "keyval.inc.bash"
else
    echo "ERROR: no 'branch-info' resource, and no 'BRANCH_NAME' param. One must be specified. Aborting." >&2
    exit 2
fi

pushd "repo" > /dev/null
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
