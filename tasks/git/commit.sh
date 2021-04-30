#!/usr/bin/env bash

set -ueo pipefail

if [[ -n ${GIT_COMMIT_MESSAGE} ]]; then
    commit_message="${GIT_COMMIT_MESSAGE}"
elif [[ -f "commit-info/commit-message" ]]; then
    commit_message=$(< commit-info/commit-message)
else
    echo "ERROR: no 'commit-info/commit-message' file, and no 'GIT_COMMIT_MESSAGE' param. One must be specified. Aborting." >&2
    exit 2
fi

pushd "repo" > /dev/null
    git config "color.ui" "always"
    git status
    git diff | cat

    git config "user.name"  "${GIT_COMMIT_NAME}"
    git config "user.email" "${GIT_COMMIT_EMAIL}"

    if [[ -z "$(git status --porcelain)" ]]; then
        echo "INFO: nothing to commit. Skipping."
    else
        git add .
        git commit -m "${commit_message}"
    fi
popd > /dev/null

git clone "repo" "repo-committed"

pushd "repo-committed" > /dev/null
    git config "user.name"  "${GIT_COMMIT_NAME}"
    git config "user.email" "${GIT_COMMIT_EMAIL}"
popd > /dev/null
