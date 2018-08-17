# Kubernetes Engine Example

Example showing how to integrate the Terraform kubernetes provider with a Google Kubernetes Engine cluster.

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

## Testing

```
curl http://$(terraform output load-balancer-ip)
```

## Connecting with kubectl

```
gcloud container clusters get-credentials $(terraform output cluster_name) --zone $(terraform output cluster_zone)

kubectl get pods -n staging
```