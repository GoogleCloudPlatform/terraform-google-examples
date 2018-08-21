# Kubernetes Engine Example

Example showing how to integrate the Terraform kubernetes provider with a Google Kubernetes Engine cluster.

[![button](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/GoogleCloudPlatform/terraform-google-examples&working_dir=example-gke-k8s-service-lb&page=shell&tutorial=README.md)

<a href="https://concourse-tf.gcp.solutions/teams/main/pipelines/tf-examples-gke-service-lb" target="_blank">
<img src="https://concourse-tf.gcp.solutions/api/v1/teams/main/pipelines/tf-examples-gke-service-lb/badge" /></a>

## Change to the example directory

```
[[ `basename $PWD` != example-gke-k8s-service-lb ]] && cd example-gke-k8s-service-lb
```

## Install Terraform

1. Install Terraform if it is not already installed (visit [terraform.io](https://terraform.io) for other distributions):

```
../terraform-install.sh
```

## Set up the environment

1. Set the project, replace `YOUR_PROJECT` with your project ID:

```
PROJECT=YOUR_PROJECT
```

```
gcloud config set project ${PROJECT}
```

2. Configure the environment for Terraform:

```
[[ $CLOUD_SHELL ]] || gcloud auth application-default login
export GOOGLE_PROJECT=$(gcloud config get-value project)
```

## Run Terraform

```
terraform init
terraform apply
```

## Testing

1. Wait for the load balancer to be provisioned:

```
./test.sh
```

2. Verify response from load balancer:

```
curl http://$(terraform output load-balancer-ip)
```

## Connecting with kubectl

1. Get the cluster credentials and configure kubectl:

```
gcloud container clusters get-credentials $(terraform output cluster_name) --zone $(terraform output cluster_zone)
```

2. Verify kubectl connectivity:

```
kubectl get pods -n staging
```

## Cleanup

1. Delete resources created by terraform:

```
terraform destroy
```