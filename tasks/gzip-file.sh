#!/usr/bin/env bash

set -ueo pipefail

cp -a artifact/* artifact-gzipped/

gzip -c9 "artifact-gzipped/${ARTIFACT_FILE}"
