#!/usr/bin/env bash

set -ueo pipefail

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

touch "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"
cat <<< "${GITHUB_PRIVATE_KEY}" > "${HOME}/.ssh/id_rsa"

grep -vE "^(UPDATED|UUID)=" "branch-info/keyval.properties" \
    | sed -r -e 's/"/\"/g; s/=(.*)$/="\1"/' \
    > keyval.inc.bash
source "keyval.inc.bash"

pushd "repo" > /dev/null
    git remote set-url "origin" "${GIT_URI}"
    ssh-keyscan -t "rsa" "github.com" 2> /dev/null >> "${HOME}/.ssh/known_hosts"
    (
        set -x
        git push --set-upstream "origin" "${branch_name}"
    )
popd > /dev/null
