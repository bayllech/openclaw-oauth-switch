# OpenClaw OpenAI OAuth 多账号管理器

[English README](./README.en.md)

一个用于 **保存、新增、切换、管理多个 OpenAI OAuth 登录身份** 的小型脚本工具集，适用于 OpenClaw。

---

## 项目定位

这个项目适合下面这种场景：

- 你已经在使用 `openclaw models auth login --provider openai-codex`
- 你希望保留多个 OpenAI OAuth 账号快照
- 你希望通过 **简单菜单 + 可重复脚本** 来管理它们
- 你希望这个项目可以安全整理后发布到 GitHub，而不泄露你自己的 token

这不是“两个账号切换脚本”，而是一个 **多账号 profile 管理器**。

---

## 这个项目能做什么

它把当前激活中的 OpenClaw OpenAI OAuth 登录，看作一个可以被保存和切换的快照。

你可以用它来：

1. 保存当前激活账号为一个具名 profile
2. 通过向导式 CLI 流程新增一个全新的 OpenAI 账号
3. 把新登录的账号保存成另一个 profile
4. 在任意数量的已保存 profile 之间切换
5. 切换时可选自动重启 gateway、清理 sessions

例如你可以保留：

- `work`
- `personal`
- `team-a`
- `backup`
- `testing`

任意时刻，当前正在生效的账号依然映射到：

- `openai-codex:default`

这些 profile 快照的意义，是让你能安全、重复地替换这个当前身份。

---

## 安全警告

保存下来的 profile 文件通常包含敏感认证信息，例如：

- access token
- refresh token
- account ID
- 过期时间元数据

所以请务必：

- **不要把真实 `*.auth-profiles.json` 提交到公开仓库**
- **不要把真实账号快照发给别人**
- 公开发布时，只保留脚本、README、脱敏示例

这个仓库默认通过 `.gitignore` 忽略真实 profile 文件。

---

## 默认目标路径

当前脚本默认操作 OpenClaw 主 agent 的认证文件：

- `~/.openclaw/agents/main/agent/auth-profiles.json`

以及 OpenClaw 主配置文件：

- `~/.openclaw/openclaw.json`

如果你的路径不同，可以通过环境变量覆盖：

```bash
OPENCLAW_ROOT=/your/custom/.openclaw bash scripts/show-current.sh
```

---

## 目录结构

```text
openclaw-oauth-switch/
├─ README.md
├─ README.en.md
├─ .gitignore
├─ profiles/
│  ├─ README.md
│  ├─ sample.auth-profiles.json.example
│  └─ .gitignore
├─ backups/                 # 本地生成，git 忽略
├─ state/                   # 本地生成，git 忽略
└─ scripts/
   ├─ lib.sh
   ├─ init-project.sh
   ├─ backup-current.sh
   ├─ save-current-as.sh
   ├─ add-account.sh
   ├─ list-profiles.sh
   ├─ switch-profile.sh
   ├─ show-current.sh
   ├─ prepare-new-login.sh            # 旧版拆分流程，可选
   ├─ save-logged-in-snapshot.sh      # 旧版拆分流程，可选
   └─ menu.sh
```

---

## 快速开始

### 1）初始化项目

```bash
cd /path/to/openclaw-oauth-switch
bash scripts/init-project.sh
```

这个脚本会：

- 创建 `profiles/`、`backups/`、`state/` 目录
- 写入安全的 `.gitignore` 规则
- 检查预期的 OpenClaw 路径是否存在

### 2）保存当前账号

如果 OpenClaw 当前已经登录好了一个账号，可以先保存成 profile：

```bash
bash scripts/save-current-as.sh work
```

这会生成：

```text
profiles/work.auth-profiles.json
```

### 3）推荐使用菜单

```bash
bash scripts/menu.sh
```

对于非技术用户，菜单模式是最推荐的入口。

首次运行时，菜单会要求选择语言：

- English
- 简体中文

这个选择会保存在 `state/settings.json` 中，后续自动沿用。

之后也可以在菜单里手动修改语言。

---

## 核心流程

### A. 保存当前激活账号

```bash
bash scripts/save-current-as.sh my-main-account
```

### B. 一步式新增账号

```bash
bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]
```

例如：

```bash
bash scripts/add-account.sh personal
bash scripts/add-account.sh personal work
```

第二个例子的意思是：

- 先把当前激活账号保存成 `work`
- 再清掉旧的激活 OAuth 状态
- 再启动一次新的 OpenClaw OAuth 登录
- 最后把新登录账号保存成 `personal`

#### 这个向导具体会做什么

运行 `add-account.sh` 时，它会：

1. 可选先把当前激活账号保存成指定名称
2. 备份 `openclaw.json`、`auth-profiles.json` 和 main sessions
3. 停止 gateway
4. 清理 main sessions
5. 从 auth store 中移除当前 `openai-codex:default`
6. 把 `openclaw.json` 恢复成干净的 `openai-codex:default` OAuth 声明
7. 启动 `openclaw models auth login --provider openai-codex`
8. 让你在浏览器里完成登录
9. 让你把最终 localhost 回调链接粘贴回终端
10. 把新认证好的账号保存为具名 profile

