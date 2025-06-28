#!/bin/sh

SA_JWT=$(cat /var/run/secrets/vaultproject.io/token)
VAULT_CACERT="/vault/tls/tls.crt"
export VAULT_CACERT

LOGIN_RESPONSE=$(curl \
  --cacert "${VAULT_CACERT}" \
  -s \
  --request POST \
  --data "{\"role\": \"${SA_NAME}\", \"jwt\": \"${SA_JWT}\"}" \
  "${VAULT_ADDR}"/v1/auth/kubernetes/login)

VAULT_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r .auth.client_token)
export VAULT_TOKEN

vault operator raft snapshot save /share/vault-raft.snap

aws --endpoint-url https://s3.nas.shifman.dev s3 cp /share/vault-raft.snap s3://"${BUCKET}"/vault_raft_"$(date +'%Y%m%d_%H%M%S')".snap

echo "Done"
