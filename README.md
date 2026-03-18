# OpenClaw OpenAI OAuth 多账号管理器 / OpenClaw OpenAI OAuth Profile Manager

一个用于 **保存、新增、切换、管理多个 OpenAI OAuth 登录身份** 的小型脚本工具集，适用于 OpenClaw。  
A small script toolkit for **saving, adding, switching, and managing multiple OpenAI OAuth logins** used by OpenClaw.

---

## 项目定位 / What this project is

这个项目适合下面这种场景：  
This project is designed for workflows where:

- 你已经在使用 `openclaw models auth login --provider openai-codex`
- 你希望保留多个 OpenAI OAuth 账号快照
- 你希望通过 **简单菜单 + 可重复脚本** 来管理它们
- 你希望这个项目可以安全整理后发布到 GitHub，而不泄露你自己的 token

- you already use `openclaw models auth login --provider openai-codex`
- you want to keep more than one OpenAI OAuth account snapshot
- you want to manage them with a **simple menu + repeatable scripts**
- you want something that can be cleaned up and published to GitHub without leaking your own tokens

这不是“两个账号切换脚本”，而是一个 **多账号 profile 管理器**。  
This is **not** just a “two-account switcher” — it is a **multi-account profile manager**.

---

## 这个项目能做什么 / What this project does

它把当前激活中的 OpenClaw OpenAI OAuth 登录，看作一个可以被保存和切换的快照。  
It treats the currently active OpenClaw OpenAI OAuth login as a snapshot that can be saved and switched.

你可以用它来：  
It helps you:

1. 保存当前激活账号为一个具名 profile  
   Save the current active OpenAI OAuth login as a named profile
2. 通过向导式 CLI 流程新增一个全新的 OpenAI 账号  
   Add a brand-new OpenAI account through a guided CLI flow
3. 把新登录的账号保存成另一个 profile  
   Save that newly logged-in account as another named profile
4. 在任意数量的已保存 profile 之间切换  
   Switch between any number of saved profiles later
5. 切换时可选自动重启 gateway、清理 sessions  
   Optionally restart gateway and clear sessions during switching

例如你可以保留：  
For example, you can keep:

- `work`
- `personal`
- `team-a`
- `backup`
- `testing`

任意时刻，当前正在生效的账号依然映射到：  
At any given moment, the currently active account is still mapped to:

- `openai-codex:default`

这些 profile 快照的意义，是让你能安全、重复地替换这个当前身份。  
The point of these saved snapshots is to let you safely and repeatedly replace that active identity.

---

## 安全警告 / Important security warning

保存下来的 profile 文件通常包含敏感认证信息，例如：  
Saved profile files contain sensitive credentials, typically including:

- access token
- refresh token
- account ID
- token expiry metadata / 过期时间元数据

所以请务必：  
So please:

- **不要把真实 `*.auth-profiles.json` 提交到公开仓库**  
  **never commit real `*.auth-profiles.json` files to a public repository**
- **不要把真实账号快照发给别人**  
  **never share your real snapshots with other people**
- 公开发布时，只保留脚本、README、脱敏示例  
  when publishing publicly, only keep scripts, the README, and redacted examples

这个仓库默认通过 `.gitignore` 忽略真实 profile 文件。  
This repository is structured so real profile files are ignored by Git by default.

---

## 默认目标路径 / Default target paths

当前脚本默认操作 OpenClaw 主 agent 的认证文件：  
Current scripts target the default main-agent auth store used by OpenClaw:

- `~/.openclaw/agents/main/agent/auth-profiles.json`

以及 OpenClaw 主配置文件：  
And the default config file:

- `~/.openclaw/openclaw.json`

如果你的路径不同，可以通过环境变量覆盖：  
If your setup differs, you can override the root path with:

```bash
OPENCLAW_ROOT=/your/custom/.openclaw bash scripts/show-current.sh
```

---

## 目录结构 / Project structure

