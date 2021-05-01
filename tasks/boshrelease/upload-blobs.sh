#!/usr/bin/env bash

set -ueo pipefail

: ${S3_ACCESS_KEY_ID:?required}
: ${S3_SECRET_ACCESS_KEY:?required}

find "boshrelease-repo" -mindepth 1 -maxdepth 1 -print0 \
    | xargs -0 -I{} cp -a {} "boshrelease-repo-blobs-uploaded"

pushd "boshrelease-repo-blobs-uploaded" > /dev/null
    (
        set +x
        cat <<EOF > "config/private.yml"
---
blobstore:
  options:
    access_key_id: "${S3_ACCESS_KEY_ID}"
    secret_access_key: "${S3_SECRET_ACCESS_KEY}"
EOF
    )
    bosh upload-blobs
    rm "config/private.yml"
popd > /dev/null
