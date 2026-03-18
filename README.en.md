# OpenClaw OpenAI OAuth Profile Manager

[中文说明](./README.md)

A practical multi-account OpenClaw OpenAI OAuth switcher for normal users.

It solves a simple problem:

- save the current account
- add a new account
- switch between saved accounts
- reduce account mix-ups caused by stale sessions or stale `openai-codex:default` state

---

## When this is useful

If you already use:

```bash
openclaw models auth login --provider openai-codex
```

and you want to:

- keep multiple OpenAI OAuth accounts on one machine
- switch back to a saved account later
- give yourself or other people a simpler menu-based tool

this project is for that.

---

## What it can do

- Save the current account as a profile
- Add a new account with a guided flow
- List saved profiles
- Switch to a saved profile
- Show the current active status
- Switch menu language between Chinese and English

The active account always uses:

- `openai-codex:default`

Saved accounts are stored locally in `profiles/`.

---

## Quick start

### 1. Initialize

```bash
cd /path/to/openclaw-oauth-switch
bash scripts/init-project.sh
```

### 2. Open the menu

```bash
bash scripts/menu.sh
```

On first run, the menu asks for a language and remembers it for later.

---

## Most common actions

### Save the current account

```bash
bash scripts/save-current-as.sh work
```

This creates:

```text
profiles/work.auth-profiles.json
```

---

### Add a new account

```bash
bash scripts/add-account.sh <new-name> [current-name-to-save]
```

Example:

```bash
bash scripts/add-account.sh personal work
```

This means:

1. save the current account as `work`
2. clean old state
3. start a fresh OAuth login
4. save the newly logged-in account as `personal`

This guided flow automatically handles:

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

---

### List saved accounts

```bash
bash scripts/list-profiles.sh
```

---

### Switch accounts

Fast switch:

```bash
bash scripts/switch-profile.sh work
```

Recommended full switch:

```bash
bash scripts/switch-profile.sh --full work
```

`--full` will:

- stop gateway
- apply the selected profile to `openai-codex:default`
- clear main sessions
- start gateway again

After switching, it is recommended to send this in chat:

```text
/new
```

---

### Show current status

```bash
bash scripts/show-current.sh
```

It masks sensitive values and does not print raw tokens.

---

## Menu overview

The main menu is designed for normal users:

```bash
bash scripts/menu.sh
```

Common entries:

1. Show current active auth status
2. List saved profiles
3. Save current account as a profile
4. Add a NEW account (guided)
5. Switch to a saved profile
6. Advanced options
7. Change language

Advanced options contain:

- low-level auth backup
- legacy compatibility flow

Most users will not need the advanced menu.

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

---

## One-line summary

If you only want the main entry points, remember these:

```bash
bash scripts/menu.sh
bash scripts/add-account.sh <new-name> [current-name]
bash scripts/switch-profile.sh --full <name>
```
