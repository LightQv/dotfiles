import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

import { assertSafeLocalGitConfig } from "./git-safety.mjs";

const BUILTIN_FORGE_HOSTS = new Map([
  ["github.com", "github"],
  ["gitlab.com", "gitlab"],
]);
const SUPPORTED_FORGES = new Set(["github", "gitlab"]);

function validHostname(hostname) {
  if (hostname.length > 253 || !hostname.includes(".") || hostname !== hostname.toLowerCase()) return false;
  return hostname.split(".").every(
    (label) => label.length > 0
      && label.length <= 63
      && /^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/.test(label),
  );
}

export function loadForgeHosts(filePath = join(homedir(), ".config", "opencode", "forge-hosts.local.json")) {
  const hosts = new Map(BUILTIN_FORGE_HOSTS);
  let source;
  try {
    source = readFileSync(filePath, "utf8");
  } catch (error) {
    if (error.code === "ENOENT") return hosts;
    throw new Error("local forge host configuration is unreadable");
  }

  let configured;
  try {
    configured = JSON.parse(source);
  } catch {
    throw new Error("local forge host configuration is malformed");
  }
  if (!configured || typeof configured !== "object" || Array.isArray(configured)) {
    throw new Error("local forge host configuration must be an object");
  }

  for (const [host, forge] of Object.entries(configured)) {
    if (!validHostname(host)) throw new Error(`invalid local forge host: ${host}`);
    if (!SUPPORTED_FORGES.has(forge)) throw new Error(`unsupported local forge type for: ${host}`);
    if (hosts.has(host)) throw new Error(`local forge host conflicts with built-in host: ${host}`);
    hosts.set(host, forge);
  }
  return hosts;
}

function remoteParts(remoteUrl) {
  const value = remoteUrl.trim();
  if (!value) throw new Error("origin URL is empty");

  if (/^[a-z][a-z0-9+.-]*:\/\//i.test(value)) {
    let parsed;
    try {
      parsed = new URL(value);
    } catch {
      throw new Error("origin URL is malformed");
    }
    if (!["https:", "ssh:"].includes(parsed.protocol)) {
      throw new Error(`unsupported origin protocol: ${parsed.protocol}`);
    }
    if (parsed.port) throw new Error("origin URL uses an unexpected port");
    if (parsed.password) throw new Error("origin URL must not contain a password");
    if (parsed.protocol === "https:" && parsed.username) {
      throw new Error("origin URL must not contain HTTPS credentials");
    }
    if (parsed.protocol === "ssh:" && parsed.username !== "git") throw new Error("SSH username must be git");
    return { host: parsed.hostname, path: parsed.pathname };
  }

  const scp = /^(?:([^@/\s]+)@)?([^:/\s]+):(.+)$/.exec(value);
  if (!scp) throw new Error("origin URL is not a supported network URL");
  if (scp[1] !== "git") throw new Error("SSH username must be git");
  return { host: scp[2], path: scp[3] };
}

export function parseRemoteUrl(remoteUrl, forgeHosts = loadForgeHosts()) {
  const parts = remoteParts(remoteUrl);
  const host = parts.host.toLowerCase().replace(/\.$/, "");
  const forge = forgeHosts.get(host);
  if (!forge) throw new Error(`unsupported forge host: ${host}`);

  const repository = parts.path.replace(/^\/+|\/+$/g, "").replace(/\.git$/i, "");
  const segments = repository.split("/").filter(Boolean);
  if (segments.length < 2 || (forge === "github" && segments.length !== 2)) {
    throw new Error(`invalid ${forge} repository path`);
  }
  if (segments.some((segment) => !/^[A-Za-z0-9._-]+$/.test(segment) || segment === "." || segment === "..")) {
    throw new Error("repository path contains unsupported characters");
  }

  return {
    forge,
    host,
    repository,
    selector: forge === "github" ? `${host}/${repository}` : `https://${host}/${repository}`,
  };
}

export function matchRemoteUrls(remoteUrls, forgeHosts = loadForgeHosts()) {
  if (!remoteUrls.length) throw new Error("origin has no URLs");
  const remotes = remoteUrls.map((url) => parseRemoteUrl(url, forgeHosts));
  const expected = JSON.stringify(remotes[0]);
  if (remotes.some((remote) => JSON.stringify(remote) !== expected)) {
    throw new Error("origin fetch and push URLs do not resolve to one repository");
  }
  return remotes[0];
}

export function detectOriginForge(cwd = process.cwd()) {
  assertSafeLocalGitConfig(cwd);
  let fetchUrls;
  let pushUrls;
  try {
    const options = {
      cwd,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    };
    fetchUrls = execFileSync("git", ["remote", "get-url", "--all", "origin"], options);
    pushUrls = execFileSync("git", ["remote", "get-url", "--push", "--all", "origin"], options);
  } catch {
    throw new Error("origin remote is missing or unreadable");
  }
  const urls = `${fetchUrls}\n${pushUrls}`
    .split("\n")
    .map((url) => url.trim())
    .filter(Boolean);
  return matchRemoteUrls(urls);
}

const isMain = process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;
if (isMain) {
  try {
    process.stdout.write(`${JSON.stringify(detectOriginForge())}\n`);
  } catch (error) {
    process.stderr.write(`Forge detection failed: ${error.message}\n`);
    process.exitCode = 2;
  }
}
