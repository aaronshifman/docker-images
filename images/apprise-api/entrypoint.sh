#!/bin/sh

cd /opt/apprise/webapp || exit

pwd
ls

# There's a gotcha that we want these static files accessible to a sidecar
cp -r ./static /mnt/nginx/s/
cp ./etc/nginx.conf /mnt/nginx/

gunicorn -c /opt/apprise/webapp/gunicorn.conf.py -b :8080 --worker-tmp-dir /dev/shm core.wsgi
