#!/usr/bin/env bash

set -ueo pipefail

if [[ -n ${GIT_COMMIT_MESSAGE} ]]; then
    commit_message="${GIT_COMMIT_MESSAGE}"
elif [[ -f "commit-info/keyval.properties" ]]; then
    grep -vE "^(UPDATED|UUID)=" "commit-info/keyval.properties" \
        | sed -r -e 's/"/\"/g; s/=(.*)$/="\1"/' \
        > keyval.inc.bash
    source "keyval.inc.bash"
else
    echo "ERROR: no 'commit-info' resource, and no 'GIT_COMMIT_MESSAGE' param. One must be specified. Aborting." >&2
    exit 2
fi

git clone "repo" "repo-committed"

pushd "repo-committed" > /dev/null
    git config "color.ui" "always"
    git status
    git diff | cat

    git config "user.name" "${GIT_COMMIT_NAME}"
    git config "user.email" "${GIT_COMMIT_EMAIL}"

    if [[ -z "$(git status --porcelain)" ]]; then
        echo "INFO: nothing to commit. Skipping."
    else
        git add .
        git commit -m "${commit_message}"
    fi
popd > /dev/null
