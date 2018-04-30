#!/usr/bin/env bash

fly -t tf set-pipeline -p tf-module-releases -c tests/pipelines/tf-module-releases.yaml -l tests/pipelines/values.yaml
fly -t tf set-pipeline -p tf-examples-regression -c tests/pipelines/tf-examples-regression.yaml -l tests/pipelines/values.yaml

fly -t tf expose-pipeline -p tf-module-releases
fly -t tf expose-pipeline -p tf-examples-regression
