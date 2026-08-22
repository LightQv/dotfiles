import { readdirSync } from "node:fs";
import { join, resolve } from "node:path";

const root = resolve(process.cwd());
const ignored = new Set([".git", "node_modules", ".venv", "venv", "vendor", "dist", "build"]);
const repositories = [];

function walk(directory, depth) {
  let entries;
  try {
    entries = readdirSync(directory, { withFileTypes: true });
  } catch {
    return;
  }
  if (entries.some((entry) => entry.name === ".git" && (entry.isDirectory() || entry.isFile()))) {
    repositories.push(directory);
  }
  if (depth === 4) return;
  for (const entry of entries) {
    if (!entry.isDirectory() || entry.isSymbolicLink() || ignored.has(entry.name)) continue;
    walk(join(directory, entry.name), depth + 1);
  }
}

walk(root, 0);
process.stdout.write(`${JSON.stringify([...new Set(repositories)].sort())}\n`);
