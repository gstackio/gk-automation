#!/usr/bin/env bash

set -eo pipefail -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

team_name="$(   bosh interpolate --path "/team_name"     "${SCRIPT_DIR}/config.yml")"
pipeline_name=$(bosh interpolate --path "/pipeline_name" "${SCRIPT_DIR}/config.yml")

pushd "${SCRIPT_DIR}" > /dev/null
(
    set -x
    fly --target="${team_name}" \
        set-pipeline --pipeline="${pipeline_name}" \
        --config="pipeline.yml" \
        --load-vars-from="config.yml"
)
popd > /dev/null
