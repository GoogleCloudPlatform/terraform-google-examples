# Kubernetes Engine and Helm Example

[![button](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/GoogleCloudPlatform/terraform-google-examples&page=editor&tutorial=example-custom-machine-types/README.md)

<a href="https://concourse-tf.gcp.solutions/teams/main/pipelines/tf-examples-gke-k8s-helm" target="_blank">
<img src="https://concourse-tf.gcp.solutions/api/v1/teams/main/pipelines/tf-examples-gke-k8s-helm/badge" /></a>

## Install Terraform

Install Terraform if it is not already installed (visit [terraform.io](https://terraform.io) for other distributions):

```
./terraform-install.sh
```

## Set up the environment

```
gcloud auth application-default login
export GOOGLE_PROJECT=$(gcloud config get-value project)
```

## Enable service management API

This example creates a Cloud Endpoints service and requires that the Service Manangement API is enabled.

```
gcloud services enable servicemanagement.googleapis.com
```

## Install helm

```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

helm init --client-only
```

## Install the helm provider

```
wget https://github.com/mcuadros/terraform-provider-helm/releases/download/v0.5.1/terraform-provider-helm_v0.5.1_$(uname | tr '[:upper:]' '[:lower:]')_amd64.tar.gz
tar -xvf terraform-provider-helm*.tar.gz

mkdir -p ~/.terraform.d/plugins/
mv terraform-provider-helm*/terraform-provider-helm ~/.terraform.d/plugins/
```

## Create the `terraform.tfvars` file

```
cat > terraform.tfvars <<EOF
helm_version = "$(helm version -c --short | egrep -o 'v[0-9].[0-9].[0-9]')"
acme_email = "$(gcloud config get-value account)"
EOF
```

## Run Terraform

If you have run this example before within the last 30 days, undelete the Cloud Endpoints service named `drupal`:

```
gcloud endpoints services undelete drupal.endpoints.$(gcloud config get-value project).cloud.goog
```

```
terraform init
terraform plan
terraform apply
```

## Testing

After the Drupal pods start and are ready, open the interface by navigating to the URL:

```
echo https://$(terraform output endpoint)
```

Login with the credentials displayed in the following commands:

```
echo User: $(terraform output drupal_user)
echo Password: $(terraform output drupal_password)
```

## Connecting with kubectl and helm

```
gcloud container clusters get-credentials $(terraform output cluster_name) --zone $(terraform output cluster_zone)

kubectl get pods

helm list
```

## Cleanup

Delete the `nginx-ingress` helm release first so that the forwarding rule and firewall rule are cleaned up by the GCE controller:

```
terraform destroy -target helm_release.nginx-ingress && sleep 60 && \
terraform destroy
```