这里最重要的一点是：

在开始新登录之前，这个流程会**强制执行 session 清理**和**干净的 `openai-codex:default` 恢复**。

这样可以避免一种很常见的坑：

看起来新账号已经登录成功，但实际运行时仍然沿用了旧账号状态。

#### 仍然需要人工做的步骤

这个向导已经尽量自动化，但仍然保留两个必须人工参与的动作：

1. 打开授权链接，在浏览器中完成登录
2. 把浏览器最终跳转到 localhost 的完整 URL 粘贴回终端

但相比手动记一大串命令，这已经简单很多。

### C. 列出已保存 profile

```bash
bash scripts/list-profiles.sh
```

### D. 查看当前激活状态

```bash
bash scripts/show-current.sh
```

这个状态脚本会对敏感信息做脱敏，只显示 access/refresh token 是否存在，不会直接打印 token。

### E. 切换到某个已保存账号

快速切换：

```bash
bash scripts/switch-profile.sh my-main-account
```

完整切换（大多数情况下更推荐）：

```bash
bash scripts/switch-profile.sh --full my-main-account
```

`--full` 会执行：

- 停止 gateway
- 把选定快照应用到 `openai-codex:default`
- 清理 main-agent sessions
- 重启 gateway

完整切换之后，推荐回到聊天界面发送：

```text
/new
```

这样更不容易粘住旧会话上下文。

---

## 菜单模式

运行：

```bash
bash scripts/menu.sh
```

推荐的小白使用路径：

1. **查看当前激活认证状态**
2. **保存当前账号**
3. **新增账号（向导）**
4. **切换到已保存 profile**
5. **修改语言**（如有需要）

一些不常用的功能，比如：

- 备份底层认证文件
- 兼容旧版拆分登录流程

已经被归到 **高级选项**，避免主菜单对新手太杂。

---

## 实际保存了什么

这个项目只保存切换 OpenAI OAuth 身份所需的最小必要快照：

- `profiles.openai-codex:default`
- `usageStats.openai-codex:default`（如果存在）

它不会故意覆盖其他 provider 的无关条目。

这比直接整份覆盖整个 auth store 更安全。

---

## 命名建议

建议使用简短、直接的名称：

- `work`
- `personal`
- `team-a`
- `backup`
- `plus-account`

避免：

- 空格
- shell 特殊字符
- 很长很绕的名字

允许的字符是：

- letters
- numbers
- dot (`.`)
- underscore (`_`)
- hyphen (`-`)

---

## 常见问题

### `openai-codex:default not found`

这表示当前 auth store 里还没有激活的 OpenAI Codex OAuth 快照。

先试试：

```bash
bash scripts/show-current.sh
```

如果里面确实没有，再先完成一次登录：

```bash
openclaw models auth login --provider openai-codex
```

### 切换完成了，但看起来还是旧状态

建议试试完整流程：

```bash
bash scripts/switch-profile.sh --full <profile-name>
```

然后回到聊天里发送：

```text
/new
```

### 新账号登录成功了，但仍像在使用旧账号

这通常意味着登录前环境没有被彻底清理，或者浏览器复用了旧状态。

建议使用向导流程：

```bash
bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]
```

这个流程会明确执行：

- 清理 main sessions
- 移除旧的 `openai-codex:default`
- 恢复干净 auth 声明

浏览器侧也建议使用：

- 无痕/隐身模式
- 或全新浏览器 profile

### 我想确认当前激活的是哪个账号，但不想把 token 打出来

用这个：

```bash
bash scripts/show-current.sh
```

它会脱敏显示账号标识，并只展示 token 是否存在。

---

## 发布到 GitHub 前的安全检查

在 push 之前，请确认：

1. `profiles/*.auth-profiles.json` 里没有任何真实敏感内容被 track
2. `backups/` 和 `state/` 已被正确忽略
3. 只保留脱敏后的 `profiles/*.example`
4. 再看一遍 `git status`

一个适合公开仓库的结构通常包含：

- `README.md`
- `README.en.md`
- `scripts/*.sh`
- `profiles/*.example`
- `profiles/README.md`
- `.gitignore`

而不应该包含：

- 真实 access tokens
- 真实 refresh tokens
- 真实 account IDs
- 嵌在快照里的个人邮箱

---

## 后续可增强方向

后面如果还要继续打磨，可以考虑：

- 更明确地检测 token 是否过期
- 支持多个 provider，而不只是 `openai-codex`
- 增加导出/导入工具，并带更强的安全提示
- 做一个更清晰的 TUI 界面
- 增加一个 doctor 脚本，用来检查目录布局或环境差异

---

## 使用说明

请自行承担使用风险，这些脚本会直接修改本地 OpenClaw 认证文件。

如果你要公开发布这个项目，建议在仓库里明确提醒用户：

- 切换前先做好备份
- 永远不要公开真实 auth 快照
- 理解浏览器登录 + 粘贴 localhost 回调 URL 仍然是 OAuth 流程的一部分
