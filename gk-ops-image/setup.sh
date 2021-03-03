#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

pushd "${SCRIPT_DIR}" > /dev/null

team=$(    bosh interpolate --path "/team_name"     "config.yml")
pipeline=$(bosh interpolate --path "/pipeline_name" "config.yml")

credhub set -n "/concourse/${team}/git-commit-email"    -t value -v "$(bosh int secrets.yml     --path /git_user_email)"
credhub set -n "/concourse/${team}/git-commit-name"     -t value -v "$(bosh int config.yml      --path /git_user_name)"

credhub set -n "/concourse/${team}/github-access-token" -t value -v "$(bosh int secrets.yml --path /github_access_token)"
credhub set -n "/concourse/${team}/github-private-key"  -t value -v "$(bosh int secrets.yml --path /github_private_key)"

credhub set -n "/concourse/${team}/dockerhub-password"        -t value -v "$(bosh int secrets.yml --path /dockerhub_password)"
credhub set -n "/concourse/${team}/docker-registry-password"  -t value -v "$(bosh int secrets.yml --path /docker_registry_password)"

# To delete all:
#
#     credhub find | awk '/concourse/{print $3}' | xargs -n 1 credhub delete -n
# or
#     credhub find --path "/concourse/main" --output-json | jq -r ".credentials[].name" | xargs -n 1 credhub delete -n

popd > /dev/null
