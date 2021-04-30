#!/usr/bin/env bash

set -ueo pipefail

cp -Rp artifact/* artifact-gzipped/

gzip -c9 "artifact-gzipped/${ARTIFACT_FILE}"
