FROM python:3.12-slim AS base

ARG VERSION
ADD https://github.com/caronc/apprise-api.git#${VERSION} .

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV APPRISE_CONFIG_DIR=/config
ENV APPRISE_ATTACH_DIR=/attach
ENV APPRISE_PLUGIN_PATHS=/plugin

FROM base AS runtime

# Install requirements and gunicorn
RUN set -eux && \
  apt-get update -qq && \
  echo "Installing tools" && \
  apt-get install -y -qq \
  curl sed git && \
  echo "Installing python requirements" && \
  pip3 install --no-cache-dir -q -r requirements.txt gunicorn && \
  pip freeze && \
  echo "Cleaning up" && \
  apt-get --yes autoremove --purge && \
  apt-get clean --yes && \
  rm --recursive --force --verbose /var/lib/apt/lists/* && \
  rm --recursive --force --verbose /tmp/* && \
  rm --recursive --force --verbose /var/tmp/* && \
  rm --recursive --force --verbose /var/cache/apt/archives/* && \
  truncate --size 0 /var/log/*log

RUN mkdir -p /usr/share/nginx/base/html/s

# set work directory
WORKDIR /opt/apprise

# Copy over Apprise API
RUN mkdir -p webapp
RUN mv /apprise_api/* webapp/

COPY ./entrypoint.sh ./entrypoint.sh
RUN ["chmod", "+x", "./entrypoint.sh"]

USER nobody:nogroup
CMD ["./entrypoint.sh"]
