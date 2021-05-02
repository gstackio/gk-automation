#!/usr/bin/env bash

set -ueo pipefail

: ${ARTIFACT_FILE:?required}

release_url=$(< github-release/url)

artifact_url=$(
    sed -e 's|/tag/|/download/|' -e "s|$|/${ARTIFACT_FILE}|" <<< "${release_url}"
)

blob_last_modified=$(
    curl --silent --fail --show-error --location --head --url "${artifact_url}" \
        | grep -i '^last-modified:' \
        | tail -n1 \
        | cut -d" " -f "2-" \
        | tr -d '\r'
)

# date_utc=$(date -j -f "%a, %d %b %Y %T %Z" "${blob_last_modified}" "+%F %T") # Darwin
date_utc=$(date --date="${blob_last_modified}" "+%F %T") # Linux
echo "INFO: setting timestamps to '${date_utc}' on file '${ARTIFACT_FILE}'."

# time format for 'touch' command: [[CC]YY]MMDDhhmm[.SS]
last_modified_ts=$(
    # date -j -f "%a, %d %b %Y %T %Z" "${blob_last_modified}" "+%Y%m%d%H%M.%S" # Darwin
    date --date="${blob_last_modified}" "+%Y%m%d%H%M.%S" # Linux
)

cp -a github-release/* github-release-timestamped/

touch -t "${last_modified_ts}" "github-release-timestamped/${ARTIFACT_FILE}"