```text
openclaw-oauth-switch/
├─ README.md
├─ .gitignore
├─ profiles/
│  ├─ README.md
│  ├─ sample.auth-profiles.json.example
│  └─ .gitignore
├─ backups/                 # 本地生成，git 忽略 / generated locally, ignored by git
├─ state/                   # 本地生成，git 忽略 / generated locally, ignored by git
└─ scripts/
   ├─ lib.sh
   ├─ init-project.sh
   ├─ backup-current.sh
   ├─ save-current-as.sh
   ├─ add-account.sh
   ├─ list-profiles.sh
   ├─ switch-profile.sh
   ├─ show-current.sh
   ├─ prepare-new-login.sh            # 旧版拆分流程，可选 / legacy split flow, optional
   ├─ save-logged-in-snapshot.sh      # 旧版拆分流程，可选 / legacy split flow, optional
   └─ menu.sh
```

---

## 快速开始 / Quick start

### 1）初始化项目 / Initialize the project

```bash
cd /path/to/openclaw-oauth-switch
bash scripts/init-project.sh
```

这个脚本会：  
This script will:

- 创建 `profiles/`、`backups/`、`state/` 目录  
  create `profiles/`, `backups/`, and `state/`
- 写入安全的 `.gitignore` 规则  
  install safe `.gitignore` rules
- 检查预期的 OpenClaw 路径是否存在  
  check whether the expected OpenClaw files exist

### 2）保存当前账号 / Save your current account

如果 OpenClaw 当前已经登录好了一个账号，可以先保存成 profile：  
If OpenClaw is already logged in with one OpenAI account, save it as a profile:

```bash
bash scripts/save-current-as.sh work
```

这会生成：  
This creates:

```text
profiles/work.auth-profiles.json
```

### 3）推荐使用菜单 / Use the menu for the easiest path

```bash
bash scripts/menu.sh
```

对于非技术用户，菜单模式是最推荐的入口。  
For non-technical users, the menu is the recommended entry point.

首次运行时，菜单会要求选择语言：  
On first run, the menu asks the user to choose a language:

- English
- 简体中文

这个选择会保存在 `state/settings.json` 中，后续自动沿用。  
That choice is saved locally in `state/settings.json` and reused on later runs.

之后也可以在菜单里手动修改语言。  
You can still change it manually later from the menu.

---

## 核心流程 / Core workflows

### A. 保存当前激活账号 / Save the currently active account

```bash
bash scripts/save-current-as.sh my-main-account
```

### B. 一步式新增账号 / Add a NEW account in one guided flow

```bash
bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]
```

例如：  
Examples:

```bash
bash scripts/add-account.sh personal
bash scripts/add-account.sh personal work
```

第二个例子的意思是：  
The second example means:

- 先把当前激活账号保存成 `work`  
  save the current active account as `work`
- 再清掉旧的激活 OAuth 状态  
  then clear the old active OAuth state
- 再启动一次新的 OpenClaw OAuth 登录  
  then start a fresh OpenClaw OAuth login
- 最后把新登录账号保存成 `personal`  
  then save the newly logged-in account as `personal`

#### 这个向导具体会做什么 / What the guided add-account flow does

运行 `add-account.sh` 时，它会：  
When you run `add-account.sh`, it will:

1. 可选先把当前激活账号保存成指定名称  
   optionally save the current active account under a name you choose
2. 备份 `openclaw.json`、`auth-profiles.json` 和 main sessions  
   back up `openclaw.json`, `auth-profiles.json`, and main sessions
3. 停止 gateway  
   stop gateway
4. 清理 main sessions  
   clear main sessions
5. 从 auth store 中移除当前 `openai-codex:default`  
   remove the current `openai-codex:default` from the auth store
6. 把 `openclaw.json` 恢复成干净的 `openai-codex:default` OAuth 声明  
   restore a clean `openai-codex:default` OAuth declaration in `openclaw.json`
7. 启动 `openclaw models auth login --provider openai-codex`  
   start `openclaw models auth login --provider openai-codex`
8. 让你在浏览器里完成登录  
   let you complete browser login
9. 让你把最终 localhost 回调链接粘贴回终端  
   ask you to paste the final localhost redirect URL back into the terminal
10. 把新认证好的账号保存为具名 profile  
    save the newly authenticated account as a named profile

这里最重要的一点是：  
The most important part is this:

