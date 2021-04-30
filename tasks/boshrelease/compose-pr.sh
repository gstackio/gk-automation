#!/usr/bin/env bash

set -ueo pipefail

latest_version=$(< bump-info/artifact-version)
branch_name=$(   < bump-info/branch-name)

pr_title="Bump ${ARTIFACT_HUMAN_NAME} to version ${latest_version}"

pr_desc="Hi there!"
pr_desc+="\\n"
pr_desc+="\\nI noticed that the new ${ARTIFACT_HUMAN_NAME} v${latest_version} is out,"
pr_desc+=" so I suggest we update this BOSH Release with the latest artifact available."
pr_desc+="\\n"
pr_desc+="\\nHere in this PR, I've pulled that new artifact in."
pr_desc+=" I've already uploaded the blob to the release blobstore, and here is the result."
pr_desc+="\\n"
if [[ -n ${RELEASE_NOTES_URL_TMPL} ]]; then
    pr_desc+="\\nDon't hesitate to have a look at the release notes: "
    pr_desc+=$(eval "echo ${RELEASE_NOTES_URL_TMPL}")
    pr_desc+="\\nWhen it's okay to you, let's give it a shot, shall we?"
else
    pr_desc+="\\nLet's give it a shot, shall we?"
fi
pr_desc+="\\n"
pr_desc+="\\nBest"

echo "${pr_title}"    > pr-info/title
echo -e "${pr_desc}"  > pr-info/body
echo "${branch_name}" > pr-info/branch
