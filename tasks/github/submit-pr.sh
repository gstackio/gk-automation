#!/usr/bin/env bash

set -ueo pipefail

pr_title=$(   < pr-info/title)
pr_desc=$(    < pr-info/body)
branch_name=$(< pr-info/branch)

# See also: https://developer.github.com/v3/pulls/#create-a-pull-request
pr_data=$(jq -n \
    --arg title "${pr_title}" \
    --arg body "${pr_desc}" \
    --arg head "${branch_name}" \
    '{
        "base": "master",
        "title": $title,
        "body": $body,
        "head": $head,
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
