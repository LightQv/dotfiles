import assert from "node:assert/strict";
import test from "node:test";

import { isProtectedBranch, parseRemoteBranches, parseRemoteDefault, selectTarget } from "./branch-policy.mjs";

test("develop has first target priority", () => {
  assert.equal(selectTarget(["develop", "main", "master"], "main"), "develop");
});

test("remote main or master default wins when develop is absent", () => {
  assert.equal(selectTarget(["main", "master"], "master"), "master");
  assert.equal(selectTarget(["main", "master"], "main"), "main");
});

test("main then master provide deterministic fallback", () => {
  assert.equal(selectTarget(["release", "main", "master"], "release"), "main");
  assert.equal(selectTarget(["release", "master"], "release"), "master");
});

test("missing supported target fails closed", () => {
  assert.throws(() => selectTarget(["release"], "release"), /no develop, main, or master/);
});

test("develop main master and remote default are protected", () => {
  for (const branch of ["develop", "main", "master", "release"]) {
    assert.equal(isProtectedBranch(branch, "release"), true);
  }
  assert.equal(isProtectedBranch("feature/test", "main"), false);
});

test("parses one live remote default and rejects ambiguity", () => {
  assert.equal(
    parseRemoteDefault("ref: refs/heads/release\tHEAD\n0123456789\tHEAD\n"),
    "release",
  );
  assert.throws(() => parseRemoteDefault("0123456789\tHEAD\n"), /missing or ambiguous/);
  assert.throws(
    () => parseRemoteDefault("ref: refs/heads/main\tHEAD\nref: refs/heads/other\tHEAD\n"),
    /missing or ambiguous/,
  );
});

test("parses live remote branches and rejects malformed output", () => {
  assert.deepEqual(
    parseRemoteBranches("0123456789\trefs/heads/develop\nabcdef0123\trefs/heads/main\n"),
    ["develop", "main"],
  );
  assert.throws(() => parseRemoteBranches("malformed\n"), /listing is malformed/);
});
