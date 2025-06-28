#!/usr/bin/env python3

import os
import time

import jwt
import requests

PEMFILE = "/secret/key.pem"
OUTPUT = "/output/token"

client_id = os.environ.get("CLIENT_ID")
if not client_id:
    raise ValueError("CLIENT_ID not set")

installation_id = os.environ.get("INSTALLATION_ID")
if not installation_id:
    raise ValueError("INSTALLATION_ID not set")

with open(PEMFILE, "rb") as pem_file:
    signing_key = pem_file.read()

payload = {
    "iat": int(time.time()),
    # only need 60s - the installation token is good for an hour
    "exp": int(time.time()) + 60,
    "iss": client_id,
}

# Create JWT
encoded_jwt = jwt.encode(payload, signing_key, algorithm="RS256")

# Get installation token
resp = requests.post(
    f"https://api.github.com/app/installations/{installation_id}/access_tokens",
    headers={
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {encoded_jwt}",
        "X-GitHub-Api-Version": "2022-11-28",
    },
)

with open(OUTPUT, "w") as f:
    f.write(resp.json()["token"])
