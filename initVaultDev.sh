#!/bin/bash
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=my-dev-root-vault-token
export VAULT_VERSION=1.0.1

curl -kO https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip

#nohup ./vault server -dev -dev-root-token-id ${VAULT_TOKEN}  > /dev/null 2>&1 &
./vault server -dev -dev-root-token-id ${VAULT_TOKEN}  > /dev/null &
# create KVs
./vault secrets enable -path=kv_v1/path/ kv > /dev/null 
#2>&1
./vault secrets enable -path=kv_v2/path/ kv > /dev/null 
./vault kv enable-versioning kv_v2/path/ > /dev/null

# create secrets
./vault kv put kv_v1/path/my-secret my-v1-secret=my-v1-secret-value > /dev/null
./vault kv put kv_v2/path/my-secret my-first-secret=my-first-secret-value my-second-secret=my-second-secret-value > /dev/null

# create policy
./vault policy write VaultDevAdmin ./VaultPolicy.hcl > /dev/null

# create approle
./vault auth enable approle > /dev/null
./vault write auth/approle/role/my-role policies=VaultDevAdmin secret_id_ttl=100m token_num_uses=100 token_ttl=100m token_max_ttl=300m secret_id_num_uses=40

unset VAULT_TOKEN
