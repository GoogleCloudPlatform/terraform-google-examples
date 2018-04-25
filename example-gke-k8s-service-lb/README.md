# Kubernetes Engine Example

## Set up the environment

```
gcloud auth application-default login
export GOOGLE_PROJECT=$(gcloud config get-value project)
```

## Create the `terraform.tfvars` file

```
cat > terraform.tfvars <<EOF
gke_username = "admin"
gke_password = "$(openssl rand -base64 16)"
EOF
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