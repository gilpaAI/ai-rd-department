# AI Context Protocol

## 1. The Map

Every project repository MUST have a live architectural map at `.ai/context-map.md`, generated and maintained by `ai-cartographer`.

### Setup (run once per project repo)
```bash
# Install as dev dependency
npm install -D ai-cartographer

# Generate the initial map
npx ai-cartographer init

# Install git hooks for auto-refresh
npx ai-cartographer hooks install
```

The map is committed to the repo (not gitignored). The cache (`.ai/.cache/`) is gitignored.

## 2. Mandatory Access Logging

**Rule:** At the start of every development session, or when confused about codebase structure, you MUST read `.ai/context-map.md`.

**Rule:** IMMEDIATELY after reading the map, output this exact log line:
```
[AUDIT_LOG] LOADED_CONTEXT_MAP: {number_of_files} files indexed.
```

Extract the file count from the map header (the line that says "N files indexed").

## 3. Navigation Protocol

- **DO** use the context map to locate files before making changes
- **DO NOT** run `find`, `ls -R`, or blind directory exploration
- **DO** read only the specific files you need (identified via the map)
- **DO** reference the map when uncertain about where logic lives

## 4. Staleness Check

If the map header timestamp is older than 24 hours or the session involves significant file changes:
```bash
npx ai-cartographer status
```

If stale:
```bash
npx ai-cartographer refresh
```

## 5. Compliance Verification

An agent is compliant if:
1. It reads `.ai/context-map.md` before exploring the codebase
2. It emits the `[AUDIT_LOG] LOADED_CONTEXT_MAP` line
3. It navigates directly to target files without blind searching

An agent is non-compliant if:
- It runs `find` or `ls -R` to orient itself
- It reads random files to "understand the project"
- It skips the audit log after reading the map
