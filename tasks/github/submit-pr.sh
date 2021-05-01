#!/usr/bin/env bash

set -ueo pipefail

: ${GH_ACCESS_TOKEN:?required}
: ${GH_OWNER:?required}
: ${GH_REPO:?required}

pr_title=$(   < pr-info/title)
pr_desc=$(    < pr-info/body)
branch_name=$(< pr-info/branch)
base_branch=$(< pr-info/base-branch)

pushd "repo" > /dev/null
    if [[ -z $(git diff --shortstat "${base_branch}") ]]; then
        echo "INFO: current branch '${branch_name}' has no changes" \
            "compared to base branch '${base_branch}'. Nothing more to do."
        exit 0
    fi
popd > /dev/null

# See also: https://developer.github.com/v3/pulls/#create-a-pull-request
pr_data=$(jq -n \
    --arg "title" "${pr_title}" \
    --arg "body"  "${pr_desc}" \
    --arg "base"  "${base_branch}" \
    --arg "head"  "${branch_name}" \
    '{
        "title": $title,
        "body":  $body,
        "base":  $base,
        "head":  $head,
        "maintainer_can_modify": true
    }')

echo "Creating pull request: POST /repos/${GH_OWNER}/${GH_REPO}/pulls"
# See also: https://developer.github.com/v3/
curl --silent --fail --show-error --location \
    --header "Accept: application/vnd.github.v3+json" \
    --header "Authorization: token ${GH_ACCESS_TOKEN}" \
    --request "POST" \
    --url "https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/pulls" \
    --data-raw "${pr_data}"
