# OpenClaw OpenAI OAuth 多账号管理器

[English README](./README.en.md)

一个给普通用户用的 OpenClaw OpenAI OAuth 多账号切换工具。

它解决的问题很简单：

- 保存当前账号
- 新增一个新账号
- 在多个已保存账号之间切换
- 尽量避免因为旧 session / 旧 `openai-codex:default` 状态残留而串号

---

## 适用场景

如果你已经在用：

```bash
openclaw models auth login --provider openai-codex
```

并且你希望：

- 一台机器保存多个 OpenAI OAuth 账号
- 以后随时切换回某个账号
- 给自己或别人一个尽量傻瓜式的菜单工具

那这个项目就是干这个的。

---

## 功能概览

- 保存当前账号为 profile
- 新增账号（向导式流程）
- 列出已保存 profile
- 切换到某个 profile
- 查看当前激活状态
- 中英文菜单切换

当前生效账号始终使用：

- `openai-codex:default`

已保存账号则放在本地 `profiles/` 目录里。

---

## 快速开始

### 1. 初始化

```bash
cd /path/to/openclaw-oauth-switch
bash scripts/init-project.sh
```

### 2. 打开菜单

```bash
bash scripts/menu.sh
```

首次运行会让你选择语言，之后会自动记住。

---

## 最常用的操作

### 保存当前账号

```bash
bash scripts/save-current-as.sh work
```

这会生成：

```text
profiles/work.auth-profiles.json
```

---

### 新增一个账号

```bash
bash scripts/add-account.sh <新账号名> [当前账号保存名]
```

例如：

```bash
bash scripts/add-account.sh personal work
```

这表示：

1. 先把当前账号保存为 `work`
2. 清理旧状态
3. 启动新的 OAuth 登录
4. 把新登录账号保存为 `personal`

这个流程会自动处理：

- 停 gateway
- 清 main sessions
- 移除旧的 `openai-codex:default`
- 恢复干净的 OAuth 声明
- 启动登录命令
- 让你粘贴 localhost 回调链接
- 保存新账号

你仍然需要人工做两步：

1. 在浏览器里完成登录
2. 把最终 localhost 回调 URL 粘贴回终端

---

### 查看已有账号

```bash
bash scripts/list-profiles.sh
```

---

### 切换账号

快速切换：

```bash
bash scripts/switch-profile.sh work
```

推荐使用完整切换：

```bash
bash scripts/switch-profile.sh --full work
```

`--full` 会：

- 停止 gateway
- 应用 выбран profile 到 `openai-codex:default`
- 清理 main sessions
- 重启 gateway

切换完成后，建议回到聊天里发一次：

```text
/new
```

---

### 查看当前状态

```bash
bash scripts/show-current.sh
```

它会脱敏显示当前状态，不会直接打印 token。

---

## 菜单说明

主菜单面向普通用户，推荐优先用菜单：

```bash
bash scripts/menu.sh
```

常用项：

1. 查看当前激活认证状态
2. 列出已保存 profile
3. 保存当前账号为 profile
4. 新增账号（向导）
5. 切换到已保存 profile
6. 高级选项
7. 修改语言

高级选项里放的是：

- 备份底层认证文件
- 继续旧版兼容流程

如果你只是正常使用，多半用不到高级选项。

---

## 安全提醒

`profiles/*.auth-profiles.json` 里通常包含敏感信息，例如：

- access token
- refresh token
- account ID

所以：

- **不要把真实 profile 文件上传到公开仓库**
- **不要把真实 profile 发给别人**
- GitHub 公开发布时，只保留脚本、README、example 文件

这个仓库默认已经通过 `.gitignore` 忽略真实 profile、`backups/`、`state/`。

---

## 默认文件位置

默认使用这些 OpenClaw 文件：

- `~/.openclaw/agents/main/agent/auth-profiles.json`
- `~/.openclaw/openclaw.json`

如果你的 OpenClaw 根目录不同，可以这样覆盖：

```bash
OPENCLAW_ROOT=/your/custom/.openclaw bash scripts/show-current.sh
```

---

## 发布前自查

在 push 到 GitHub 前，建议确认：

```bash
git status
git ls-files
```

重点看：

- 没有真实 `profiles/*.auth-profiles.json`
- 没有 `backups/`
- 没有 `state/` 里的本地敏感状态
- 没有真实 token、refresh token、邮箱信息

---

## 一句话总结

如果你只想正常使用，记这三个入口就够了：

```bash
bash scripts/menu.sh
bash scripts/add-account.sh <new-name> [current-name]
bash scripts/switch-profile.sh --full <name>
```
