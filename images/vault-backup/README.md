# vault-backup

Since vault doesn't provide backups in the open source version

- Authenticates against vault with a k8s service account token and snapshots the raft file system
- Uploads backup to s3

This assumes the following is configured - for extra documentation / examples [see this](https://michaellin.me/backup-vault-with-raft-storage-on-kubernetes/)

- Vault kubernetes authentication backend is enabled
- SA created for the job to use
- The vault role has a audience claim and has to use a projected k8s serivce account token
- `/share` exists and is writable

## Environment Variables

| Variable              | Example                |
| --------------------- | ---------------------- |
| VAULT_ADDR            | https://vault:8200     |
| AWS_SECRET_ACCESS_KEY | xxx                    |
| AWS_ACCESS_KEY_ID     | yyy                    |
| AWS_DEFAULT_REGION    | us-east-1              |
| AWS_ENDPOINT          | https://s3.example.com |
| SA_NAME               | snapshot-agent         |
| BUCKET                | vault-backup           |

## Required Files

| File                 | Path                                   |
| -------------------- | -------------------------------------- |
| Vault CA certificate | /vault/tls/tls.crt                     |
| k8s CA token         | /var/run/secrets/vaultproject.io/token |

## Example Cron Job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: vault-snapshot
spec:
  schedule: "@every 12h"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          serviceAccountName: vault-snapshot-agent
          volumes:
            - name: vault-token
              # need to project this to set the audience claim
              projected:
                sources:
                  - serviceAccountToken:
                      path: token
                      expirationSeconds: 600
                      audience: vault
            - name: share
              emptyDir: {}
            - name: client-cert
              secret:
                secretName: vault-client-cert
          containers:
            - name: snapshot
              image: ghcr.io/aaronshifman/vault-backup:1.19.0
              env:
                - name: BUCKET
                  value: vault-backup
                - name: SA_NAME
                  value: snapshot-agent
                - name: AWS_ENDPOINT
                  value: https://s3.nas.shifman.dev
                - name: VAULT_ADDR
                  value: https://vault-active:8200
              volumeMounts:
                - name: vault-token
                  mountPath: /var/run/secrets/vaultproject.io/
                  readOnly: true
                - mountPath: /vault/tls
                  name: client-cert
                  readOnly: true
                - mountPath: /share
                  name: share
              envFrom:
                - secretRef:
                    name: backup-s3-secret
```

### Vault Policy for service account

```hcl
path "sys/storage/raft/snapshot" {
  capabilities = ["read"]
}

```
