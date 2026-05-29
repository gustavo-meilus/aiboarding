# aiboarding Foundation: Plugin Scaffold + Hook Templates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the `aiboarding` Claude Code plugin and build the cross-platform polyglot hook templates (`session-start`, `pre-task`, `post-commit`) that `create-aiboarding` will install into target repos, fully tested against a fixture `AIBOARDING.md`.

**Architecture:** The hooks are deterministic bash scripts invoked through a single polyglot `run-hook.cmd` wrapper (valid in both CMD and bash) so they run on Windows (via Git Bash), macOS, and Linux. Scripts read `AIBOARDING.md` from `${CLAUDE_PROJECT_DIR}`, JSON-escape its content with pure bash, and emit Claude Code `hookSpecificOutput` JSON. This plan builds and unit-tests these templates in isolation; later plans install and consume them.

**Tech Stack:** Claude Code plugin (`.claude-plugin/plugin.json`), bash hook scripts, polyglot `.cmd` wrapper, plain-bash test harness (no `jq`/`bats`/`node` dependency). Requires Git Bash on Windows to run the scripts and tests.

**Specs:** `docs/superpowers/specs/2026-05-29-aiboarding-architecture.md`, `docs/superpowers/specs/2026-05-29-sync-aiboarding-design.md`, `docs/superpowers/specs/2026-05-29-update-aiboarding-design.md`

---

## File Structure

- `.claude-plugin/plugin.json` — plugin manifest (name, version, description).
- `templates/hooks/run-hook.cmd` — polyglot wrapper; dispatches to a named sibling script.
- `templates/hooks/session-start` — emits `AIBOARDING.md` as `SessionStart` context, or a fallback prompt if absent.
- `templates/hooks/pre-task` — emits `AIBOARDING.md` as `PreToolUse` context for spawned sub-agents.
- `templates/hooks/post-commit` — compares frontmatter `last_synced_commit` to `HEAD`; emits a drift nudge if they differ.
- `templates/hooks/_lib` — shared bash: `escape_for_json` + project/doc path resolution. Sourced by the three scripts (DRY).
- `templates/settings/hooks.json` — the `.claude/settings.json` `hooks` snippet that wires the three scripts (installed by `create-aiboarding` later).
- `tests/lib/assert.sh` — tiny assertion helpers (`assert_contains`, `assert_not_contains`, `assert_eq`).
- `tests/fixtures/with-doc/AIBOARDING.md` — fixture project containing a doc with frontmatter.
- `tests/fixtures/no-doc/.gitkeep` — fixture project with no doc.
- `tests/hooks/test-session-start.sh`, `test-pre-task.sh`, `test-post-commit.sh` — per-script tests.
- `tests/run.sh` — runs every `tests/**/test-*.sh` and reports pass/fail.

All hook scripts are **extensionless** so Claude Code's Windows auto-detection does not prepend `bash` to a `.sh` name and break invocation.

---

## Task 1: Plugin scaffold + test harness

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `tests/lib/assert.sh`
- Create: `tests/run.sh`

- [ ] **Step 1: Write the plugin manifest**

Create `.claude-plugin/plugin.json`:

```json
{
  "name": "aiboarding",
  "version": "0.1.0",
  "description": "Treats AI agents as fresh engineers: generates, injects, and keeps current a compressed AIBOARDING.md per repo.",
  "author": { "name": "Gustavo Meilus" }
}
```

- [ ] **Step 2: Write the assertion helpers**

Create `tests/lib/assert.sh`:

```bash
#!/usr/bin/env bash
# Minimal assertion helpers. No external deps.

assert_contains() {
  # assert_contains "<haystack>" "<needle>" "<message>"
  case "$1" in
    *"$2"*) ;;
    *) printf 'FAIL: %s\n  expected to contain: %s\n  got: %s\n' "$3" "$2" "$1"; return 1 ;;
  esac
}

assert_not_contains() {
  case "$1" in
    *"$2"*) printf 'FAIL: %s\n  expected NOT to contain: %s\n  got: %s\n' "$3" "$2" "$1"; return 1 ;;
    *) ;;
  esac
}

assert_eq() {
  if [ "$1" != "$2" ]; then
    printf 'FAIL: %s\n  expected: %s\n  got: %s\n' "$3" "$2" "$1"; return 1
  fi
}
```

