import assert from "node:assert/strict";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test, { after } from "node:test";

import { loadForgeHosts, matchRemoteUrls, parseRemoteUrl } from "./detect-forge.mjs";

const temporaryDirectory = mkdtempSync(join(tmpdir(), "detect-forge-"));
after(() => rmSync(temporaryDirectory, { recursive: true, force: true }));

function overlay(name, contents) {
  const filePath = join(temporaryDirectory, name);
  writeFileSync(filePath, contents);
  return filePath;
}

test("detects GitHub HTTPS remotes", () => {
  assert.deepEqual(parseRemoteUrl("https://github.com/owner/repo.git"), {
    forge: "github",
    host: "github.com",
    repository: "owner/repo",
    selector: "github.com/owner/repo",
  });
});

test("detects GitHub SCP-style SSH remotes", () => {
  assert.equal(parseRemoteUrl("git@github.com:owner/repo.git").forge, "github");
});

test("detects nested repositories on a configured GitLab host", () => {
  const hosts = loadForgeHosts(overlay("private.json", '{"gitlab.internal.example":"gitlab"}\n'));
  assert.deepEqual(parseRemoteUrl("ssh://git@gitlab.internal.example/group/subgroup/repo.git", hosts), {
    forge: "gitlab",
    host: "gitlab.internal.example",
    repository: "group/subgroup/repo",
    selector: "https://gitlab.internal.example/group/subgroup/repo",
  });
});

test("detects GitLab.com remotes", () => {
  assert.equal(parseRemoteUrl("https://gitlab.com/group/repo").forge, "gitlab");
});

test("rejects malformed local forge configuration", () => {
  assert.throws(() => loadForgeHosts(overlay("malformed.json", "{")), /malformed/);
  assert.throws(() => loadForgeHosts(overlay("array.json", "[]")), /must be an object/);
});

test("rejects invalid hosts and forge types", () => {
  assert.throws(
    () => loadForgeHosts(overlay("invalid-host.json", '{"-invalid.example":"gitlab"}')),
    /invalid local forge host/,
  );
  assert.throws(
    () => loadForgeHosts(overlay("invalid-forge.json", '{"forge.example":"other"}')),
    /unsupported local forge type/,
  );
});

test("rejects attempts to override built-in hosts", () => {
  assert.throws(
    () => loadForgeHosts(overlay("override.json", '{"github.com":"gitlab"}')),
    /conflicts with built-in host/,
  );
});

test("accepts a missing local forge configuration", () => {
  assert.equal(loadForgeHosts(join(temporaryDirectory, "missing.json")).get("github.com"), "github");
});

test("rejects unknown hosts without probing them", () => {
  assert.throws(() => parseRemoteUrl("git@example.com:owner/repo.git"), /unsupported forge host/);
});

test("rejects SSH aliases because their forge is ambiguous", () => {
  assert.throws(() => parseRemoteUrl("git@github-work:owner/repo.git"), /unsupported forge host/);
});

test("rejects malformed and local remotes", () => {
  assert.throws(() => parseRemoteUrl("../repo"), /supported network URL/);
  assert.throws(() => parseRemoteUrl("https://github.com/owner"), /invalid github repository path/);
  assert.throws(() => parseRemoteUrl("https://github.com/owner/repo%2Fother"), /unsupported characters/);
  assert.throws(() => parseRemoteUrl("http://github.com/owner/repo"), /unsupported origin protocol/);
  assert.throws(() => parseRemoteUrl("git://github.com/owner/repo"), /unsupported origin protocol/);
  assert.throws(() => parseRemoteUrl("https://user@github.com/owner/repo"), /HTTPS credentials/);
  assert.throws(() => parseRemoteUrl("ssh://git@github.com:2222/owner/repo"), /unexpected port/);
  assert.throws(() => parseRemoteUrl("ssh://user:secret@github.com/owner/repo"), /password/);
  assert.throws(() => parseRemoteUrl("user@github.com:owner/repo"), /SSH username must be git/);
});

test("requires fetch and push URLs to identify the same repository", () => {
  assert.equal(
    matchRemoteUrls(["git@github.com:owner/repo.git", "https://github.com/owner/repo.git"]).forge,
    "github",
  );
  assert.throws(
    () => matchRemoteUrls(["git@github.com:owner/repo.git", "git@github.com:owner/other.git"]),
    /do not resolve to one repository/,
  );
});
