/**
 * ESLint flat config entry for the VS Code / Cursor ESLint extension when
 * `eslint.options.overrideConfigFile` points here.
 *
 * Picks the nearest `eslint.config.*` walking up from `process.cwd()` (the
 * extension sets cwd from `eslint.workingDirectories`), otherwise loads
 * `eslint.config.mjs` in this directory.
 */
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { pathToFileURL } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

/** Same basename order as ESLint when multiple exist in one folder. */
const CONFIG_BASENAMES = [
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
];

const FALLBACK_CONFIG = join(__dirname, 'eslint.config.mjs');

function findNearestConfigPath(startDir) {
  let dir = startDir;
  for (;;) {
    for (const name of CONFIG_BASENAMES) {
      const abs = join(dir, name);
      if (existsSync(abs)) {
        return abs;
      }
    }
    const parent = dirname(dir);
    if (parent === dir) {
      return null;
    }
    dir = parent;
  }
}

async function unwrapExport(mod) {
  let exp = mod?.default ?? mod;
  if (typeof exp === 'function') {
    exp = exp();
  }
  if (exp && typeof exp.then === 'function') {
    exp = await exp;
  }
  return exp;
}

const cwd = process.cwd();
const nearest = findNearestConfigPath(cwd);
const configPath = nearest ?? FALLBACK_CONFIG;
const mod = await import(pathToFileURL(configPath).href);

export default await unwrapExport(mod);
