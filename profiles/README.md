# profiles directory

This directory stores locally saved OpenClaw OpenAI OAuth snapshots.

Examples:

- `work.auth-profiles.json`
- `personal.auth-profiles.json`
- `team-a.auth-profiles.json`

## Sensitive data warning

These files may contain:

- access token
- refresh token
- account ID
- expiry metadata

So:

- do not publish them
- do not commit them to a public repository
- do not send them to other people

Generate them only on the local machine that owns the login.

Example:

```bash
bash scripts/save-current-as.sh work
```
