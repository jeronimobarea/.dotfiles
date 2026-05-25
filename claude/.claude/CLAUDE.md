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

## Working style

- Terse responses preferred. State results and decisions directly; skip running commentary.
- Don't recap the diff in end-of-turn summaries — one or two sentences max.
- Confirmations ("does this plan look good?") are fine for risky actions; not needed for routine edits.
- When in doubt about reversibility or scope, ask first. Once authorized, proceed without re-asking for the same scope.

## Toolchain conventions

- **Go**: gofumpt for formatting, `golangci-lint run` for lint, `go vet ./...` for static checks. Tests run with `go test ./...`.
- **TypeScript**: detect package manager from lockfile; always run `tsc --noEmit` (or the `typecheck` script) — never skip type-checking on TS changes.
- **Git**: never push without explicit ask. Force-push only when user explicitly says so. Commits use Conventional Commits style (`feat(...)`, `fix(...)`).

@CLAUDE.thunes.md