在开始新登录之前，这个流程会**强制执行 session 清理**和**干净的 `openai-codex:default` 恢复**。  
Before starting the new login, the flow deliberately performs **session clearing** and a **clean `openai-codex:default` reset**.

这样可以避免一种很常见的坑：  
That helps avoid a common failure mode:

看起来新账号已经登录成功，但实际运行时仍然沿用了旧账号状态。  
login appears to succeed, but the environment is still effectively using old account state.

#### 仍然需要人工做的步骤 / Manual steps still required

这个向导已经尽量自动化，但仍然保留两个必须人工参与的动作：  
The guided flow is as automated as practical, but two user actions still remain:

1. 打开授权链接，在浏览器中完成登录  
   open the auth URL in a browser and log in
2. 把浏览器最终跳转到 localhost 的完整 URL 粘贴回终端  
   paste the final localhost redirect URL back into the terminal

但相比手动记一大串命令，这已经简单很多。  
That is still much easier than manually remembering all the prep and cleanup commands.

### C. 列出已保存 profile / List saved profiles

```bash
bash scripts/list-profiles.sh
```

### D. 查看当前激活状态 / Show current active auth status

```bash
bash scripts/show-current.sh
```

这个状态脚本会对敏感信息做脱敏，只显示 access/refresh token 是否存在，不会直接打印 token。  
The status view masks sensitive identifiers and only shows whether access/refresh tokens exist, not the raw tokens themselves.

### E. 切换到某个已保存账号 / Switch to a saved account

快速切换：  
Fast switch:

```bash
bash scripts/switch-profile.sh my-main-account
```

完整切换（大多数情况下更推荐）：  
Full switch, recommended in most cases:

```bash
bash scripts/switch-profile.sh --full my-main-account
```

`--full` 会执行：  
`--full` does three things:

- 停止 gateway / stops gateway
- 把选定快照应用到 `openai-codex:default` / applies the selected snapshot to `openai-codex:default`
- 清理 main-agent sessions / clears main-agent sessions
- 重启 gateway / starts gateway again

完整切换之后，推荐回到聊天界面发送：  
After a full switch, it is recommended to go back to chat and send:

```text
/new
```

这样更不容易粘住旧会话上下文。  
That helps avoid stale session context.

---

## 菜单模式 / Menu mode

运行：  
Run:

```bash
bash scripts/menu.sh
```

推荐的小白使用路径：  
Recommended menu usage:

1. **查看当前激活认证状态 / Show current active auth status**
2. **保存当前账号 / Save current account as a profile**
3. **新增账号（向导） / Add a NEW account (guided)**
4. **切换到已保存 profile / Switch to a saved profile**
5. **修改语言 / Change language**（如有需要）

一些不常用的功能，比如：  
Less common actions such as:

- 备份底层认证文件 / low-level backup
- 兼容旧版拆分登录流程 / legacy split-flow resume

已经被归到 **高级选项 / Advanced options**，避免主菜单对新手太杂。  
are grouped under **Advanced options**, so the main menu stays easier for new users.

---

## 实际保存了什么 / What exactly is saved

这个项目只保存切换 OpenAI OAuth 身份所需的最小必要快照：  
This project saves only the minimal snapshot needed for switching the OpenAI OAuth identity:

- `profiles.openai-codex:default`
- `usageStats.openai-codex:default`（如果存在 / if present）

它不会故意覆盖其他 provider 的无关条目。  
It does **not** intentionally overwrite unrelated provider entries when switching.

这比直接整份覆盖整个 auth store 更安全。  
That is safer than replacing the whole auth store file with a broad copy.

---

## 命名建议 / Recommended naming rules

建议使用简短、直接的名称：  
Use short, boring names:

- `work`
- `personal`
- `team-a`
- `backup`
- `plus-account`

避免：  
Avoid:

- 空格 / spaces
- shell 特殊字符 / shell-special characters
- 很长很绕的名字 / very long names

允许的字符是：  
Allowed characters are:

- letters
- numbers
- dot (`.`)
- underscore (`_`)
- hyphen (`-`)

---

## 常见问题 / Troubleshooting

