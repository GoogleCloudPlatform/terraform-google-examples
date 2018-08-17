#!/usr/bin/env bash

PROJECT=$(cat ~/.secrets.yaml | egrep '^project_id:' | cut -d' ' -f2)
BUCKET=$(cat ~/.secrets.yaml | egrep '^tf_backend_bucket:' | cut -d' ' -f2)
ACCESS_KEY=$(cat ~/.secrets.yaml | egrep '^s3_compatible_access_key:' | cut -d' ' -f2)
SECRET_KEY=$(cat ~/.secrets.yaml | egrep '^s3_compatible_secret_key:' | cut -d' ' -f2)
CMD="gsutil ls -p ${PROJECT} gs://${BUCKET}/*/*.tfstate"

function list-tf-states() {
  CMD=$1
  IFS=';' read -ra items <<< "$($CMD | sort | tr '\n' ';')"
  [[ ${#items[@]} -eq 0 ]] && echo "ERROR: No state files found." && return 1
  local count=1
  echo "Terraform state files:" >&2
  for i in ${items[@]}; do 
    echo "  $count) ${i//*${BUCKET}\/}" >&2
    ((count=count+1))
  done
  local sel=0
  while [[ $sel -lt 1 || $sel -ge $count ]]; do
    read -p "Select state file: " sel >&2
  done
  item=${items[(sel-1)]}
  echo $item
}

STATEFILE=$(list-tf-states "$CMD")
KEY="${STATEFILE//*${BUCKET}\/}"
PREFIX=$(dirname $KEY)
WORKSPACE=$(basename $KEY .tfstate)

cat > backend.tf <<EOF
terraform {
  backend "gcs" {
    bucket     = "${BUCKET}"
    prefix     = "${PREFIX}"
  }
}
EOF

echo "INFO: Generated backend.tf"

cat - << EOF 

Copy backend.tf to the example directory then run the following: 

  terraform init
  terraform workspace select ${WORKSPACE}
  terraform plan

EOF