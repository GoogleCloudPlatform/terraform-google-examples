# TCP Forwarding Rule Example

**Figure 1.** *diagram of Google Cloud resources*

![architecture diagram](./diagram.png)

## Set up the environment

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
EXTERNAL_IP=$(terraform output -module gce-lb-fr | grep external_ip | cut -d = -f2 | xargs echo -n)
open http://${EXTERNAL_IP}
```

You should see the instance details from `group1`

## Cleanup

Remove all resources created by terraform:

```
terraform destroy
```