#!/usr/bin/env bash
# Best-effort silent refresh of AWS SSO tokens.
# Runs `aws sso login` non-interactively. If the cached token is still valid,
# this is a no-op. If it has fully expired, this will fail silently — the
# user has to log in interactively (the launchd agent doesn't have a browser).

set -euo pipefail

PROFILE="${1:-aws-claude-code}"

for prefix in /opt/homebrew /usr/local "$HOME/.local"; do
  if [[ -x "$prefix/bin/aws" ]]; then
    AWS_BIN="$prefix/bin/aws"
    break
  fi
done

if [[ -z "${AWS_BIN:-}" ]]; then
  echo "aws CLI not found" >&2
  exit 0
fi

# Probe first; if already valid, do nothing.
if "$AWS_BIN" sts get-caller-identity --profile "$PROFILE" >/dev/null 2>&1; then
  exit 0
fi

# Token invalid. We can't open a browser from launchd, so just log and exit.
# The user will see the warning from their precmd hook.
echo "$(date -Iseconds) SSO expired for profile $PROFILE; user must run claude-login" >&2
exit 0