- [ ] **Step 3: Write the test runner**

Create `tests/run.sh`:

```bash
#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
for t in "$ROOT"/tests/hooks/test-*.sh; do
  [ -f "$t" ] || continue
  printf '== %s ==\n' "$(basename "$t")"
  if bash "$t"; then
    printf 'PASS\n'
  else
    printf 'FAILED\n'
    fail=1
  fi
done
exit "$fail"
```

- [ ] **Step 4: Run the harness to verify it runs with zero tests**

Run: `bash tests/run.sh`
Expected: exits 0, prints nothing under any `==` header (no test files yet).

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/plugin.json tests/lib/assert.sh tests/run.sh
git commit -m "feat: scaffold aiboarding plugin manifest and bash test harness"
```

---

## Task 2: Shared hook library (`_lib`)

**Files:**
- Create: `templates/hooks/_lib`
- Test: `tests/hooks/test-lib.sh`

- [ ] **Step 1: Write the failing test**

Create `tests/hooks/test-lib.sh`:

```bash
#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
. "$ROOT/templates/hooks/_lib"

# escape_for_json escapes backslash, quote, newline, tab
out="$(escape_for_json "$(printf 'a"b\\c\n\tx')")"
assert_eq "$out" 'a\"b\\c\n\tx' "escape_for_json handles quote/backslash/newline/tab" || exit 1

# resolve_doc_path uses CLAUDE_PROJECT_DIR when set
CLAUDE_PROJECT_DIR="/tmp/proj" resolve_doc_path
assert_eq "$DOC_PATH" "/tmp/proj/AIBOARDING.md" "resolve_doc_path honors CLAUDE_PROJECT_DIR" || exit 1
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/hooks/test-lib.sh`
Expected: FAIL — `_lib` does not exist / functions undefined.

- [ ] **Step 3: Write the shared library**

Create `templates/hooks/_lib`:

```bash
#!/usr/bin/env bash
# Shared helpers for aiboarding hook scripts. Source, do not execute.

# Escape a string for embedding in a JSON string literal, using only bash
# parameter substitution (no sed/awk/jq; safe under Git Bash).
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

# Resolve the AIBOARDING.md path into DOC_PATH and the project dir into PROJECT_DIR.
resolve_doc_path() {
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
  DOC_PATH="${PROJECT_DIR}/AIBOARDING.md"
}

# Read the value of a top-level frontmatter key from a file into REPLY.
# Pure bash; trims surrounding spaces. Stops at the closing '---'.
read_frontmatter() {
  # read_frontmatter <file> <key>
  local file="$1" key="$2" line in_fm=0
  REPLY=""
  [ -f "$file" ] || return 0
  while IFS= read -r line; do
    if [ "$line" = "---" ]; then
      if [ "$in_fm" -eq 0 ]; then in_fm=1; continue; else break; fi
    fi
    case "$line" in
      "${key}:"*)
        REPLY="${line#"${key}:"}"
        REPLY="${REPLY#"${REPLY%%[![:space:]]*}"}"   # ltrim
        REPLY="${REPLY%"${REPLY##*[![:space:]]}"}"   # rtrim
        ;;
    esac
  done < "$file"
}

