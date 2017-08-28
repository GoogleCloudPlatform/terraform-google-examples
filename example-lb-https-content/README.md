# HTTPS Content-Based Load Balancer Example

**Figure 1.** *diagram of Google Cloud resources*

![architecture diagram](./diagram.png)

## Set up the environment

```
gcloud auth application-default login
export GOOGLE_PROJECT=$(gcloud config get-value project)
export TF_VAR_backend_bucket="${GOOGLE_PROJECT}-static-assets"
```

## Run Terraform

```
terraform init
terraform plan
terraform apply
```

## Generate SSL key and certificate:

```
openssl genrsa -out example.key 2048
openssl req -new -key example.key -out example.csr
openssl x509 -req -days 365 -in example.csr -signkey example.key -out example.crt
```

## Run Terraform

```
terraform get
terraform plan
terraform apply
```

Open URL of load balancer in browser:

```
EXTERNAL_IP=$(terraform output -module gce-lb-http | grep external_ip | cut -d = -f2 | xargs echo -n)
open https://${EXTERNAL_IP}/
```

You should see the GCP logo and instance details from the group closest to your geographical region.

```
open https://${EXTERNAL_IP}/group1/
```

You should see the GCP logo and instance details from the group in us-west1.

```
open https://${EXTERNAL_IP}/group2/
```

You should see the GCP logo and instance details from the group in us-central1.

```
open https://${EXTERNAL_IP}/group3/
```

You should see the GCP logo and instance details from the group in us-east1.

## Cleanup

Remove all resources created by terraform:

```
terraform destroy
```
