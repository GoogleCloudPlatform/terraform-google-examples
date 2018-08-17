#!/usr/bin/env bash

fly -t tf set-pipeline -p tf-module-releases -c tests/pipelines/tf-module-releases.yaml -l tests/pipelines/values.yaml
fly -t tf set-pipeline -p tf-examples-gke-k8s-helm -c tests/pipelines/tf-examples-gke-k8s-helm.yaml -l tests/pipelines/values.yaml
fly -t tf set-pipeline -p tf-examples-gke-multi-region -c tests/pipelines/tf-examples-gke-multi-region.yaml -l tests/pipelines/values.yaml
fly -t tf set-pipeline -p tf-examples-gke-service-lb -c tests/pipelines/tf-examples-gke-service-lb.yaml -l tests/pipelines/values.yaml

fly -t tf expose-pipeline -p tf-module-releases
fly -t tf expose-pipeline -p tf-examples-gke-k8s-helm
fly -t tf expose-pipeline -p tf-examples-gke-multi-region
fly -t tf expose-pipeline -p tf-examples-gke-service-lb
