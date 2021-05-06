#!/usr/bin/env bash

set -ueo pipefail

function main() {
    vars_files_args=()
    compute_var_vars_files_args

    inject_vars_in_configs
}

function inject_vars_in_configs() {
    local config_file_json  src  dst
    for config_file_json in $(jq --compact-output '.[]' <<< "${CONFIG_FILES}"); do
        src=$(jq --raw-output '.src' <<< "${config_file_json}")
        dst=$(jq --raw-output '.dst' <<< "${config_file_json}")

        mkdir -p "pre-filled-configs/$(dirname "${dst}")"
        echo "INFO: generating the '${dst}' file..."
        om interpolate --config "${src}" --skip-missing "${vars_files_args[@]}" \
            > "pre-filled-configs/${dst}"
    done
}

function compute_var_vars_files_args() {
    local vars_files  vars_file

    IFS=$'\n'
    # vars_files=(
    #     $(spruce json <<< "${VARS_FILES}" | jq --raw-output '.[]')
    # )
    vars_files=($(jq --raw-output '.[]' <<< "${VARS_FILES}"))

    for vars_file in "${vars_files[@]}"; do
        vars_files_args+=("--vars-file=${vars_file}")
    done
}

main "$@"