---
name: sync-with-main
description: Sync the current feature branch with the latest main/master via rebase, auto-resolving trivial conflicts and pausing on substantive ones with full context. Re-runs unit tests after. Trigger when the user types `/sync-with-main`, `/rebase`, or asks to "rebase on main", "sync with master", "pull in main into my branch".
---

# Sync with main

Rebases the current branch onto the latest `main`/`master`, resolving trivial conflicts automatically and pausing on substantive ones with enough context to make a good call.

## Usage

```
/sync-with-main
/sync-with-main <base-ref>      # explicit base (e.g. origin/develop)
```

Run from inside the repo and on the branch you want to sync.

## Inputs

- **Repo**: current dir must be a git repo. If running from the orchestration root, ask which repo's branch you want synced.
- **Base ref** (optional): defaults to `origin/main` if it exists, else `origin/master`. Verify with `git -C <repo> rev-parse --verify <base>`. Ask if neither is found.

## Workflow

### Step 1 — Pre-flight

1. Ensure `pwd` is inside a git repo. If not, stop.
2. **Refuse to run if there are uncommitted changes.** Show `git status --short` and stop. Do NOT auto-stash unless the user explicitly says so — stash bugs are easy to introduce and hard to recover from. If the user wants to stash, they can do `git stash && /sync-with-main && git stash pop`.
3. Refuse to run on `main` or `master` itself — there's nothing to rebase. Tell the user.
4. Identify the current branch: `git rev-parse --abbrev-ref HEAD`.
5. Resolve the base ref (default or argument). Run `git fetch origin <main-or-master>` so the comparison is fresh.
6. Find the merge base: `git merge-base HEAD <base>`. Show the user:
   - Current branch + tip SHA
   - Base ref + tip SHA
   - How far behind base the branch is (`git rev-list --count HEAD..<base>`)
   - How many commits the branch has on top of base (`git rev-list --count <base>..HEAD`)
   - Whether the branch's commits are still all `CO-XXXX <type>: ...` formatted (warn if any aren't — rebasing won't fix non-conforming commits)
7. **Confirm before rebasing.** "I'll rebase `<branch>` (N commits) onto `<base>`. Proceed?" Wait for explicit approval.

### Step 2 — Rebase

8. Run `git rebase <base>`. Capture the exit code and output.
9. **If the rebase succeeds cleanly**, jump to Step 4.
10. **If it stops on a conflict**, do NOT auto-continue. Move to Step 3.

### Step 3 — Conflict handling (loop)

For each conflict that appears (one rebase step at a time):

11. Identify conflicted files: `git diff --name-only --diff-filter=U`.

12. **Classify each conflict** — auto-resolvable vs substantive:
    - **Auto-resolvable** (no user prompt needed; resolve and move on):
      - **Lockfiles**: `go.sum`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `cpanfile.snapshot`. Take the version from base (`git checkout --theirs <file>` mid-rebase, where `--theirs` is the *base* during a rebase) and regenerate from `go.mod` / `package.json` / `cpanfile`. After regenerating, run `git add` on the file. If regeneration fails, escalate to substantive.
      - **Pure import-order conflicts** (Go `import (...)` blocks where both sides only added imports without changing logic): merge the union and run `goimports -w` if available.
      - **Pure formatting conflicts** (whitespace, trailing newline, gofmt-only differences): take the base side and re-run the formatter (`gofmt -w`, `prettier --write`, etc.).
      - **Generated files** (`*.pb.go`, mock files, OpenAPI types): take the base side and re-run the generator (`make generate`, `make proto`). If the user's changes need to be re-applied to the proto/IDL source instead, escalate.

      For every auto-resolution, log the file + the heuristic used in a running list. Show this list at the end so the user can audit.

    - **Substantive** (everything else): pause and follow the prompt format below.

