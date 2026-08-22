import { execFileSync } from "node:child_process";

import { detectBranchPolicy } from "./branch-policy.mjs";
import { detectOriginForge } from "./detect-forge.mjs";

const mode = process.argv[2];
if (!["find", "create", "copy"].includes(mode) || process.argv.length !== 3) {
  process.stderr.write("Usage: forge-request.mjs <find|create|copy>\n");
  process.exit(2);
}

const cwd = process.cwd();
const env = { ...process.env, GH_PROMPT_DISABLED: "1", GLAB_PROMPT_DISABLED: "1", NO_COLOR: "1" };

function run(file, args) {
  return execFileSync(file, args, {
    cwd,
    env,
    encoding: "utf8",
    maxBuffer: 16 * 1024 * 1024,
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

function git(...args) {
  return run("git", args);
}

function requestContext() {
  const remote = detectOriginForge(cwd);
  const policy = detectBranchPolicy(cwd);
  const branch = policy.current;
  const target = policy.target;
  const title = git("log", "-1", "--pretty=%s");
  if (!branch || policy.isProtected) {
    throw new Error("current branch is empty or protected");
  }
  if (!title || /[\x00-\x1f\x7f]/.test(title)) throw new Error("commit subject is invalid");
  return { ...remote, branch, target, title };
}

function requestUrl(output, context) {
  for (const line of output.split("\n")) {
    try {
      const url = new URL(line.trim());
      const prefix = context.forge === "github"
        ? `/${context.repository}/pull/`
        : `/${context.repository}/-/merge_requests/`;
      if (url.protocol === "https:" && url.hostname === context.host && url.pathname.startsWith(prefix)) {
        return url.href;
      }
    } catch {}
  }
  throw new Error("forge returned no valid request URL");
}

function findRequest(context) {
  if (context.forge === "github") {
    const owner = context.repository.split("/")[0].toLowerCase();
    const requests = JSON.parse(
      run("gh", [
        "pr", "list", "--repo", context.selector, "--head", context.branch, "--base", context.target,
        "--state", "open", "--json", "url,headRepositoryOwner", "--limit", "10",
      ]),
    ).filter((request) => request.headRepositoryOwner?.login?.toLowerCase() === owner);
    if (requests.length > 1) throw new Error("multiple matching GitHub pull requests found");
    return requests[0]?.url ? requestUrl(requests[0].url, context) : "";
  }

  const project = JSON.parse(run("glab", ["repo", "view", context.selector, "--output", "json"]));
  const projectId = project.id;
  if (!Number.isInteger(projectId) && !(typeof projectId === "string" && /^\d+$/.test(projectId))) {
    throw new Error("GitLab returned no valid source project identity");
  }
  const listedRequests = JSON.parse(
    run("glab", [
      "mr", "list", "--repo", context.selector, "--source-branch", context.branch,
      "--target-branch", context.target, "--output", "json",
    ]),
  );
  if (listedRequests.some((request) => request.source_project_id == null && request.sourceProjectId == null)) {
    throw new Error("GitLab returned a request without source project identity");
  }
  const requests = listedRequests.filter(
    (request) => String(request.source_project_id ?? request.sourceProjectId) === String(projectId),
  );
  if (requests.length > 1) throw new Error("multiple matching GitLab merge requests found");
  const url = requests[0]?.web_url ?? requests[0]?.webUrl ?? requests[0]?.url;
  return url ? requestUrl(url, context) : "";
}

function verifyPushed(context) {
  const head = git("rev-parse", "HEAD");
  const remote = git("ls-remote", "--heads", "origin", `refs/heads/${context.branch}`).split(/\s+/)[0];
  if (!remote || remote !== head) throw new Error("remote branch does not match local HEAD");
}

function createRequest(context) {
  verifyPushed(context);
  if (context.forge === "github") {
    return requestUrl(run("gh", [
      "pr", "create", "--repo", context.selector, "--base", context.target, "--head", context.branch,
      "--title", context.title, "--body", "",
    ]), context);
  }
  return requestUrl(run("glab", [
    "mr", "create", "--repo", context.selector, "--source-branch", context.branch,
    "--target-branch", context.target, "--title", context.title, "--description", "",
    "--remove-source-branch", "--yes",
  ]), context);
}

try {
  const context = requestContext();
  let url = findRequest(context);
  let status = url ? "found" : "absent";
  if (!url && mode === "create") {
    try {
      url = createRequest(context);
      status = "created";
    } catch (createError) {
      url = findRequest(context);
      if (!url) throw createError;
      status = "found-after-create-conflict";
    }
  }
  if (mode === "copy") {
    if (!url) throw new Error("no request URL is available to copy");
    execFileSync("pbcopy", [], { input: url, stdio: ["pipe", "ignore", "pipe"] });
    status = "copied";
  }
  process.stdout.write(`${JSON.stringify({ ...context, status, url })}\n`);
} catch (error) {
  process.stderr.write(`Forge request failed: ${error.message}\n`);
  process.exitCode = 1;
}
