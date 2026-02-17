# Bug Fix Workflow

Usage: `/fix <bug_description>`

Orchestrates a 3-agent pipeline to locate, fix, and verify a bug. The fixer is
constrained to edit only the exact file and line identified by the analyzer.

---

## Step 0: Context (mandatory)

Read `.ai/context-map.md` if it exists in the project.
Output: `[AUDIT_LOG] LOADED_CONTEXT_MAP: {N} files indexed.`

---

## Step 1: Analyze

Use the Task tool with `subagent_type: code-analyzer`.

Prompt:
```
Analyze the codebase to find the root cause of this bug: $ARGUMENTS

Return your findings in this exact format:

FILE: <relative file path>
LINE: <line number>
CAUSE: <one sentence describing what is wrong at that location>
FIX_HINT: <one sentence describing what the correct behavior should be>

If you cannot identify a single specific file and line, say:
FILE: UNKNOWN
LINE: UNKNOWN
CAUSE: <what you found instead>
FIX_HINT: <what information is still needed to locate the bug>
```

Store the full output as **ANALYSIS**.

---

## Step 2: Gate check

Read the ANALYSIS output from Step 1.

- If `FILE: UNKNOWN` — stop and tell Gil:
  > "The analyzer could not pinpoint a specific location. Here is what it found:
  > {CAUSE}
  > To proceed, please provide more context about where the bug occurs."
  Do NOT proceed to Step 3.

- If FILE and LINE are identified — continue to Step 3.

---

## Step 3: Fix

Use the Task tool with `subagent_type: general-purpose`.

Prompt:
```
You are a Developer fixing a specific bug. You have been given the exact location
of the bug by a code analyzer. You MUST follow the constraints below without exception.

Bug description: $ARGUMENTS

Code analyzer findings:
{ANALYSIS}

CONSTRAINTS — follow these exactly:
1. Edit ONLY the file identified in FILE above.
2. Edit ONLY at or near the line number identified in LINE above.
3. Do NOT refactor, rename, or reorganize any other code.
4. Do NOT touch any file other than the one in FILE.
5. Make the minimal change required to fix the described bug.
6. If the fix requires changes in more than one file to be correct, STOP and report back
   to the user: "This fix requires changes in multiple files: [list them]. Please confirm
   before I proceed." Do not make any edits until confirmed.

After making the fix, briefly state:
- What you changed (one sentence)
- Why that change fixes the bug (one sentence)
```

---

## Step 4: Verify

Use the Task tool with `subagent_type: test-runner`.

Prompt:
```
A bug fix was just applied for: $ARGUMENTS

Run the relevant tests to verify the fix is correct. Focus on tests that exercise
the area of code that was changed.

If no tests exist or none are relevant, respond with:
"No tests found for this area. The fix is UNVERIFIED. Recommend adding a test
that covers: $ARGUMENTS"
```

---

## Step 5: Report to Gil

Present a final summary:

```
## Fix Complete

**Bug**: $ARGUMENTS

**Root cause**: {CAUSE from ANALYSIS}
**File changed**: {FILE}:{LINE}
**What changed**: {developer's one-sentence summary}

**Verification**: {pass/fail/unverified + test summary}
```

If tests failed, add:
> "Tests did not pass after the fix. The developer's change may be incomplete. Here is the failure: {test output}"
> Do not close the task — ask Gil how to proceed.
