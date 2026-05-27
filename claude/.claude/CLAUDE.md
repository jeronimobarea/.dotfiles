# Personal collaboration guide

User: Jeronimo Lucas. Primarily a senior backend engineer working in Go, with some TypeScript on frontends.

## Subagent dispatch rules

When you find yourself about to do open-ended discovery work, prefer dispatching a subagent over doing it inline. The shift saves the main context for synthesis and lets independent investigations run in parallel.

**Dispatch `Explore` when:**
- A task spans ≥2 repos in the orchestration root. Send one parallel `Explore` per repo, each with a focused question.
- You expect to read >5 files to find a single fact, or grep across many directories with uncertain naming.
- The user asks "where is X used / defined / referenced" and the answer requires hunting.

**Dispatch `Plan` when:**
- A change requires committing to a multi-step strategy before any edits.
- The user asks "how should we approach X?" and you'd otherwise write a long inline analysis.

**Dispatch in parallel** (one message, multiple Agent calls) when investigations are independent — don't serialize them.

**Don't dispatch for:**
- A known file path or a single targeted grep.
- Work already orchestrated by a slash command (the skill author chose the right granularity; trust it).
- Trivial questions answered from memory or one tool call.

## Model choice for dispatched agents

Pick the cheapest model that can do the job well. Pass `model` on every `Agent` call — don't let subagents inherit Opus by default for tasks that don't need it.

- **Opus** — orchestration, synthesis, user-facing decisions, ambiguous design judgment, the main conversation thread. Default for the agent the user is talking to.
- **Sonnet** — most code edits, parallel investigations (multi-repo `Explore`), classification/extraction over structured input, MR review passes that don't decide architecture. The default subagent model.
- **Haiku** — trivial lookups, single-file greps, deterministic transforms, anything where a wrong answer is cheap to detect.

Rule of thumb: if the subagent is producing structured output the main agent will validate (a list, a table, a file path), Sonnet is enough. If the subagent is making the final call on something the user will act on directly, use Opus.

This applies to slash commands too — when authoring a skill that dispatches subagents, specify the model explicitly in the skill instructions (see `/address-comments` Step 2 for the pattern).

## Worktrees: default for parallelism

When two units of work could plausibly run in parallel, use a worktree per unit instead of branch-switching. Triggers:

- Reviewing an MR while still implementing on a different branch.
- Two tickets in flight at once.
- Addressing comments on MR A while building MR B.
- Spawning a headless agent (`/spawn-agent`) — always uses its own worktree, never shares the user's working tree.

Pattern: `git worktree add ../$(basename $PWD)-<short-name> -b <branch>`. The `wt` zsh helper wraps this. Clean up with `git worktree remove` once the branch is merged.

When the user asks to start a new task and another is in progress, default to suggesting a worktree rather than `git stash` + branch-switch.

## Working style

- Terse responses preferred. State results and decisions directly; skip running commentary.
- Don't recap the diff in end-of-turn summaries — one or two sentences max.
- Confirmations ("does this plan look good?") are fine for risky actions; not needed for routine edits.
- When in doubt about reversibility or scope, ask first. Once authorized, proceed without re-asking for the same scope.
- **Approved-plan → execution = autonomous.** Once the user approves a plan or implementation approach, do not interrupt for further confirmation on routine steps (lint, test, format, commit, scoped edits, file moves, expected reads). Surface a question only if (a) the implementation runs into a real ambiguity that warrants a plan revision, (b) a destructive or hard-to-reverse action is needed that wasn't covered by the plan, or (c) you discover a constraint that invalidates the plan. The user's mental model is "I approved the plan, ping me when the Draft MR is up."

## Toolchain conventions

- **Go**: gofumpt for formatting, `golangci-lint run` for lint, `go vet ./...` for static checks. Tests run with `go test ./...`.
- **TypeScript**: detect package manager from lockfile; always run `tsc --noEmit` (or the `typecheck` script) — never skip type-checking on TS changes.
- **Git**: never push without explicit ask. Force-push only when user explicitly says so. Commits use Conventional Commits style (`feat(...)`, `fix(...)`).

## Plugin-provided agents and skills

Use these augmentations when the situation matches — they don't auto-trigger.

- **`context7` MCP** — fetch up-to-date library docs by name. Trigger when working with an unfamiliar package or upgrading a dependency: "use context7 to look up `<package>`". Prefer this over training-cutoff knowledge for library APIs.
- **`pr-review-toolkit` agents** — six review subagents callable via the `Agent` tool. Augment `/local-review` and `/mr-review` with one of these when the diff calls for it:
  - `silent-failure-hunter` — error-handling and fallback audit
  - `pr-test-analyzer` — test coverage gaps
  - `type-design-analyzer` — invariants and encapsulation on new types
  - `comment-analyzer` — comment accuracy / rot
  - `code-reviewer` — general CLAUDE.md compliance pass
- **`claude-md-improver` skill / `/revise-claude-md`** — only invoke when explicitly asked to audit or update CLAUDE.md files.

@CLAUDE.thunes.md
