# github-app-token

Generate an installation token for a github app signed by the private key

Creates an installation token and writes it to `/output/token` to be read in elsewhere where needed

Implementation from GH docs

- [JWT](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-python-to-generate-a-jwt)
- [Access Token](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app#generating-an-installation-access-token)

## Environment Variables

| Variable        | Example |
| --------------- | ------- |
| CLIENT_ID       | xxx     |
| INSTALLATION_ID | yyy     |

## Required Files

| File   | Path            |
| ------ | --------------- |
| App PK | /secret/key.pem |
