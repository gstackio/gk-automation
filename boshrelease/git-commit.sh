#!/usr/bin/env bash

set -ueo pipefail

git clone "repo" "repo-committed"

pushd "repo-committed" > /dev/null
    git config --global "color.ui" "always"
    git status
    git diff | cat

    git config --global "user.name" "${GIT_COMMIT_NAME}"
    git config --global "user.email" "${GIT_COMMIT_EMAIL}"

    if [[ -z "$(git status --porcelain)" ]]; then
        echo "INFO: nothing to commit. Skipping."
    else
        git add .
        git commit -m "${GIT_COMMIT_MESSAGE}"
    fi
popd > /dev/null
