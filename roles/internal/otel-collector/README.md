# otel-collector

Installs the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)
(core distribution) as a systemd service on the host. It listens on
`127.0.0.1:4318` (OTLP/HTTP) and `127.0.0.1:4317` (OTLP/gRPC) and forwards
traces to a single configurable OTLP/HTTP upstream — e.g. Sentry's OTLP
ingest endpoint.

The local app (PHP, bash, etc.) just talks to `http://127.0.0.1:4318` and
doesn't need to know about the upstream backend or its credentials. The
collector handles batching, retries, and (optionally) sampling.

## Variables

See [`defaults/main.yml`](defaults/main.yml). The important ones to set in
`group_vars` are:

- `otel_collector_upstream_endpoint` — full URL of the upstream OTLP/HTTP
  traces endpoint, e.g.
  `https://o12345.ingest.sentry.io/api/67890/otlp/v1/traces`.
- `otel_collector_upstream_headers` — map of header name to value, e.g.
  `{ x-sentry-auth: "sentry sentry_key=..., sentry_version=7" }`.
  **Vault-encrypt the secret values.**
- `otel_collector_resource_attributes` — `service.name`,
  `deployment.environment`, etc. attached to every span.
- `otel_collector_sampling_ratio` — `1.0` keeps everything; lower if Sentry
  quota becomes a concern.

Leaving `otel_collector_upstream_endpoint` blank installs the collector and
runs it, but routes received spans to a no-op exporter (useful for staging
the install before wiring up Sentry).
