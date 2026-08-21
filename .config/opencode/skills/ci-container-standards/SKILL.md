---
name: ci-container-standards
description: Use for Dockerfiles, Docker Compose, GitLab CI, GitHub Actions, Nginx, Harbor, deployment scripts, container security, build reproducibility, and release pipelines.
---

# CI And Container Standards

## Authority

Repository manifests, lockfiles, CI includes, deployment contracts, and existing infrastructure are the source of truth. Preserve required platform behavior. When local guidance is absent, use official documentation matching pinned major versions; do not migrate tools merely to match current examples.

## Review First

- Trace build, test, publish, deploy, migration, worker, and rollback stages end to end.
- Inspect referenced templates instead of assuming their behavior.
- Treat `.env*`, credentials, dumps, signing material, registry tokens, and deployment variables as secrets. Never print values.
- Distinguish application images, workers, schedulers, migration jobs, and frontend/runtime images.

## Containers

- Use deterministic dependency installation (`npm ci`, frozen lockfile modes, pinned Python constraints) when compatible with the repository.
- Use `.dockerignore`; exclude VCS data, secrets, dependencies, caches, tests/build output when not required.
- Prefer multi-stage builds and minimal runtime images.
- Run as non-root unless the runtime has a documented requirement.
- Use exec-form `ENTRYPOINT`/`CMD`. Shell operators such as `&&` require an explicit shell or, preferably, a checked entrypoint script using `exec`.
- Never use development reloaders in production.
- Keep API, Celery worker, Celery beat, and migrations as explicit processes/jobs.
- Add bounded health checks and graceful signal handling.
- Do not persist secrets through Docker `ARG`, `ENV`, image layers, or copied environment files. Prefer BuildKit secret mounts and runtime secret injection.

## CI/CD

- Pin action versions and container image versions or digests where practical. Avoid `latest`, `stable`, `canary`, and mutable remote scripts for security-sensitive jobs.
- Verify downloaded scripts with a checksum/signature and least-privilege permissions; never apply mode `777` without a documented need.
- Keep lint in check mode. Do not let CI rewrite source with `--fix` or formatter write modes.
- Run tests before image publication/deployment. Placeholder test commands do not count.
- Use protected environments and least-privilege tokens for registry/deployment access.
- Make security scan failure policy explicit. Do not silently allow high-severity findings.
- Preserve artifacts, checksums, provenance, signing, and rollback metadata for releases.
- Prevent concurrent deployments from racing through environment locks/resource groups.

## Frontend Images

- Keep build-time and runtime configuration boundaries explicit.
- Do not bake secret environment files into static bundles or Nginx images.
- Pass Sentry/source-map credentials as ephemeral build secrets; upload artifacts without retaining tokens in layers.
- Validate Nginx SPA fallback, cache policy, compression, headers, and runtime config substitution.

## Verification

Run repository-provided validation first. Where available, use Dockerfile/Compose parsing, CI lint, shell lint, image build, container health check, and relevant tests. Do not publish, deploy, migrate, or pull mutable remote scripts during validation without explicit approval.

Report exact files, commands, blockers, and residual deployment risk. Never claim a pipeline or image works based only on syntax inspection.
