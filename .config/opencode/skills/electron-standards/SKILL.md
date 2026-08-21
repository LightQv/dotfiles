---
name: electron-standards
description: Use for secure Electron JavaScript or TypeScript apps, IPC, windows, sessions, renderer UI, linting, formatting, testing, packaging, signing, and releases.
---

## When To Use

- Use this skill for any Electron feature, refactor, bug fix, test, build, release, or security-hardening task.
- Use this skill when touching `main`, `preload`, `renderer`, IPC contracts, packaging/signing, auto-updates, or E2E automation.
- Apply this skill by default when creating new Electron modules so secure defaults exist from first commit.
- Treat repository code, package scripts, lockfiles, Forge/Builder configuration, and existing JavaScript or TypeScript choice as the source of truth.

## Core Security Baseline (Mandatory)

- Treat every renderer surface as untrusted input.
- Every production `BrowserWindow` must set:
  - `contextIsolation: true`
  - `sandbox: true`
  - `nodeIntegration: false`
- Keep `webviewTag: false` unless explicitly required and reviewed.
- Never expose raw `ipcRenderer` or generic `send/invoke` passthrough APIs to renderer.
- Enforce CSP (prefer session-level header injection) and avoid broad/unsafe directives.
- Validate all IPC arguments in main process (type, shape, range/length, path/URL allowlists).

## Process Boundaries

- Main process owns privileged capabilities:
  - filesystem access
  - process execution
  - app/session policy
  - update/signing flows
  - secrets/tokens
- Preload is a narrow bridge:
  - expose explicit, named functions only
  - return unsubscribe functions for event listeners
  - keep bridge deterministic and minimal
- Renderer is UI-only:
  - no Node assumptions
  - consume only typed `window.electronAPI` surface
  - clean up listeners in lifecycle teardown

## IPC Standards

- Prefer `ipcMain.handle` + `ipcRenderer.invoke` for request/response flows.
- Keep channels typed and centralized; use one source of truth for contracts.
- In JavaScript repositories, preserve JavaScript and enforce explicit channel/result contracts with runtime validation and JSDoc where useful. Do not force a TypeScript migration.
- Use stable channel naming (`domain:action` recommended).
- Never pass renderer-controlled values directly into sensitive APIs (`exec`, file paths, external URLs).
- Remove stale channels and dead handlers during refactors.

### Result/Error Contract (Mandatory)

- Do not rely on thrown custom errors as IPC contract.
- Return structured, serializable result objects:

```ts
type Result<T> =
  | { success: true; data: T }
  | {
      success: false;
      error: {
        code: string;
        message: string;
        details?: unknown;
      };
    };
```

- Normalize error codes so renderer logic branches deterministically.
- Keep internal stack traces in main-process logs, not user-facing payloads.

## Secure Implementation Snippets

### Hardened BrowserWindow

```ts
const win = new BrowserWindow({
  webPreferences: {
    preload: join(__dirname, "../preload/index.js"),
    contextIsolation: true,
    sandbox: true,
    nodeIntegration: false,
    webviewTag: false,
    allowRunningInsecureContent: false,
    experimentalFeatures: false,
  },
});
```

### Explicit preload bridge

```ts
contextBridge.exposeInMainWorld("electronAPI", {
  loadPrefs: () => ipcRenderer.invoke("prefs:load"),
  savePrefs: (prefs: PrefsInput) => ipcRenderer.invoke("prefs:save", prefs),
  onUpdateAvailable: (cb: (version: string) => void) => {
    const handler = (_event: IpcRendererEvent, version: string) => cb(version);
    ipcRenderer.on("update:available", handler);
    return () => ipcRenderer.removeListener("update:available", handler);
  },
});
```

### IPC validation pattern

```ts
ipcMain.handle("file:read", async (_event, relPath: unknown): Promise<Result<string>> => {
  if (typeof relPath !== "string" || relPath.length > 500) {
    return {
      success: false,
      error: { code: "VALIDATION_FAILED", message: "Invalid path" },
    };
  }

  const resolved = path.resolve(ALLOWED_BASE_DIR, relPath);
  const relative = path.relative(ALLOWED_BASE_DIR, resolved);
  if (relative.startsWith("..") || path.isAbsolute(relative)) {
    return {
      success: false,
      error: { code: "PERMISSION_DENIED", message: "Access denied" },
    };
  }

  const data = await fs.readFile(resolved, "utf-8");
  return { success: true, data };
});
```

## Session, Permissions, and Navigation Hardening

- Set CSP headers via `session.defaultSession.webRequest.onHeadersReceived` where feasible.
- Enforce permission allowlists with:
  - `setPermissionRequestHandler`
  - `setPermissionCheckHandler`
