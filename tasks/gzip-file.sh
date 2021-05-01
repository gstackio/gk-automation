#!/usr/bin/env bash

set -ueo pipefail

: ${ARTIFACT_FILE:?required}

cp -a artifact/* artifact-gzipped/

gzip --best "artifact-gzipped/${ARTIFACT_FILE}"
gzip --list "artifact-gzipped/${ARTIFACT_FILE}.gz"
