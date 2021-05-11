#!/usr/bin/env bash

set -ueo pipefail

: ${PIVNET_PRODUCT_SLUG:?"required"}
: ${PIVNET_PRODUCT_VERSION:?"required"}
: ${PIVNET_PRODUCT_FILE_GLOB:?"required"}
: ${PIVNET_API_TOKEN:?"required"}
: ${OUTPUT_DIR:?"required"}

find "repo" -mindepth 1 -maxdepth 1 -print0 \
    | xargs -0 -I{} cp -a {} "repo-updated"

pushd "repo-updated" > /dev/null

    mkdir -p "${OUTPUT_DIR}"

    om config-template \
        --pivnet-product-slug="${PIVNET_PRODUCT_SLUG}" \
        --product-version="${PIVNET_PRODUCT_VERSION}" \
        --file-glob="${PIVNET_PRODUCT_FILE_GLOB}" \
        \
        --pivnet-api-token="${PIVNET_API_TOKEN}" \
        --exclude-version \
        --output-directory="${OUTPUT_DIR}"

popd > /dev/null