13. **Substantive conflict prompt**: for each substantive conflict, present:

    ```
    ## Conflict in `path/to/file.ext`

    ### What main changed (commit <sha> by <author>: <subject>)
    <diff hunk from <merge-base>..<base> for the conflicting region — 5–15 lines>

    ### What this branch changed (commit <sha>: <subject>)
    <diff hunk from <merge-base>..HEAD for the conflicting region — 5–15 lines>

    ### Conflict markers
    ```
    <<<<<<< HEAD
    <branch's version, since `git rebase` shows the rebased commit as HEAD>
    =======
    <main's version>
    >>>>>>> <base>
    ```

    ### Recommended resolution
    <one of: "take HEAD", "take base", "merge both — keep <X> from HEAD plus <Y> from base", "needs manual judgement">
    <1–3 sentences on why>

    ### Options
    1. Apply recommendation
    2. Take HEAD (this branch)
    3. Take base (main)
    4. I'll resolve manually — pause until I say continue
    5. Abort the rebase entirely (`git rebase --abort`)
    ```

    Wait for the user's choice. After applying, `git add` the file and confirm there are no more conflicts before continuing.

14. Once all conflicts in the current step are resolved, run `git rebase --continue`. Loop back to step 11 if more conflicts surface.

15. **Hard exit conditions**:
    - User picks option 5 (abort): run `git rebase --abort`, confirm the working tree is back to its pre-rebase state, stop.
    - More than ~5 substantive conflicts in a row: stop and ask the user whether to continue, abort, or take a break. Long rebases get error-prone fast.
    - Any operation that would touch files outside the conflict set: stop. Don't drift.

### Step 4 — Verify

16. Once the rebase completes (no more conflicts), run the repo's unit tests + lint:
    - Go services: `make unit && make lint && go build ./...`
    - `admin-interface-ui`: `yarn test --watch=false` (verify the right command in the repo's `package.json`)
    - `common-lib`, `admin-interface` (Perl): `make test`
    - If unsure, ask before running.

17. **If tests pass**, report success and stop. The branch is rebased on `<base>` and verified.

18. **If tests fail**, do NOT auto-fix. Report:
    - Which tests failed.
    - Whether the failures look related to the rebase (touched files appear in the failing tests' coverage area) or unrelated.
    - The list of auto-resolutions from Step 3 — failures often trace back to a heuristic that picked the wrong side.
    - Recommend the user inspect, fix, and either continue or `git reflog` back if the rebase needs redoing.

### Step 5 — Force-push? (don't)

19. **Never push automatically after a rebase.** Pushing a rebased branch requires `--force-with-lease`, which overwrites the upstream history of the branch. Even though it's the user's own branch, this is destructive enough to keep manual.
20. Report the final state and tell the user: "Rebase complete. To push, run `git push --force-with-lease`. Don't use plain `--force`."

## Guardrails

- **Never `git push --force` or `--force-with-lease`** from this skill.
- **Never auto-stash.** If the user has dirty state, stop.
- **Never run on `main` / `master`.** There's nothing to rebase.
- **Don't combine rebasing with other operations** (squashing, fixup, branch renaming). One thing at a time. If the user asks for an interactive rebase, that's a different skill.
- **Don't classify a conflict as trivial unless it really is.** When in doubt, treat as substantive. False auto-resolves are silent bugs; false substantive prompts are mild annoyance.
- **Honour the auto-resolve audit log.** The user must be able to see every change the skill made on its own.
- **Never edit `.git/` internals.** All operations go through `git` commands.

## Notes

- Rebasing changes commit SHAs. Any open MR on the branch will need a force-push (manual) to update; comments on inline diffs against the old SHAs may become detached. This is a GitLab quirk, not something this skill can fix.
- If the branch has already been rebased and pushed once, sequential rebases compound the force-push requirement. That's fine — just keep using `--force-with-lease`.
- The auto-resolve list for trivial conflicts is intentionally narrow. Adding more heuristics (say, "always take HEAD for test files") sounds attractive but tends to mask real conflicts. Keep it boring.
