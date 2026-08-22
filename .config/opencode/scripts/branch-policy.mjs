import { execFileSync } from "node:child_process";
import { isAbsolute } from "node:path";
import { pathToFileURL } from "node:url";

import { detectOriginForge } from "./detect-forge.mjs";
import { assertSafeLocalGitConfig } from "./git-safety.mjs";

export const PROTECTED_BRANCHES = new Set(["develop", "main", "master"]);

export function selectTarget(remoteBranches, remoteDefault = "") {
  const branches = new Set(remoteBranches);
  if (branches.has("develop")) return "develop";
  if (["main", "master"].includes(remoteDefault) && branches.has(remoteDefault)) return remoteDefault;
  if (branches.has("main")) return "main";
  if (branches.has("master")) return "master";
  throw new Error("origin has no develop, main, or master target branch");
}

export function isProtectedBranch(branch, remoteDefault = "") {
  return PROTECTED_BRANCHES.has(branch) || (remoteDefault && branch === remoteDefault);
}

export function parseRemoteDefault(output) {
  const matches = [...output.matchAll(/^ref: refs\/heads\/([^\s]+)\s+HEAD$/gm)];
  if (matches.length !== 1) throw new Error("origin default branch is missing or ambiguous");
  return matches[0][1];
}

export function parseRemoteBranches(output) {
  const branches = output
    .split("\n")
    .filter(Boolean)
    .map((line) => /^\S+\s+refs\/heads\/(.+)$/.exec(line)?.[1]);
  if (branches.some((branch) => !branch)) throw new Error("origin branch listing is malformed");
  return branches;
}

export function detectBranchPolicy(cwd = process.cwd()) {
  assertSafeLocalGitConfig(cwd);
  const options = {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
  };
  const git = (...args) => execFileSync("git", args, options).trim();

  try {
    detectOriginForge(cwd);
  } catch (error) {
    const localUrls = `${git("remote", "get-url", "--all", "origin")}\n${git("remote", "get-url", "--push", "--all", "origin")}`
      .split("\n")
      .filter(Boolean);
    if (!localUrls.length || localUrls.some((url) => !isAbsolute(url))) throw error;
  }

  const current = git("branch", "--show-current");
  const remoteBranches = parseRemoteBranches(git("ls-remote", "--heads", "origin"));
  const remoteDefault = parseRemoteDefault(git("ls-remote", "--symref", "origin", "HEAD"));

  const target = selectTarget(remoteBranches, remoteDefault);
  return { current, target, remoteDefault, isProtected: isProtectedBranch(current, remoteDefault) };
}

const isMain = process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;
if (isMain) {
  try {
    process.stdout.write(`${JSON.stringify(detectBranchPolicy())}\n`);
  } catch (error) {
    process.stderr.write(`Branch policy failed: ${error.message}\n`);
    process.exitCode = 2;
  }
}