# Emit a Claude Code hookSpecificOutput JSON object.
# emit_cc_context <hookEventName> <raw-context-string>
emit_cc_context() {
  local event="$1" raw="$2" esc
  esc="$(escape_for_json "$raw")"
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "$event" "$esc"
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/hooks/test-lib.sh`
Expected: PASS (no FAIL lines).

- [ ] **Step 5: Commit**

```bash
git add templates/hooks/_lib tests/hooks/test-lib.sh
git commit -m "feat: add shared hook library (json escape, path + frontmatter helpers)"
```

---

## Task 3: `session-start` hook

**Files:**
- Create: `templates/hooks/session-start`
- Create: `tests/fixtures/with-doc/AIBOARDING.md`
- Create: `tests/fixtures/no-doc/.gitkeep`
- Test: `tests/hooks/test-session-start.sh`

- [ ] **Step 1: Create the fixtures**

Create `tests/fixtures/with-doc/AIBOARDING.md`:

```markdown
---
aiboarding_version: 1
generated: 2026-05-29
last_synced_commit: abc123
---
# 1. Engineering Basics
Node app. Build: npm run build. Test: npm test.

# 2. Domain & Business Logic
Invoicing for freelancers.

# 3. AI-Specific Context
Auth provider is custom; do not assume NextAuth.
```

Create `tests/fixtures/no-doc/.gitkeep` (empty file).

- [ ] **Step 2: Write the failing test**

Create `tests/hooks/test-session-start.sh`:

```bash
#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/session-start"

# With a doc present: output carries the body inside aiboarding-context, as CC JSON.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"SessionStart"' "emits SessionStart event" || exit 1
assert_contains "$out" '<aiboarding-context>' "wraps doc in context tag" || exit 1
assert_contains "$out" 'Invoicing for freelancers.' "includes doc body" || exit 1
assert_contains "$out" 'do not assume NextAuth.' "includes AI-context section" || exit 1

# With no doc: output is the missing-doc fallback prompting create-aiboarding.
out_missing="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/no-doc" bash "$HOOK")"
assert_contains "$out_missing" 'create-aiboarding' "fallback names create-aiboarding" || exit 1
assert_not_contains "$out_missing" '<aiboarding-context>' "no context tag when doc missing" || exit 1
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bash tests/hooks/test-session-start.sh`
Expected: FAIL — `session-start` does not exist.

- [ ] **Step 4: Write the hook**

Create `templates/hooks/session-start`:

```bash
#!/usr/bin/env bash
# aiboarding SessionStart hook: inject AIBOARDING.md into agent context.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/_lib"

resolve_doc_path

if [ -f "$DOC_PATH" ]; then
  raw="$(printf '<aiboarding-context>\n%s\n</aiboarding-context>' "$(cat "$DOC_PATH")")"
else
  raw='<aiboarding-missing>No AIBOARDING.md found in this repo. Offer to run the create-aiboarding skill to generate one.</aiboarding-missing>'
fi

emit_cc_context "SessionStart" "$raw"
exit 0
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bash tests/hooks/test-session-start.sh`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add templates/hooks/session-start tests/fixtures tests/hooks/test-session-start.sh
git commit -m "feat: add session-start hook with doc injection and missing-doc fallback"
```

---

## Task 4: `pre-task` hook

**Files:**
- Create: `templates/hooks/pre-task`
- Test: `tests/hooks/test-pre-task.sh`

- [ ] **Step 1: Write the failing test**

Create `tests/hooks/test-pre-task.sh`:

```bash
#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/pre-task"

# With a doc: emit PreToolUse context carrying the doc.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"PreToolUse"' "emits PreToolUse event" || exit 1
assert_contains "$out" 'Invoicing for freelancers.' "sub-agent receives doc body" || exit 1

# With no doc: no output at all (empty), no fallback.
out_missing="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/no-doc" bash "$HOOK")"
assert_eq "$out_missing" "" "no output when doc missing" || exit 1
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/hooks/test-pre-task.sh`
Expected: FAIL — `pre-task` does not exist.

- [ ] **Step 3: Write the hook**

Create `templates/hooks/pre-task`:

> **Implementation risk (from sync-aiboarding spec):** the exact PreToolUse sub-agent
> injection mechanism is Claude-Code-version-dependent. This script uses
> `hookSpecificOutput.additionalContext`. Before relying on it in production, verify
> against the installed CC version that PreToolUse `additionalContext` reaches the
> spawned `Task` sub-agent; if not, switch to the `updatedInput` mechanism that prepends
> the doc to the `Task` prompt. Tracked as a verification step in Task 6.

```bash
#!/usr/bin/env bash
# aiboarding PreToolUse[Task] hook: give spawned sub-agents the onboarding doc.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/_lib"

resolve_doc_path

# No doc -> nothing to inject; the parent session's SessionStart already handled it.
[ -f "$DOC_PATH" ] || exit 0

raw="$(printf '<aiboarding-context>\n%s\n</aiboarding-context>' "$(cat "$DOC_PATH")")"
emit_cc_context "PreToolUse" "$raw"
exit 0
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/hooks/test-pre-task.sh`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add templates/hooks/pre-task tests/hooks/test-pre-task.sh
git commit -m "feat: add pre-task hook injecting AIBOARDING.md into sub-agents"
```

---

## Task 5: `post-commit` drift hook

**Files:**
- Create: `templates/hooks/post-commit`
- Test: `tests/hooks/test-post-commit.sh`

The hook compares the frontmatter `last_synced_commit` against the repo `HEAD`. The test
builds a throwaway git repo in a temp dir so `git rev-parse HEAD` is deterministic.

- [ ] **Step 1: Write the failing test**

Create `tests/hooks/test-post-commit.sh`:

```bash
#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
HOOK="$ROOT/templates/hooks/post-commit"

