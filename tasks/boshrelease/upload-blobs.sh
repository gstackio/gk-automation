#!/usr/bin/env bash

set -ueo pipefail

git clone "boshrelease-repo" "boshrelease-repo-blobs-uploaded"
cp -Rp "boshrelease-repo/blobs" "boshrelease-repo-blobs-uploaded"

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
