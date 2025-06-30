# apprise-api

Rebuild of [apprise-api](https://github.com/caronc/apprise-api/tree/master) to strip out the additional supervisord / nginx layers.
As a result this cannot run standalone and needs an nginx sidecar, use the original author's nginx.conf as a [starting place](https://github.com/caronc/apprise-api/blob/master/apprise_api/etc/nginx.conf)

## Setup

Writes static files to a volume mounted at `/mnt/nginx`, the assumption is that this is mountable by an independent nginx container

### Example Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apprise
spec:
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: apprise
  template:
    metadata:
      labels:
        app.kubernetes.io/name: apprise
    spec:
      containers:
        - name: nginx
          image: nginxinc/nginx-unprivileged:alpine3.22
          ports:
            - name: http
              containerPort: 8000
              protocol: TCP
          volumeMounts:
            - mountPath: /etc/nginx/nginx.conf
              name: nginx-conf
              subPath: nginx.conf
            - mountPath: /usr/share/nginx/html
              name: nginx
            - mountPath: /tmp/nginx
              name: nginx-tmp
            - mountPath: /var/cache/nginx
              name: nginx-var
        - name: apprise
          image: docker.shifman.dev/shifman/apprise-api:v1.2.0
          volumeMounts:
            - mountPath: /mnt/nginx
              name: nginx
            - mountPath: /attach
              name: attach
            - mountPath: /config
              name: config
            - mountPath: /run/apprise
              name: apprise
            - mountPath: /tmp
              name: tmp
          ports:
            - name: http-internal
              containerPort: 8080
              protocol: TCP
      volumes:
        - name: nginx-conf
          configMap:
            name: nginx-conf
        - name: nginx
          emptyDir: {}
        - name: config
          emptyDir: {}
        - name: attach
          emptyDir: {}
        - name: apprise
          emptyDir: {}
        - name: tmp
          emptyDir: {}
        - name: nginx-var
          emptyDir: {}
        - name: nginx-tmp
          emptyDir: {}
```