# Build a temp git repo with an AIBOARDING.md whose last_synced_commit is stale.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
git -C "$tmp" config user.email t@t.t
git -C "$tmp" config user.name t
printf 'x\n' > "$tmp/file.txt"
git -C "$tmp" add file.txt
git -C "$tmp" commit -q -m one
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: deadbeef\n---\n# 1. Engineering Basics\n' > "$tmp/AIBOARDING.md"

# Stale: last_synced_commit (deadbeef) != HEAD -> drift nudge.
out="$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_contains "$out" '"hookEventName":"PostToolUse"' "emits PostToolUse on drift" || exit 1
assert_contains "$out" 'update-aiboarding' "nudge names update-aiboarding" || exit 1
assert_contains "$out" 'deadbeef..HEAD' "nudge names the commit range" || exit 1

# In sync: set last_synced_commit to real HEAD -> no output.
head="$(git -C "$tmp" rev-parse HEAD)"
printf -- '---\naiboarding_version: 1\ngenerated: 2026-05-29\nlast_synced_commit: %s\n---\n' "$head" > "$tmp/AIBOARDING.md"
out_sync="$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_eq "$out_sync" "" "no output when in sync" || exit 1

# No doc -> no output.
rm "$tmp/AIBOARDING.md"
out_nodoc="$(CLAUDE_PROJECT_DIR="$tmp" bash "$HOOK")"
assert_eq "$out_nodoc" "" "no output when doc missing" || exit 1
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/hooks/test-post-commit.sh`
Expected: FAIL — `post-commit` does not exist.

- [ ] **Step 3: Write the hook**

Create `templates/hooks/post-commit`:

```bash
#!/usr/bin/env bash
# aiboarding PostToolUse[git commit] hook: nudge on drift since last sync.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/_lib"

resolve_doc_path
[ -f "$DOC_PATH" ] || exit 0

read_frontmatter "$DOC_PATH" "last_synced_commit"
last="$REPLY"

head_sha="$(git -C "$PROJECT_DIR" rev-parse HEAD 2>/dev/null || echo "")"
[ -n "$head_sha" ] || exit 0

if [ "$last" != "$head_sha" ]; then
  raw="$(printf '<aiboarding-drift>Commits have landed since AIBOARDING.md was last synced (%s..HEAD). Run the update-aiboarding skill to triage whether the doc needs updating.</aiboarding-drift>' "$last")"
  emit_cc_context "PostToolUse" "$raw"
fi
exit 0
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/hooks/test-post-commit.sh`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add templates/hooks/post-commit tests/hooks/test-post-commit.sh
git commit -m "feat: add post-commit drift hook comparing last_synced_commit to HEAD"
```

---

## Task 6: Polyglot wrapper + settings snippet + full-suite run

**Files:**
- Create: `templates/hooks/run-hook.cmd`
- Create: `templates/settings/hooks.json`
- Test: `tests/hooks/test-run-hook.sh`

- [ ] **Step 1: Write the failing test (Unix dispatch path)**

Create `tests/hooks/test-run-hook.sh`:

```bash
#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/tests/lib/assert.sh"
WRAP="$ROOT/templates/hooks/run-hook.cmd"

# The wrapper, run under bash, should dispatch to the named sibling script.
out="$(CLAUDE_PROJECT_DIR="$ROOT/tests/fixtures/with-doc" bash "$WRAP" session-start)"
assert_contains "$out" '"hookEventName":"SessionStart"' "wrapper dispatches to session-start" || exit 1

# Missing script name -> nonzero exit, message on stderr.
if err="$(bash "$WRAP" 2>&1)"; then
  printf 'FAIL: wrapper should fail with no script name\n'; exit 1
fi
assert_contains "$err" "missing script name" "wrapper reports missing name" || exit 1
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/hooks/test-run-hook.sh`
Expected: FAIL — `run-hook.cmd` does not exist.

- [ ] **Step 3: Write the polyglot wrapper**

