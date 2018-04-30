#!/usr/bin/env bash
set -e
PIPELINE="tf-examples-regression"
JOBS="run-example-gke-k8s-helm run-example-gke-k8s-service-lb run-example-gke-k8s-multi-region"
for j in $JOBS; do
  fly -t solutions trigger-job -j ${PIPELINE}/${j}
done
