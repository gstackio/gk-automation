#!/usr/bin/env bash

set -ueo pipefail

: ${ARTIFACT_FILE:?required}

cp -a artifact/* artifact-gzipped/

gzip -9 "artifact-gzipped/${ARTIFACT_FILE}"
