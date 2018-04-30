#!/usr/bin/env bash

set -x 
set -e

URL="$(terraform output endpoint)"
status=0
count=0
while [[ $count -lt 120 && $status -ne 200 ]]; do
  echo "INFO: Waiting for load balancer..."
  status=$(curl -m 5 -s -f -k -o /dev/null -w "%{http_code}" "${URL}" || true)
  ((count=count+1))
  sleep 5
done
if [[ $count -lt 120 ]]; then
  echo "INFO: PASS"
else
  echo "ERROR: Failed"
fi