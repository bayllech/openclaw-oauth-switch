# OpenClaw OpenAI OAuth Profile Manager

[中文说明](./README.md)

A practical multi-account OpenClaw OpenAI OAuth switcher for normal users.

---

## Start here: use the menu first

Most users **do not need to remember commands**. Just run:

```bash
bash scripts/menu.sh
```

The menu already covers the main actions:

1. Show current active auth status
2. List saved profiles
3. Save current account as a profile
4. Add a NEW account (guided)
5. Switch to a saved profile
6. Advanced options
7. Change language

### Best way to use it

If you are just using the tool normally, these are the main things you need:

- **Save current account**: save the current login state under a name like `work`
- **Add a NEW account (guided)**: log in to a new account and save it as another profile
- **Switch to a saved profile**: switch back to a previously saved account
- **Show current status**: confirm which account state is active now

On first run, the menu asks for a language and remembers it for later.

---

## Most common scenarios

### Scenario 1: save the current account first

```bash
bash scripts/save-current-as.sh work
```

This creates:

```text
profiles/work.auth-profiles.json
```

If you do not want to remember commands, you can also just choose:

- `Save current account as a profile`

inside `menu.sh`.

---

### Scenario 2: add a new account

The recommended way is to use the menu:

```bash
bash scripts/menu.sh
```

Then choose:

- `Add a NEW account (guided)`

This flow automatically handles:

- stopping gateway
- clearing main sessions
- removing old `openai-codex:default`
- restoring a clean OAuth declaration
- starting the login command
- asking you to paste the localhost callback URL
- saving the new account

You still need to do two manual steps:

1. finish the login in a browser
2. paste the final localhost callback URL back into the terminal

If you prefer direct CLI, you can run:

```bash
bash scripts/add-account.sh <new-name> [current-name-to-save]
```

Example:

```bash
bash scripts/add-account.sh personal work
```

---

### Scenario 3: switch back to a saved account

Recommended way:

```bash
bash scripts/menu.sh
```

Then choose:

- `Switch to a saved profile`

If you want direct CLI switching:

```bash
bash scripts/switch-profile.sh --full work
```

After switching, it is recommended to send this in chat:

```text
/new
```

---

## What this project is for

It solves a simple problem:

- save the current account
- add a new account
- switch between saved accounts
- reduce account mix-ups caused by stale sessions or stale `openai-codex:default` state

The active account always uses:

- `openai-codex:default`

Saved accounts are stored locally in `profiles/`.

---

## Quick command reference

### Open the menu

```bash
bash scripts/menu.sh
```

### List saved profiles

```bash
bash scripts/list-profiles.sh
```

### Show current status

```bash
bash scripts/show-current.sh
```

### Save current account

```bash
bash scripts/save-current-as.sh <name>
```

### Add a new account

```bash
bash scripts/add-account.sh <new-name> [current-name]
```

### Switch account

```bash
bash scripts/switch-profile.sh --full <name>
```

---

## Security reminder

`profiles/*.auth-profiles.json` usually contains sensitive data such as:

- access token
- refresh token
- account ID

So:

- **do not upload real profile files to a public repository**
- **do not send real profile files to other people**
- for public GitHub release, keep only scripts, README files, and example files

This repo already ignores real profiles, `backups/`, and `state/` by default.

---

## Default file locations

By default, the scripts use these OpenClaw files:

- `~/.openclaw/agents/main/agent/auth-profiles.json`
- `~/.openclaw/openclaw.json`

If your OpenClaw root is different, override it like this:

```bash
OPENCLAW_ROOT=/your/custom/.openclaw bash scripts/show-current.sh
```

---

## Before publishing to GitHub

Before pushing, check:

```bash
git status
git ls-files
```

Make sure you are not publishing:

- real `profiles/*.auth-profiles.json`
- `backups/`
- local sensitive `state/` data
- real tokens, refresh tokens, or email addresses