Create `templates/hooks/run-hook.cmd` (valid CMD on Windows, valid bash on Unix):

```bat
: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for aiboarding hook scripts.
REM Windows: cmd runs this batch block, finds Git Bash, calls the named script.
REM Unix: bash treats this block as a heredoc no-op and runs the tail below.
REM Usage: run-hook.cmd <script-name> [args...]
if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)
set "HOOK_DIR=%~dp0"
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
REM No bash found - exit silently so the project still works without injection.
exit /b 0
CMDBLOCK

# Unix: run the named script directly.
if [ -z "${1:-}" ]; then
  echo "run-hook.cmd: missing script name" >&2
  exit 1
fi
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/hooks/test-run-hook.sh`
Expected: PASS.

- [ ] **Step 5: Write the settings snippet**

Create `templates/settings/hooks.json` — the `hooks` block `create-aiboarding` will merge into a target repo's `.claude/settings.json`. Paths assume the scripts are installed at `.aiboarding/hooks/`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PROJECT_DIR}/.aiboarding/hooks/run-hook.cmd\" session-start", "async": false }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PROJECT_DIR}/.aiboarding/hooks/run-hook.cmd\" pre-task", "async": false }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_PROJECT_DIR}/.aiboarding/hooks/run-hook.cmd\" post-commit", "async": false }
        ]
      }
    ]
  }
}
```

> Note: the `PostToolUse` matcher is `Bash` (the tool name). The `post-commit` script itself
> is cheap and self-gates (no doc, or no drift → exits silently), so matching all Bash calls
> is acceptable. A tighter command-substring match is a later optimization, not needed now.

- [ ] **Step 6: Run the FULL suite**

Run: `bash tests/run.sh`
Expected: every `test-*.sh` prints `PASS`; runner exits 0.

- [ ] **Step 7: Verify the PreToolUse injection mechanism (manual, documented)**

This resolves the implementation risk flagged in Task 4. In a scratch repo with the hooks
installed and an `AIBOARDING.md` present, spawn a sub-agent via the `Task` tool and confirm
the sub-agent's context contains the `<aiboarding-context>` block.
- If it does: leave `pre-task` on `additionalContext`.
- If it does NOT: change `pre-task` to return `updatedInput` that prepends the doc to the
  `Task` prompt, and update `tests/hooks/test-pre-task.sh` accordingly.
Record the observed CC version and the outcome in a comment at the top of `templates/hooks/pre-task`.

- [ ] **Step 8: Commit**

```bash
git add templates/hooks/run-hook.cmd templates/settings/hooks.json tests/hooks/test-run-hook.sh templates/hooks/pre-task
git commit -m "feat: add polyglot run-hook wrapper, settings snippet; verify PreToolUse injection"
```

---

## Self-Review

**Spec coverage:**
- sync-aiboarding `SessionStart(startup|clear|compact)` injection + missing-doc fallback → Task 3 + settings snippet (Task 6). ✓
- sync-aiboarding `PreToolUse[Task]` sub-agent injection + version risk → Task 4 + Task 6 Step 7. ✓
- sync-aiboarding polyglot wrapper, extensionless names, graceful Windows degradation, pure-bash JSON escape → Task 6 + Task 2. ✓
- update-aiboarding `PostToolUse[git commit]` drift nudge comparing `last_synced_commit` to HEAD, silent when in-sync/absent → Task 5. ✓
- umbrella frontmatter schema (`last_synced_commit`) read path → Task 2 `read_frontmatter`. ✓
- Plugin packaging (`.claude-plugin/plugin.json`) → Task 1. ✓
- **Out of scope here (later plans):** generating the doc, the triage reasoning, and the Phase 6 installer that *copies* these templates + merges the settings snippet into target repos.

**Placeholder scan:** No TBD/TODO; every code step contains full content. The two "Note"/"risk" callouts describe verification steps with concrete actions, not deferred implementation.

**Type/name consistency:** `escape_for_json`, `resolve_doc_path` (sets `PROJECT_DIR`/`DOC_PATH`), `read_frontmatter` (sets `REPLY`), and `emit_cc_context <event> <raw>` are defined once in Task 2 `_lib` and called with those exact signatures in Tasks 3–5. Script names (`session-start`, `pre-task`, `post-commit`, `run-hook.cmd`) match between the settings snippet, the wrapper dispatch test, and the files created.
