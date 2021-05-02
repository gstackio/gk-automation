#!/usr/bin/env bash

set -ueo pipefail

: ${GH_OWNER:?required}
: ${GH_REPO:?required}
: ${ARTIFACT_FILE:?required}

tag=$(< github-release/tag)

url="https://github.com/${GH_OWNER}/${GH_REPO}/releases/download/${tag}/${ARTIFACT_FILE}"

blob_last_modified=$(
    curl --silent --fail --show-error --location --head --url "${url}" \
        | grep -i '^last-modified:' \
        | tail -n1 \
        | cut -d" " -f "2-" \
        | tr -d '\r'
)

date_utc=$(date -j -f "%a, %d %b %Y %T %Z" "${blob_last_modified}" "+%F %T")
echo "INFO: setting timestamps to '${date_utc}' on file '${ARTIFACT_FILE}'."

# time format for 'touch' command: [[CC]YY]MMDDhhmm[.SS]
last_modified_ts=$(
    date -j -f "%a, %d %b %Y %T %Z" "${blob_last_modified}" "+%Y%m%d%H%M.%S"
)

cp -a github-release/* github-release-timestamped/

touch -t "${last_modified_ts}" "github-release-timestamped/${ARTIFACT_FILE}"
