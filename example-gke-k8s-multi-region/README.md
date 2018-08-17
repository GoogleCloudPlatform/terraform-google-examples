# Kubernetes Engine Multi Cluster Load Balancing

This example shows how to do multi-region ingress using an L7 HTTP Load Balancer with regional clusters.

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

## Testing

Open the address of the load balancer in a browser once it is ready:

```
(until curl --connect-timeout 1 -sf -o /dev/null http://$(terraform output load-balancer-ip); do echo "Waiting for Load Balancer... "; sleep 5 ; done) && open http://$(terraform output load-balancer-ip)
```

## Cleanup

```
terraform destroy
```