- Block untrusted navigation in `will-navigate`.
- Deny popup creation by default with `setWindowOpenHandler`.
- Guard `shell.openExternal`:
  - allow HTTPS only
  - enforce hostname allowlist
  - reject unknown protocols and local-file pivots

## Architecture and File Organization

- Keep strict separation:
  - `src/main/` for lifecycle/orchestration/policy
  - `src/preload/` for bridge and API declarations
  - `src/renderer/` for UI only
  - `src/shared/` for contracts/types only (no privileged runtime side effects)
- Keep app entrypoint thin; register IPC handlers by domain modules.
- In multi-window apps, keep state authority in main and publish synchronized updates via typed IPC events.

## Packaging, Signing, and Updates

- Prefer Electron Forge for packaging and maker flow.
- Prefer `electron-updater` for update orchestration.
- Update policy requirements:
  - HTTPS-only feeds
  - signed artifacts
  - no renderer exposure of update secrets/tokens
  - no insecure fallback endpoints
- Enable ASAR by default; unpack only required binaries/native modules.
- macOS release requirements:
  - hardened runtime
  - correct entitlements
  - notarization in CI
- Windows release requirements:
  - code-signing configured (OV/EV or cloud-signing provider)
- Never commit credentials, signing material, or notarization secrets.

## Testing Standards

- Use split test projects:
  - main/preload in Node environment
  - renderer in jsdom/browser environment
- Unit-test IPC handlers directly (including validation and error-code behavior).
- Mock `window.electronAPI` in renderer tests and assert listener cleanup paths.
- Use Playwright for Electron E2E (do not invest in Spectron).
- E2E minimum coverage:
  - security preferences present at runtime
  - key IPC roundtrip paths
  - critical user journeys

## Performance and Observability

- Keep preload minimal and deterministic.
- Use renderer code splitting/lazy loading for heavy routes.
- Externalize native modules in build configuration.
- Set and enforce bundle-size budgets in CI.
- Keep source maps for error pipeline; avoid unnecessary public distribution.
- Emit structured logs for:
  - app startup path
  - window lifecycle
  - IPC failures by stable error code
  - update lifecycle events

## Deterministic Agent Workflow

1. Preflight
   - Identify touched process (`main` / `preload` / `renderer` / `shared`).
   - Confirm baseline security settings remain intact.
2. Contract
   - Define or update typed IPC contracts first.
3. Implement
   - Add/modify main handlers with validation + `Result<T>` return shape.
   - Expose only explicit preload APIs.
   - Consume APIs via renderer wrappers/hooks.
4. Harden
   - Re-check CSP, permission handlers, and navigation/window policies.
5. Verify
   - Add/update unit tests and renderer bridge mocks.
   - Add/update E2E coverage for critical flows.
6. Release Gate
   - Validate packaging/signing/update configuration integrity.
   - Confirm no secret leakage in code, logs, or artifacts.
7. Frontend Completion Gate
   - Detect package manager and commands from lockfiles, scripts, and tool configuration.
   - Format changed renderer/main/preload files only with the configured formatter.
   - Apply safe lint fixes only to changed files, then run non-mutating lint and type checks.
   - Run the smallest relevant Node/renderer/Electron test targets.
   - Run packaging or production build checks when build configuration or process boundaries changed.
   - Report exact commands and failures; do not claim completion with required checks failing.

## How Agents Should Apply This Skill

- Start every Electron task by identifying the process boundary first (`main`, `preload`, `renderer`, `shared`).
- Implement contract-first: define IPC types and result shapes before handler/UI changes.
- Enforce hardening during implementation, not as a final patch step.
- Treat security checks and validation as required functionality, not optional polish.
- Before finishing, run the release checklist and report any unmet items explicitly.
- When repository guidance is absent, use official Electron and tool documentation matching installed major versions.

## Release Hygiene Checklist

- [ ] All windows enforce `contextIsolation=true`, `sandbox=true`, `nodeIntegration=false`
- [ ] No raw `ipcRenderer` exposure in preload
- [ ] New/changed IPC handlers validate untrusted args
- [ ] Typed, stable `Result<T>` contract for IPC responses
- [ ] CSP + permission handlers remain strict
- [ ] Navigation and external-link policies are enforced
- [ ] Tests cover behavior and listener cleanup paths
- [ ] Packaging/signing/update settings are intact
- [ ] No secrets, tokens, signing material, or certs committed

## Red Flags and Anti-Patterns

- `nodeIntegration: true` in production windows.
- Generic bridge methods exposing unrestricted IPC.
- Passing renderer-supplied URLs directly to `shell.openExternal`.
- Unvalidated file paths or command strings in `ipcMain` handlers.
- Disabling CSP or allowing unsafe directives without strict justification.
- Shipping unsigned or unnotarized production builds.
- New testing investment in deprecated Spectron tooling.
