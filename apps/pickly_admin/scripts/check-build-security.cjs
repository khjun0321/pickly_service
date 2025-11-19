#!/usr/bin/env node
/**
 * Build Security Checker
 *
 * Scans the build output (dist/) for sensitive keys that should not be exposed.
 * This script runs automatically after `npm run build` via the postbuild hook.
 *
 * Exit codes:
 * - 0: Build is safe (no sensitive keys found)
 * - 1: Build is unsafe (sensitive keys detected)
 */

const fs = require('fs');
const path = require('path');

const DIST_PATH = path.join(__dirname, '..', 'dist');
const SENSITIVE_PATTERNS = [
  /SERVICE_ROLE_KEY/gi,
  /sb_secret_/gi,
  /SUPABASE_SERVICE_ROLE_KEY/gi,
];

console.log('\n🔍 Checking build security...\n');

function scanDirectory(dir) {
  const files = fs.readdirSync(dir);
  const issues = [];

  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      issues.push(...scanDirectory(fullPath));
    } else if (stat.isFile() && (file.endsWith('.js') || file.endsWith('.html'))) {
      const content = fs.readFileSync(fullPath, 'utf8');

      for (const pattern of SENSITIVE_PATTERNS) {
        if (pattern.test(content)) {
          const relativePath = path.relative(DIST_PATH, fullPath);
          issues.push({
            file: relativePath,
            pattern: pattern.source,
          });
        }
      }
    }
  }

  return issues;
}

if (!fs.existsSync(DIST_PATH)) {
  console.error('❌ dist/ directory not found. Did you run `npm run build`?');
  process.exit(1);
}

const issues = scanDirectory(DIST_PATH);

if (issues.length > 0) {
  console.error('🚨 SECURITY ALERT: Sensitive keys found in build!\n');

  issues.forEach(issue => {
    console.error(`   File: ${issue.file}`);
    console.error(`   Pattern: ${issue.pattern}\n`);
  });

  console.error('⚠️  Build contains sensitive keys that should NOT be deployed!');
  console.error('⚠️  Please remove SERVICE_ROLE_KEY from client-side code.\n');

  process.exit(1);
}

console.log('✅ Build is safe: No sensitive keys detected');
console.log('✅ Safe to deploy\n');

process.exit(0);