### `openai-codex:default not found`

这表示当前 auth store 里还没有激活的 OpenAI Codex OAuth 快照。  
That means the current auth store does not contain an active OpenAI Codex OAuth snapshot yet.

先试试：  
Try:

```bash
bash scripts/show-current.sh
```

如果里面确实没有，再先完成一次登录：  
If nothing is there, complete a login first:

```bash
openclaw models auth login --provider openai-codex
```

### 切换完成了，但看起来还是旧状态 / Switching finished, but behavior still looks old

建议试试完整流程：  
Try the full flow:

```bash
bash scripts/switch-profile.sh --full <profile-name>
```

然后回到聊天里发送：  
Then go back to chat and send:

```text
/new
```

### 新账号登录成功了，但仍像在使用旧账号 / New login succeeded, but it still seems to use the old account

这通常意味着登录前环境没有被彻底清理，或者浏览器复用了旧状态。  
This usually means the environment was not fully cleaned before login, or the browser reused old state.

建议使用向导流程：  
Use the guided flow:

```bash
bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]
```

这个流程会明确执行：  
That flow explicitly:

- 清理 main sessions / clears main sessions
- 移除旧的 `openai-codex:default` / removes old `openai-codex:default`
- 恢复干净 auth 声明 / restores a clean auth declaration first

浏览器侧也建议使用：  
Also use:

- 无痕/隐身模式 / incognito/private mode
- 或全新浏览器 profile / or a fresh browser profile

### 我想确认当前激活的是哪个账号，但不想把 token 打出来 / I want to see what account is active, but without dumping tokens

用这个：  
Use:

```bash
bash scripts/show-current.sh
```

它会脱敏显示账号标识，并只展示 token 是否存在。  
It masks account identifiers and only shows token presence, not raw token values.

---

## 发布到 GitHub 前的安全检查 / Publishing to GitHub safely

在 push 之前，请确认：  
Before pushing:

1. `profiles/*.auth-profiles.json` 里没有任何真实敏感内容被 track  
   make sure `profiles/*.auth-profiles.json` contains no real secrets in tracked files
2. `backups/` 和 `state/` 已被正确忽略  
   make sure `backups/` and `state/` are ignored
3. 只保留脱敏后的 `profiles/*.example`  
   keep only redacted examples in `profiles/*.example`
4. 再看一遍 `git status`  
   double-check `git status`

一个适合公开仓库的结构通常包含：  
A safe public repo usually contains:

- `README.md`
- `scripts/*.sh`
- `profiles/*.example`
- `profiles/README.md`
- `.gitignore`

而不应该包含：  
And does **not** contain:

- 真实 access tokens / real access tokens
- 真实 refresh tokens / real refresh tokens
- 真实 account IDs / real account IDs
- 嵌在快照里的个人邮箱 / personal email addresses embedded in snapshots

---

## 后续可增强方向 / Suggested future improvements

后面如果还要继续打磨，可以考虑：  
If you want to keep evolving this project, useful next steps would be:

- 更明确地检测 token 是否过期  
  detect token expiry more explicitly
- 支持多个 provider，而不只是 `openai-codex`  
  support multiple providers, not just `openai-codex`
- 增加导出/导入工具，并带更强的安全提示  
  add export/import helpers with extra safety prompts
- 做一个更清晰的 TUI 界面  
  add a TUI with clearer status cards
- 增加一个 doctor 脚本，用来检查目录布局或环境差异  
  add a "doctor" script that checks common path/layout differences

---

## 使用说明 / Usage note

请自行承担使用风险，这些脚本会直接修改本地 OpenClaw 认证文件。  
Use at your own risk. These scripts directly manipulate local OpenClaw auth files.

如果你要公开发布这个项目，建议在仓库里明确提醒用户：  
If you publish this project, make it very clear that users should:

- 切换前先做好备份 / back up before switching
- 永远不要公开真实 auth 快照 / never publish real auth snapshots
- 理解浏览器登录 + 粘贴 localhost 回调 URL 仍然是 OAuth 流程的一部分  
  understand that browser login plus pasting the localhost callback URL is still part of the OAuth flow
