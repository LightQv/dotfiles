import { execFileSync } from "node:child_process";

const unsafeLocalConfig = /^(?:branch\..*\.pushremote|core\.(?:askpass|attributesfile|fsmonitor|hookspath|pager|sshcommand)|credential\.|diff\.(?:external|.*\.command)|filter\.|gpg\.|http\.|include\.|includeif\.|merge\..*\.driver|pager\.|protocol\.|push\.|remote\.(?:pushdefault|.*\.push|origin\.(?:receivepack|uploadpack))|url\.|commit\.gpgsign|tag\.gpgsign)/i;

export function assertSafeLocalGitConfig(cwd = process.cwd()) {
  let names = "";
  try {
    names = execFileSync("git", ["config", "--local", "--name-only", "--get-regexp", ".*"], {
      cwd,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    }).trim();
  } catch (error) {
    if (error.status !== 1) throw new Error("repository-local Git configuration is unreadable");
  }
  const unsafe = names.split("\n").filter(Boolean).find((name) => unsafeLocalConfig.test(name));
  if (unsafe) throw new Error(`unsafe repository-local Git configuration: ${unsafe}`);
}
