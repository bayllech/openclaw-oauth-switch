# OpenClaw OpenAI OAuth Profile Manager

[中文说明](./README.md)

A small script toolkit for **saving, adding, switching, and managing multiple OpenAI OAuth logins** used by OpenClaw.

---

## What this project is

This project is designed for workflows where:

- you already use `openclaw models auth login --provider openai-codex`
- you want to keep more than one OpenAI OAuth account snapshot
- you want to manage them with a **simple menu + repeatable scripts**
- you want something that can be cleaned up and published to GitHub without leaking your own tokens

This is **not** just a “two-account switcher” — it is a **multi-account profile manager**.

---

## What this project does

It treats the currently active OpenClaw OpenAI OAuth login as a snapshot that can be saved and switched.

It helps you:

1. Save the current active OpenAI OAuth login as a named profile
2. Add a brand-new OpenAI account through a guided CLI flow
3. Save that newly logged-in account as another named profile
4. Switch between any number of saved profiles later
5. Optionally restart gateway and clear sessions during switching

For example, you can keep:

- `work`
- `personal`
- `team-a`
- `backup`
- `testing`

At any given moment, the currently active account is still mapped to:

- `openai-codex:default`

The point of these saved snapshots is to let you safely and repeatedly replace that active identity.

---

## Important security warning

Saved profile files usually contain sensitive credentials, such as:

- access token
- refresh token
- account ID
- token expiry metadata

So please:

- **never commit real `*.auth-profiles.json` files to a public repository**
- **never share your real snapshots with other people**
- when publishing publicly, only keep scripts, the README files, and redacted examples

This repository is structured so real profile files are ignored by Git by default.

---

## Default target paths

Current scripts target the default main-agent auth store used by OpenClaw:

- `~/.openclaw/agents/main/agent/auth-profiles.json`

And the default config file:

- `~/.openclaw/openclaw.json`

If your setup differs, you can override the root path with:

```bash
OPENCLAW_ROOT=/your/custom/.openclaw bash scripts/show-current.sh
```

---

## Project structure

```text
openclaw-oauth-switch/
├─ README.md
├─ README.en.md
├─ .gitignore
├─ profiles/
│  ├─ README.md
│  ├─ sample.auth-profiles.json.example
│  └─ .gitignore
├─ backups/                 # generated locally, ignored by git
├─ state/                   # generated locally, ignored by git
└─ scripts/
   ├─ lib.sh
   ├─ init-project.sh
   ├─ backup-current.sh
   ├─ save-current-as.sh
   ├─ add-account.sh
   ├─ list-profiles.sh
   ├─ switch-profile.sh
   ├─ show-current.sh
   ├─ prepare-new-login.sh            # legacy split flow, optional
   ├─ save-logged-in-snapshot.sh      # legacy split flow, optional
   └─ menu.sh
```

---

## Quick start

### 1) Initialize the project

```bash
cd /path/to/openclaw-oauth-switch
bash scripts/init-project.sh
```

This script will:

- create `profiles/`, `backups/`, and `state/`
- install safe `.gitignore` rules
- check whether the expected OpenClaw files exist

### 2) Save your current account

If OpenClaw is already logged in with one OpenAI account, save it as a profile:

```bash
bash scripts/save-current-as.sh work
```

This creates:

```text
profiles/work.auth-profiles.json
```

### 3) Use the menu for the easiest path

```bash
bash scripts/menu.sh
```

For non-technical users, the menu is the recommended entry point.

On first run, the menu asks the user to choose a language:

- English
- 简体中文

That choice is saved locally in `state/settings.json` and reused on later runs.

You can still change it manually later from the menu.

---

## Core workflows

### A. Save the currently active account

```bash
bash scripts/save-current-as.sh my-main-account
```

### B. Add a NEW account in one guided flow

```bash
bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]
```

Examples:

```bash
bash scripts/add-account.sh personal
bash scripts/add-account.sh personal work
```

The second example means:

- save the current active account as `work`
- clear the old active OAuth state
- start a fresh OpenClaw OAuth login
- save the newly logged-in account as `personal`

#### What the guided add-account flow does

When you run `add-account.sh`, it will:

1. optionally save the current active account under a name you choose
2. back up `openclaw.json`, `auth-profiles.json`, and main sessions
3. stop gateway
4. clear main sessions
5. remove the current `openai-codex:default` from the auth store
6. restore a clean `openai-codex:default` OAuth declaration in `openclaw.json`
7. start `openclaw models auth login --provider openai-codex`
8. let you complete browser login
9. ask you to paste the final localhost redirect URL back into the terminal
10. save the newly authenticated account as a named profile

