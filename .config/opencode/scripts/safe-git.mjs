import { execFileSync } from "node:child_process";
import { existsSync, lstatSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { isAbsolute, join, normalize } from "node:path";

import { detectBranchPolicy, isProtectedBranch } from "./branch-policy.mjs";
import { detectOriginForge } from "./detect-forge.mjs";
import { assertSafeLocalGitConfig } from "./git-safety.mjs";

const cwd = process.cwd();
const baseEnv = {
  ...process.env,
  GIT_PAGER: "cat",
  GIT_TERMINAL_PROMPT: "0",
  PAGER: "cat",
};
const sensitivePath = /(^|\/)(?:\.env(?:\.|$)|credentials?(?:\.|$)|secrets?(?:\.|$)|id_(?:rsa|dsa|ecdsa|ed25519)(?:\.|$))|\.(?:key|p12|pfx|pem)$/i;

function runGit(args, options = {}) {
  return execFileSync("git", args, {
    cwd,
    env: { ...baseEnv, ...options.env },
    encoding: "utf8",
    maxBuffer: 16 * 1024 * 1024,
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

function safeGit(args, options = {}) {
  return runGit(["-c", "core.hooksPath=/dev/null", "-c", "commit.gpgSign=false", ...args], options);
}

function assertPublishableBranch() {
  const policy = detectBranchPolicy(cwd);
  if (!policy.current || policy.isProtected) throw new Error("current branch is empty or protected");
  return policy;
}

function validateBranchName(branch, remoteDefault) {
  if (!branch || /[\x00-\x20\x7f]/.test(branch)) throw new Error("branch name is missing or contains whitespace");
  safeGit(["check-ref-format", "--branch", branch]);
  if (isProtectedBranch(branch, remoteDefault)) throw new Error("new branch name is protected");
}

function createBranch(branch) {
  assertSafeLocalGitConfig(cwd);
  const policy = detectBranchPolicy(cwd);
  validateBranchName(branch, policy.remoteDefault);
  try {
    runGit(["show-ref", "--verify", "--quiet", `refs/heads/${branch}`]);
    throw new Error("branch already exists locally");
  } catch (error) {
    if (error.message === "branch already exists locally") throw error;
    if (error.status !== 1) throw new Error("local branch check failed");
  }
  if (runGit(["ls-remote", "--heads", "origin", `refs/heads/${branch}`])) {
    throw new Error("branch already exists remotely");
  }
  safeGit(["switch", "-c", branch]);
  if (runGit(["branch", "--show-current"]) !== branch) throw new Error("branch switch verification failed");
  return { status: "branch-created", branch };
}

function normalizePaths(paths) {
  if (!paths.length) throw new Error("no paths selected");
  const selected = paths.map((path) => {
    if (!path || isAbsolute(path) || /[\x00-\x1f\x7f]/.test(path)) throw new Error("selected path is invalid");
    const cleaned = normalize(path).replace(/^\.\//, "");
    if (cleaned === ".git" || cleaned.startsWith(".git/") || cleaned === ".." || cleaned.startsWith("../")) {
      throw new Error("selected path escapes the repository");
    }
    if (sensitivePath.test(cleaned)) throw new Error(`sensitive path is blocked: ${cleaned}`);
    if (existsSync(join(cwd, cleaned)) && lstatSync(join(cwd, cleaned)).isDirectory()) {
      throw new Error(`directories cannot be staged as one path: ${cleaned}`);
    }
    return cleaned;
  });
  if (new Set(selected).size !== selected.length) throw new Error("selected paths contain duplicates");
  return selected;
}

function commit(subject, paths) {
  assertSafeLocalGitConfig(cwd);
  assertPublishableBranch();
  if (!subject || subject.length > 200 || /[\x00-\x1f\x7f]/.test(subject)) throw new Error("commit subject is invalid");
  const selected = normalizePaths(paths);
  const attributes = safeGit(["check-attr", "filter", "--", ...selected]);
  if (attributes && attributes.split("\n").some((line) => !line.endsWith(": filter: unspecified"))) {
    throw new Error("selected paths use Git content filters");
  }
  try {
    runGit(["diff", "--cached", "--quiet"]);
  } catch {
    throw new Error("index already contains staged changes");
  }

  const temporaryDirectory = mkdtempSync(join(tmpdir(), "opencode-safe-git-"));
  const temporaryIndex = join(temporaryDirectory, "index");
  const env = { GIT_INDEX_FILE: temporaryIndex };
  try {
    safeGit(["read-tree", "HEAD"], { env });
    safeGit(["add", "--", ...selected], { env });
    const staged = safeGit(["diff", "--cached", "--name-only", "-z"], { env })
      .split("\0")
      .filter(Boolean)
      .sort();
    if (JSON.stringify(staged) !== JSON.stringify([...selected].sort())) {
      throw new Error("staged paths differ from approved paths");
    }
    safeGit(["diff", "--cached", "--check"], { env });
    safeGit(["commit", "-m", subject], { env });
    safeGit(["reset", "--mixed", "--quiet", "HEAD"]);
  } finally {
    rmSync(temporaryDirectory, { recursive: true, force: true });
  }
  return { status: "committed", subject, paths: selected };
}

function push() {
  assertSafeLocalGitConfig(cwd);
  detectOriginForge(cwd);
  const policy = assertPublishableBranch();
  let upstream = "";
  try {
    upstream = runGit(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"]);
  } catch {}

  if (upstream) {
    if (upstream !== `origin/${policy.current}`) throw new Error("upstream does not match current origin branch");
    const [behind] = runGit(["rev-list", "--left-right", "--count", `${upstream}...HEAD`]).split(/\s+/).map(Number);
    if (behind) throw new Error("current branch is behind or diverged from upstream");
    safeGit(["push", "origin", `HEAD:refs/heads/${policy.current}`]);
  } else {
    if (runGit(["ls-remote", "--heads", "origin", `refs/heads/${policy.current}`])) {
      throw new Error("remote branch exists without a matching upstream");
    }
    safeGit(["push", "--set-upstream", "origin", `HEAD:refs/heads/${policy.current}`]);
  }
  return { status: "pushed", branch: policy.current };
}

function main() {
  const [mode, ...args] = process.argv.slice(2);
  if (mode === "branch" && args.length === 1) return createBranch(args[0]);
  if (mode === "commit") {
    const separator = args.indexOf("--");
    if (separator !== 1) throw new Error("usage: safe-git.mjs commit <subject> -- <path>...");
    return commit(args[0], args.slice(2));
  }
  if (mode === "push" && args.length === 0) return push();
  throw new Error("usage: safe-git.mjs <branch|commit|push>");
}

try {
  process.stdout.write(`${JSON.stringify(main())}\n`);
} catch (error) {
  process.stderr.write(`Safe Git failed: ${error.message}\n`);
  process.exitCode = 1;
}
