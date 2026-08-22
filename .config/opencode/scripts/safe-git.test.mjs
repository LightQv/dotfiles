import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test, { after } from "node:test";
import { fileURLToPath } from "node:url";

const temporaryDirectory = mkdtempSync(join(tmpdir(), "safe-git-test-"));
const repository = join(temporaryDirectory, "repository");
const remote = join(temporaryDirectory, "origin.git");
const script = join(dirname(fileURLToPath(import.meta.url)), "safe-git.mjs");
after(() => rmSync(temporaryDirectory, { recursive: true, force: true }));

function git(cwd, ...args) {
  return execFileSync("git", args, { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).trim();
}

function safe(...args) {
  return spawnSync(process.execPath, [script, ...args], {
    cwd: repository,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
}

git(temporaryDirectory, "init", "--bare", remote);
git(temporaryDirectory, "init", "-b", "main", repository);
git(repository, "config", "user.name", "Test User");
git(repository, "config", "user.email", "test@example.com");
writeFileSync(join(repository, "tracked.txt"), "initial\n");
git(repository, "add", "--", "tracked.txt");
git(repository, "commit", "-m", "Initial commit");
git(repository, "remote", "add", "origin", remote);
git(repository, "push", "-u", "origin", "main");
git(remote, "symbolic-ref", "HEAD", "refs/heads/main");

test("creates only a validated unprotected branch", () => {
  const result = safe("branch", "feature/safe-wrapper");
  assert.equal(result.status, 0, result.stderr);
  assert.equal(git(repository, "branch", "--show-current"), "feature/safe-wrapper");
  assert.notEqual(safe("branch", "main").status, 0);
});

test("commits exact files through a temporary index", () => {
  writeFileSync(join(repository, "tracked.txt"), "changed\n");
  const result = safe("commit", "Safe wrapper commit", "--", "tracked.txt");
  assert.equal(result.status, 0, result.stderr);
  assert.equal(git(repository, "log", "-1", "--pretty=%s"), "Safe wrapper commit");
  assert.equal(git(repository, "status", "--short"), "");
});

test("blocks sensitive paths and executable local Git configuration", () => {
  writeFileSync(join(repository, ".env"), "TOKEN=example\n");
  assert.match(safe("commit", "Blocked", "--", ".env").stderr, /sensitive path is blocked/);

  writeFileSync(join(repository, "tracked.txt"), "changed again\n");
  git(repository, "config", "core.sshCommand", "false");
  assert.match(
    safe("commit", "Blocked config", "--", "tracked.txt").stderr,
    /unsafe repository-local Git configuration/,
  );
  git(repository, "config", "--unset", "core.sshCommand");
});
