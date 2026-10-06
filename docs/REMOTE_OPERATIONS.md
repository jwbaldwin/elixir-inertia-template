# Remote Operations Helpers

See [Deployment](DEPLOYMENT.md) for release-image migrations, access, and rollout guidance.

This template includes two optional helper scripts for Docker/Kamal-style deployments:

- `bin/connect`: opens a remote IEx session inside the running app container
- `bin/logs [tail_lines]`: tails logs from the running app container

They are intentionally small shell wrappers around `ssh`, `docker exec`, and `docker logs`. They are not a deployment framework.

## Defaults

The scripts default to:

- SSH host alias: `deploy`
- Container name pattern: `template_app-web`
- Release binary: `bin/template_app`
- Log tail count: `200`

These defaults match the template's placeholder OTP app and Kamal service names. New projects should update them or override them through environment variables.

## Usage

Open a remote IEx session:

```sh
bin/connect
```

Tail the last 200 lines and follow logs:

```sh
bin/logs
```

Tail a different number of lines:

```sh
bin/logs 500
```

Override the remote shape without editing the scripts:

```sh
REMOTE_APP_HOST=production \
REMOTE_APP_CONTAINER_PATTERN=acme_app-web \
REMOTE_APP_RELEASE_BIN=bin/acme_app \
bin/connect
```

## Maintenance Rules

- When renaming `:template_app`, update `REMOTE_APP_RELEASE_BIN` defaults in `bin/connect`
- When renaming the Kamal service or container pattern, update `REMOTE_APP_CONTAINER_PATTERN` defaults in both scripts
- When changing SSH aliases, update `REMOTE_APP_HOST` defaults or document the required alias in the project README
- Keep private hostnames, IP addresses, usernames, and production-only aliases out of committed scripts
- If a project does not deploy with Docker/Kamal, update these helpers to match the real runtime or delete them
- Keep script docs, README deployment notes, and `config/deploy.yml` consistent

## Troubleshooting

- If `bin/connect` says no container matched, check the deployed container name with `docker ps` on the remote host
- If remote IEx fails after connecting, verify the release binary name matches the OTP app release
- If `bin/logs` connects but shows no useful output, check whether logs are emitted to Docker stdout/stderr or sent to another logging backend
