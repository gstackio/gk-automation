#!/usr/bin/env bash

set -eo pipefail -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

pipeline_name=$(bosh interpolate --path "/pipeline_name" "${SCRIPT_DIR}/config.yml")

fly --target="gk" \
    set-pipeline --pipeline="${pipeline_name}" \
    --config="${SCRIPT_DIR}/pipeline.yml" \
    --load-vars-from="${SCRIPT_DIR}/config.yml"
