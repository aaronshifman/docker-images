FROM python:3.11-slim

RUN pip install --no-cache-dir PyJWT cryptography requests
ADD generate_token.py /app/generate_token.py
WORKDIR /app

ENTRYPOINT ["python", "generate_token.py"]
