#!/bin/bash -ex

# Extract JSON args into shell variables
JQ=$(command -v jq || true)
[[ -z "${JQ}" ]] && echo "ERROR: Missing command: 'jq'" >&2 && exit 1

eval "$(${JQ} -r '@sh "REGION=\(.region)"')"

TMP_DIR=$(mktemp -d)
function cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

if [[ ! -z ${GOOGLE_CREDENTIALS+x} && ! -z ${GOOGLE_PROJECT+x} ]]; then
  export CLOUDSDK_CONFIG=${TMP_DIR}
  gcloud auth activate-service-account --key-file - <<<"${GOOGLE_CREDENTIALS}"
  gcloud config set project "${GOOGLE_PROJECT}"
fi

export CLOUDSDK_CONTAINER_USE_V1_API_CLIENT=false

DATA=$(gcloud beta container get-server-config --region ${REGION} --format=json)
LATEST_MASTER="$(${JQ} -r '.validMasterVersions[0]' <<<${DATA})"
LATEST_NODE="$(${JQ} -r '.validNodeVersions[0]' <<<${DATA})"

# Output results in JSON format.
jq -n --arg latest_master_version "${LATEST_MASTER}" --arg latest_node_version "${LATEST_NODE}" '{"latest_master_version":$latest_master_version, "latest_node_version":$latest_node_version}'