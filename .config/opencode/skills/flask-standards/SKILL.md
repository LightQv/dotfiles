---
name: flask-standards
description: Standards for building and maintaining Flask backend code with clean layering, consistent responses, and production-safe defaults
---

## When To Use

- Use this skill for any Flask backend feature, refactor, bug fix, test, or infrastructure change.
- Use this skill for code in routes, services, validation, models, auth, logging, config, migrations, and tests.
- Treat repository code, dependency versions, configuration, tests, and established paths as the source of truth. Use official Flask and extension documentation matching installed major versions when local guidance is absent.

## Architecture

- Preferred layers: `routes -> services -> validators -> repositories/models`.
- Keep routes thin: parse request, call service, return response.
- Keep business logic in services, not in routes.
- Keep DB validation rules in validator modules or validator classes.
- Keep data access reusable and explicit (repository helpers or model query helpers).

## App Initialization

- Prefer `create_app(config_name: str | None = None)` app factory for new code.
- Keep extension singletons in `extensions.py` and call `init_app(app)` in factory.
- Avoid heavy import-time side effects.
- Initialize in this order: config/env -> logging/observability -> extensions -> handlers -> blueprints.

## Routes And Blueprints

- Organize blueprints by domain and context (`admin`, `client`, `common`, etc.).
- Use `flask.Response` or `jsonify` consistently.
- Never import HTTP `Response` from `requests` in route modules.
- Keep authn/authz decorators at route level, before business call.
- Use explicit HTTP methods and stable URL naming.

## Request Validation

- Validate input as early as possible.
- Validation errors must raise typed business exceptions (not generic `Exception`).
- Keep validators deterministic and explicit about supported query/body fields.
- Return actionable validation messages and stable error keys.

## Service Layer

- Service functions orchestrate validation, queries, external calls, and transaction boundaries.
- Keep functions focused and composable.
- Use type hints for function signatures and key local variables.
- Avoid hidden side effects; if needed, make side effects explicit and logged.

## Response And Error Contract

- Standardize API output envelope for success and error responses.
- Register global error handlers once during app startup.
- Map business exceptions to stable HTTP status codes and error keys.
- Avoid mixing raw strings, ad-hoc JSON, and DTO JSON in the same endpoint family.

## Auth And Security

- Keep authentication and authorization concerns separate.
- For cookie-based auth, enforce CSRF checks on state-changing routes.
- Parse boolean env vars safely (never use `bool(os.getenv(...))`).
- Never log tokens, secrets, or raw sensitive payloads.

## Models And ORM

- One model per file when practical; keep naming and tablename conventions consistent.
- Use explicit relationships and enum types for status/state fields.
- Keep shared timestamp fields consistent (`created_at`, `updated_at`).
- Avoid circular imports by central model import registration.

## Config And Environment

- Validate required environment variables at startup with clear errors.
- Keep `.env` local-only and never committed.
- Use config classes or equivalent for env-specific behavior (`local`, `dev`, `rec`, `prod`).
- Keep secure defaults for production (cookies, CORS, debug disabled).

## Logging And Observability

- Keep structured request/response logs with method, path, status, and latency.
- Add correlation/request IDs when available.
- Keep Sentry (or equivalent) initialized centrally.
- Filter expected business validation noise from error tracking.

## Testing And Tooling

- Add tests for each feature change (service-level and route-level where relevant).
- Keep test fixtures deterministic and isolated.
- Enforce lint and format checks in CI (for example: Ruff).
- CI test stage must run real tests, not placeholders.

## Docker And Runtime

- Ensure container command/entrypoint is shell-correct.
- Run migrations safely before app start when required.
- Keep worker/beat processes explicit and separate from API process.

## Deliverables Checklist

- New/updated route follows thin-controller pattern.
- Business logic lives in service layer with typing.
- Validation and errors use typed exceptions and global handlers.
- Response shape is consistent with project contract.
- Tests added/updated and passing locally.
- Lint/format/CI expectations preserved.
