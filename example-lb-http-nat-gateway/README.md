# Global HTTP Example to GCE instances with NAT Gateway

**Figure 1.** *diagram of Google Cloud resources*

![architecture diagram](./diagram.png)

## Setup Environment

```
gcloud auth application-default login
export GOOGLE_PROJECT=$(gcloud config get-value project)
```

## Run Terraform

```
terraform init
terraform plan
terraform apply
```

Open URL of load balancer in browser:

```
EXTERNAL_IP=$(terraform output -module gce-lb-http | grep external_ip | cut -d = -f2 | xargs echo -n)
open http://${EXTERNAL_IP}
```

> Wait for all instance to become healthy per output of: `gcloud compute backend-services get-health group-http-lb-backend-0 --global`. This may take several minutes.

You should see the instance details from `group1`.

## Cleanup

Remove all resources created by terraform:

```
terraform destroy
```