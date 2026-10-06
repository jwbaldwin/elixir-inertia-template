# Deployment

The template includes a Docker release and an optional Kamal sample. CI runs quality checks only. Choose the host, registry, database, domain, and deployment trigger before wiring a production workflow.

## Build and access

- Pin the Kamal version in a project's `Gemfile` and lockfile before relying on version-specific settings
- Build for the target server's architecture; the server should pull and run the checked release image
- When building outside Kamal, include the `service` image label matching the configured service and tag the image with the checked commit
- Deploy that same image with `kamal deploy --skip-push --version COMMIT`
- Serialize production deployments and do not cancel a deployment midway through rollout
- Keep production credentials in the deployment environment, outside source, build arguments, command arguments, and logs
- Pin an independently verified SSH host key, require strict host checking, and disable agent forwarding
- Treat the deploy account's Docker access as administrative access

Kamal proxy routes apps by hostname. Each container can listen on port 4000 without publishing that port on the host. Phoenix must bind to an interface the proxy can reach. Inventory existing services before changing ownership of ports 80 and 443; reuse an existing Kamal proxy on shared hosts.

## Database and migrations

Run migrations from the exact release image that will receive traffic. This template exposes `TemplateApp.Release.migrate/0`, invoked through the release binary's `eval` command. A migration failure must stop deployment.

- Exercise the release migration command twice against disposable PostgreSQL: once on an empty database and once on the migrated schema
- Keep migrations compatible with the old container, which can still serve requests during migration
- Use separate expansion and removal steps for schema changes that cannot support old and new code together
- Keep seeds separate from normal deployment
- Remember that rolling back an image does not roll back the database

If a managed database uses a transaction pooler, choose a direct connection for migrations and test the pooled runtime connection separately. The template currently reads one `DATABASE_URL`; separate migration credentials or URLs require explicit runtime/release configuration. Configure verified PostgreSQL TLS when the provider requires it rather than assuming URL parameters configure the driver.

Pass credentials to one-shot migration containers through a restricted temporary environment file, remove it on exit, and remove the container after it finishes.

## Health and rollout

`/healthz` sits outside the session pipeline and currently proves only that the app responds. Decide whether production readiness must also check database access; the sample does not implement that check.

Before a DNS cutover, run the final image with its runtime configuration and verify it through a loopback-bound preflight port. Record the previous DNS records and TLS/proxy settings, including both IPv4 and IPv6 records. Change only this app's routing.

After rollout, check HTTPS, health, assets, authentication, a database write, and WebSocket connections where used. Watch logs and memory while old and new containers overlap. Confirm that the next normal deploy follows the same path.

Keep the old host available until the new deployment is verified and retirement is approved. For populated databases, plan data cutover separately: DNS rollback does not copy new writes back to the old database.

Use [Remote Operations](REMOTE_OPERATIONS.md) for the optional IEx and log helpers. Production deployment and infrastructure changes require explicit approval.
