# Vault on GCE Example

**Figure 1.** *diagram of Google Cloud resources*

![architecture diagram](./diagram.png)

## Set up the environment

```
gcloud auth application-default login
export GOOGLE_PROJECT=$(gcloud config get-value project)
```

Add the project ID and bucket name to the tfvars file:

```
cat - > terraform.tfvars <<EOF
project_id = "${GOOGLE_PROJECT}"
storage_bucket = "${GOOGLE_PROJECT}-vault""
EOF
```

## Deploy Vault

```
terraform init
terraform plan
terraform apply
```

## SSH Into Vault Instnace

List instances to find the Vault instance:

```
VAULT_INSTANCE=$(gcloud compute instances list --limit=1 --filter=name~vault- --uri)
```

```
gcloud compute ssh ${VAULT_INSTANCE}
```

## Initialize Vault

```
vault init
```
> Record the unseal keys and root token.

Unseal Vault

```
vault unseal
vault unseal
vault unseal
```

> Enter each unseal key per command.

Authenticate to Vault as root:

```
vault auth ROOT_TOKEN
```

## Configure GCP Auth Backend

Enable GCP auth backend:

```
vault auth-enable gcp
```

Configure GCP backend:

```
vault write auth/gcp/config credentials=@/etc/vault/gcp_credentials.json
```

## Create a Vault role and login with signed JWT

Create a Vault role named `dev-role`:

```
GOOGLE_PROJECT=$(gcloud config get-value project)
vault write auth/gcp/role/dev-role \
  type="iam" \
  project_id="${GOOGLE_PROJECT}" \
  policies="default" \
  service_accounts="vault-admin@${GOOGLE_PROJECT}.iam.gserviceaccount.com"
```

Get a signed JWT for the `dev-role`:

```
GOOGLE_PROJECT=$(gcloud config get-value project)
SERVICE_ACCOUNT=vault-admin@${GOOGLE_PROJECT}.iam.gserviceaccount.com
cat - > login_request.json <<EOF
{
  "aud": "vault/dev-role",
  "sub": "${SERVICE_ACCOUNT}",
  "exp": $((EXP=$(date +%s)+600))
}
EOF
```

```
JWT_TOKEN=$(gcloud beta iam service-accounts sign-jwt login_request.json signed_jwt.json --iam-account=${SERVICE_ACCOUNT} && cat signed_jwt.json)
```

Login to Vault with the signed JWT:

```
curl -s ${VAULT_ADDR}/v1/auth/gcp/login -d '{"role": "dev-role", "jwt": "'${JWT_TOKEN}'"}' | jq -r '.auth.client_token' > ~/.vault-token
```

Test access by writing and reading a value to the cubbyhole

```
vault write /cubbyhole/hello value=world
vault read /cubbyhole/hello
```

Expected output:

```
Key     Value
---     -----
value   world
```