The important part is this:

Before starting the new login, the flow deliberately performs **session clearing** and a **clean `openai-codex:default` reset**.

That helps avoid a common failure mode:

Login appears to succeed, but the environment is still effectively using old account state.

#### Manual steps still required

The guided flow is as automated as practical, but two user actions still remain:

1. open the auth URL in a browser and log in
2. paste the final localhost redirect URL back into the terminal

That is still much easier than manually remembering the full prep and cleanup workflow.

### C. List saved profiles

```bash
bash scripts/list-profiles.sh
```

### D. Show current active auth status

```bash
bash scripts/show-current.sh
```

The status view masks sensitive identifiers and only shows whether access/refresh tokens exist, not the raw tokens themselves.

### E. Switch to a saved account

Fast switch:

```bash
bash scripts/switch-profile.sh my-main-account
```

Full switch, recommended in most cases:

```bash
bash scripts/switch-profile.sh --full my-main-account
```

`--full` does the following:

- stops gateway
- applies the selected snapshot to `openai-codex:default`
- clears main-agent sessions
- starts gateway again

After a full switch, it is recommended to go back to chat and send:

```text
/new
```

That helps avoid stale session context.

---

## Menu mode

Run:

```bash
bash scripts/menu.sh
```

Recommended menu usage:

1. **Show current active auth status**
2. **Save current account as a profile**
3. **Add a NEW account (guided)**
4. **Switch to a saved profile**
5. **Change language** if needed

Less common actions such as:

- low-level auth backup
- legacy split-flow resume

are grouped under **Advanced options**, so the main menu stays easier for new users.

---

## What exactly is saved

This project saves only the minimal snapshot needed for switching the OpenAI OAuth identity:

- `profiles.openai-codex:default`
- `usageStats.openai-codex:default` (if present)

It does **not** intentionally overwrite unrelated provider entries when switching.

That is safer than replacing the whole auth store file with a broad copy.

---

## Recommended naming rules

Use short, boring names:

- `work`
- `personal`
- `team-a`
- `backup`
- `plus-account`

Avoid:

- spaces
- shell-special characters
- very long names

Allowed characters are:

- letters
- numbers
- dot (`.`)
- underscore (`_`)
- hyphen (`-`)

---

## Troubleshooting

### `openai-codex:default not found`

That means the current auth store does not contain an active OpenAI Codex OAuth snapshot yet.

Try:

```bash
bash scripts/show-current.sh
```

If nothing is there, complete a login first:

```bash
openclaw models auth login --provider openai-codex
```

### Switching finished, but behavior still looks old

Try the full flow:

```bash
bash scripts/switch-profile.sh --full <profile-name>
```

Then go back to chat and send:

```text
/new
```

### New login succeeded, but it still seems to use the old account

This usually means the environment was not fully cleaned before login, or the browser reused old state.

Use the guided flow:

```bash
bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]
```

That flow explicitly:

- clears main sessions
- removes old `openai-codex:default`
- restores a clean auth declaration first

Also use:

- incognito/private mode
- or a fresh browser profile

### I want to see what account is active, but without dumping tokens

Use:

```bash
bash scripts/show-current.sh
```

It masks account identifiers and only shows token presence, not raw token values.

---

## Publishing to GitHub safely

Before pushing:

1. make sure `profiles/*.auth-profiles.json` contains no real secrets in tracked files
2. make sure `backups/` and `state/` are ignored
3. keep only redacted examples in `profiles/*.example`
4. double-check `git status`

A safe public repo usually contains:

- `README.md`
- `README.en.md`
- `scripts/*.sh`
- `profiles/*.example`
- `profiles/README.md`
- `.gitignore`

And does **not** contain:

- real access tokens
- real refresh tokens
- real account IDs
- personal email addresses embedded in snapshots

---

## Suggested future improvements

If you want to keep evolving this project, useful next steps would be:

- detect token expiry more explicitly
- support multiple providers, not just `openai-codex`
- add export/import helpers with extra safety prompts
- add a clearer TUI
- add a "doctor" script that checks common path/layout differences

---

## Usage note

Use at your own risk. These scripts directly manipulate local OpenClaw auth files.

If you publish this project, make it very clear that users should:

- back up before switching
- never publish real auth snapshots
- understand that browser login plus pasting the localhost callback URL is still part of the OAuth flow
