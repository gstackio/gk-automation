#!/usr/bin/env bash

set -ueo pipefail

find "repo" -mindepth 1 -maxdepth 1 -print0 \
    | xargs -0 -I{} cp -a {} "repo-branched"

branch_name=$(eval "echo ${BRANCH_NAME_TEMPLATE}")

pushd "repo-branched" > /dev/null
	current_branch=$(git branch --show-current)
    if [[ ${branch_name} != "${current_branch}" ]]; then
        git checkout -b "${branch_name}"
    fi
popd > /dev/null

echo "${branch_name}" > branch-info/branch-name
