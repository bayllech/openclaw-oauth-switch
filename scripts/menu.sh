#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_dirs
LANG_CHOICE=""

pause() {
  echo
  if [[ "$LANG_CHOICE" == "zh-CN" ]]; then
    read -r -p "按回车继续..." _
  else
    read -r -p "Press Enter to continue..." _
  fi
}

save_language() {
  local lang="$1"
  node_json "$SETTINGS_FILE" "$lang" <<'EOF'
const fs = require('fs');
const [path, lang] = process.argv.slice(2);
const data = {
  version: 1,
  language: lang,
  updatedAt: new Date().toISOString()
};
fs.writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
EOF
}

load_language() {
  if [[ -f "$SETTINGS_FILE" ]]; then
    LANG_CHOICE="$(node_json "$SETTINGS_FILE" <<'EOF'
const fs = require('fs');
const [path] = process.argv.slice(2);
try {
  const obj = JSON.parse(fs.readFileSync(path, 'utf8'));
  process.stdout.write(obj.language || '');
} catch {}
EOF
)"
  fi
}

choose_language() {
  while true; do
    echo "=========================================="
    echo " Select Language / 选择语言"
    echo "=========================================="
    echo "1) English"
    echo "2) 简体中文"
    echo
    read -r -p "Choose / 请选择 [1/2]: " choice
    case "$choice" in
      1)
        LANG_CHOICE="en"
        save_language "$LANG_CHOICE"
        return
        ;;
      2)
        LANG_CHOICE="zh-CN"
        save_language "$LANG_CHOICE"
        return
        ;;
      *)
        echo "Invalid choice / 无效选项"
        echo
        ;;
    esac
  done
}

t() {
  local key="$1"
  case "$LANG_CHOICE:$key" in
    zh-CN:header_title) echo "OpenClaw OpenAI OAuth 多账号管理器" ;;
    zh-CN:project) echo "项目目录" ;;
    zh-CN:no_profiles) echo "[INFO] 暂无已保存 profile。" ;;
    zh-CN:warn_name_empty) echo "[WARN] 名称不能为空。" ;;
    zh-CN:save_profile_prompt) echo "请输入要保存的 profile 名称：" ;;
    zh-CN:new_profile_prompt) echo "请输入要新增的账号 profile 名称：" ;;
    zh-CN:save_current_as_prompt) echo "可选：当前激活账号要先保存成什么名称？（留空则跳过）" ;;
    zh-CN:guided_flow_intro) echo "这个向导流程将会：" ;;
    zh-CN:flow_line_1) echo "- 可选先保存当前账号快照" ;;
    zh-CN:flow_line_2) echo "- 备份 config/auth/session 文件" ;;
    zh-CN:flow_line_3) echo "- 停止 gateway" ;;
    zh-CN:flow_line_4) echo "- 清理 main agent sessions" ;;
    zh-CN:flow_line_5) echo "- 移除当前 openai-codex:default" ;;
    zh-CN:flow_line_6) echo "- 恢复干净的 openai-codex:default OAuth 声明" ;;
    zh-CN:flow_line_7) echo "- 运行：openclaw models auth login --provider openai-codex" ;;
    zh-CN:flow_line_8) echo "- 让你粘贴 localhost 回调链接" ;;
    zh-CN:flow_line_9_prefix) echo "- 把新登录账号保存为：" ;;
    zh-CN:confirm_real) echo "确认执行真实流程？(y/N): " ;;
    zh-CN:cancelled) echo "[INFO] 已取消。" ;;
    zh-CN:no_legacy_state) echo "[INFO] 没有待继续的旧版登录向导状态。" ;;
    zh-CN:legacy_hint_1) echo "当前默认是一步式流程：" ;;
    zh-CN:legacy_hint_2) echo "或者使用菜单项：新增账号（向导）" ;;
    zh-CN:legacy_pending) echo "待继续的旧版向导状态：" ;;
    zh-CN:save_now_prompt) echo "请输入现在要保存的新 profile 名称：" ;;
    zh-CN:choose_profile_num) echo "请输入要切换的 profile 编号：" ;;
    zh-CN:error_number) echo "[ERROR] 请输入数字。" ;;
    zh-CN:error_out_of_range) echo "[ERROR] 编号超出范围。" ;;
    zh-CN:switch_target) echo "切换目标" ;;
    zh-CN:modes) echo "模式：" ;;
    zh-CN:mode_fast) echo "  1) 快速：只替换当前激活的 OpenAI OAuth 快照" ;;
    zh-CN:mode_full) echo "  2) 完整：停/启 gateway + 清 session + 替换快照" ;;
    zh-CN:choose_mode) echo "请选择模式 [1/2，默认 2]: " ;;
    zh-CN:confirm_continue) echo "确认继续？(y/N): " ;;
    zh-CN:menu_1) echo "1) 查看当前激活认证状态" ;;
    zh-CN:menu_2) echo "2) 列出已保存 profile" ;;
    zh-CN:menu_3) echo "3) 保存当前账号为 profile" ;;
    zh-CN:menu_4) echo "4) 新增账号（向导）" ;;
    zh-CN:menu_5) echo "5) 切换到已保存 profile" ;;
    zh-CN:menu_6) echo "6) 高级选项" ;;
    zh-CN:menu_7) echo "7) 修改语言 / Change language" ;;
    zh-CN:menu_0) echo "0) 退出" ;;
    zh-CN:choose_action) echo "请选择操作：" ;;
    zh-CN:bye) echo "已退出。" ;;
    zh-CN:invalid_choice) echo "[WARN] 无效选项。" ;;
    zh-CN:advanced_title) echo "高级选项" ;;
    zh-CN:advanced_1) echo "1) 备份底层认证文件（排错/保险用）" ;;
    zh-CN:advanced_2) echo "2) 继续旧版浏览器登录流程（兼容旧流程）" ;;
    zh-CN:advanced_0) echo "0) 返回主菜单" ;;
    zh-CN:advanced_choose) echo "请选择高级操作：" ;;
    en:header_title) echo "OpenClaw OpenAI OAuth Profile Manager" ;;
    en:project) echo "Project" ;;
    en:no_profiles) echo "[INFO] No saved profiles yet." ;;
    en:warn_name_empty) echo "[WARN] Name cannot be empty." ;;
    en:save_profile_prompt) echo "Enter the profile name to save: " ;;
    en:new_profile_prompt) echo "Enter the NEW profile name to create: " ;;
    en:save_current_as_prompt) echo "Optionally save the CURRENT active account as which name? (leave blank to skip): " ;;
    en:guided_flow_intro) echo "This guided flow will:" ;;
    en:flow_line_1) echo "- optionally save the current account snapshot" ;;
    en:flow_line_2) echo "- back up config/auth/session files" ;;
    en:flow_line_3) echo "- stop gateway" ;;
    en:flow_line_4) echo "- clear main agent sessions" ;;
    en:flow_line_5) echo "- remove current openai-codex:default" ;;
    en:flow_line_6) echo "- restore a clean openai-codex:default OAuth declaration" ;;
    en:flow_line_7) echo "- run: openclaw models auth login --provider openai-codex" ;;
    en:flow_line_8) echo "- ask you to paste the localhost redirect URL" ;;
    en:flow_line_9_prefix) echo "- save the newly logged-in account as: " ;;
    en:confirm_real) echo "Continue with real execution? (y/N): " ;;
    en:cancelled) echo "[INFO] Cancelled." ;;
    en:no_legacy_state) echo "[INFO] No pending login wizard state found." ;;
    en:legacy_hint_1) echo "The default flow is now one-shot:" ;;
    en:legacy_hint_2) echo "Or use menu option: Add a NEW account" ;;
    en:legacy_pending) echo "Pending legacy wizard state:" ;;
    en:save_now_prompt) echo "Enter the new profile name to save now: " ;;
    en:choose_profile_num) echo "Enter the profile number to switch to: " ;;
    en:error_number) echo "[ERROR] Please enter a number." ;;
    en:error_out_of_range) echo "[ERROR] Number out of range." ;;
    en:switch_target) echo "Switch target" ;;
    en:modes) echo "Modes:" ;;
    en:mode_fast) echo "  1) Fast: only replace active OpenAI OAuth snapshot" ;;
    en:mode_full) echo "  2) Full: stop/start gateway + clear sessions + replace snapshot" ;;
    en:choose_mode) echo "Choose mode [1/2, default 2]: " ;;
    en:confirm_continue) echo "Continue? (y/N): " ;;
    en:menu_1) echo "1) Show current active auth status" ;;
    en:menu_2) echo "2) List saved profiles" ;;
    en:menu_3) echo "3) Save current account as a profile" ;;
    en:menu_4) echo "4) Add a NEW account (guided)" ;;
    en:menu_5) echo "5) Switch to a saved profile" ;;
    en:menu_6) echo "6) Advanced options" ;;
    en:menu_7) echo "7) Change language / 修改语言" ;;
    en:menu_0) echo "0) Exit" ;;
    en:choose_action) echo "Choose an action: " ;;
    en:bye) echo "Bye." ;;
    en:invalid_choice) echo "[WARN] Invalid choice." ;;
    en:advanced_title) echo "Advanced options" ;;
    en:advanced_1) echo "1) Back up low-level auth files (for rollback/debug)" ;;
    en:advanced_2) echo "2) Resume legacy browser-login flow (compatibility)" ;;
    en:advanced_0) echo "0) Back to main menu" ;;
    en:advanced_choose) echo "Choose an advanced action: " ;;
    *) echo "$key" ;;
  esac
}

show_header() {
  echo "=========================================="
  echo " $(t header_title)"
  echo "=========================================="
  echo "$(t project): $PROJECT_DIR"
  echo
}

load_profile_files() {
  mapfile -t PROFILE_FILES < <(find "$PROFILE_DIR" -maxdepth 1 -type f -name '*.auth-profiles.json' | sort)
}

list_profiles_numbered() {
  load_profile_files
  if [[ ${#PROFILE_FILES[@]} -eq 0 ]]; then
    echo "$(t no_profiles)"
    return 1
  fi

  local i=1
  for file in "${PROFILE_FILES[@]}"; do
    local base
    base="$(basename "$file")"
    echo "  $i) ${base%.auth-profiles.json}"
    ((i++))
  done
  return 0
}

save_current_profile() {
  echo
  read -r -p "$(t save_profile_prompt)" name
  [[ -n "${name:-}" ]] || { echo "$(t warn_name_empty)"; pause; return; }
  bash "$SCRIPT_DIR/save-current-as.sh" "$name"
  pause
}

add_new_account() {
  echo
  read -r -p "$(t new_profile_prompt)" new_name
  [[ -n "${new_name:-}" ]] || { echo "$(t warn_name_empty)"; pause; return; }
  read -r -p "$(t save_current_as_prompt)" current_name
  echo
  echo "$(t guided_flow_intro)"
  echo "$(t flow_line_1)"
  echo "$(t flow_line_2)"
  echo "$(t flow_line_3)"
  echo "$(t flow_line_4)"
  echo "$(t flow_line_5)"
  echo "$(t flow_line_6)"
  echo "$(t flow_line_7)"
  echo "$(t flow_line_8)"
  echo "$(t flow_line_9_prefix)$new_name"
  echo
  read -r -p "$(t confirm_real)" confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    if [[ -n "$current_name" ]]; then
      bash "$SCRIPT_DIR/add-account.sh" "$new_name" "$current_name"
    else
      bash "$SCRIPT_DIR/add-account.sh" "$new_name"
    fi
  else
    echo "$(t cancelled)"
  fi
  pause
}

resume_after_browser_login() {
  echo
  if [[ ! -f "$WIZARD_STATE_FILE" ]]; then
    echo "$(t no_legacy_state)"
    echo "       $(t legacy_hint_1)"
    echo "       bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]"
    echo "       $(t legacy_hint_2)"
    pause
    return
  fi

  echo "$(t legacy_pending)"
  cat "$WIZARD_STATE_FILE"
  echo
  read -r -p "$(t save_now_prompt)" name
  [[ -n "${name:-}" ]] || { echo "$(t warn_name_empty)"; pause; return; }
  bash "$SCRIPT_DIR/save-logged-in-snapshot.sh" "$name"
  pause
}

switch_profile_by_number() {
  echo
  if ! list_profiles_numbered; then
    pause
    return
  fi
  echo
  read -r -p "$(t choose_profile_num)" num
  if [[ ! "$num" =~ ^[0-9]+$ ]]; then
    echo "$(t error_number)"
    pause
    return
  fi
  if (( num < 1 || num > ${#PROFILE_FILES[@]} )); then
    echo "$(t error_out_of_range)"
    pause
    return
  fi

  local file base name
  file="${PROFILE_FILES[$((num-1))]}"
  base="$(basename "$file")"
  name="${base%.auth-profiles.json}"

  echo
  echo "$(t switch_target): $name"
  echo "$(t modes)"
  echo "$(t mode_fast)"
  echo "$(t mode_full)"
  read -r -p "$(t choose_mode)" mode
  mode="${mode:-2}"
  read -r -p "$(t confirm_continue)" confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    if [[ "$mode" == "1" ]]; then
      bash "$SCRIPT_DIR/switch-profile.sh" "$name"
    else
      bash "$SCRIPT_DIR/switch-profile.sh" --full "$name"
    fi
  else
    echo "$(t cancelled)"
  fi
  pause
}

change_language() {
  echo
  choose_language
}

advanced_menu() {
  while true; do
    echo
    echo "=========================================="
    echo " $(t advanced_title)"
    echo "=========================================="
    echo "$(t advanced_1)"
    echo "$(t advanced_2)"
    echo "$(t advanced_0)"
    echo
    read -r -p "$(t advanced_choose)" choice
    case "$choice" in
      1)
        echo
        bash "$SCRIPT_DIR/backup-current.sh"
        pause
        ;;
      2)
        resume_after_browser_login
        ;;
      0)
        return
        ;;
      *)
        echo
        echo "$(t invalid_choice)"
        pause
        ;;
    esac
  done
}

main_menu() {
  load_language
  if [[ "$LANG_CHOICE" != "en" && "$LANG_CHOICE" != "zh-CN" ]]; then
    choose_language
  fi

  while true; do
    if [[ -t 1 && -n "${TERM:-}" ]]; then
      clear || true
    fi
    show_header
    echo "$(t menu_1)"
    echo "$(t menu_2)"
    echo "$(t menu_3)"
    echo "$(t menu_4)"
    echo "$(t menu_5)"
    echo "$(t menu_6)"
    echo "$(t menu_7)"
    echo "$(t menu_0)"
    echo
    read -r -p "$(t choose_action)" choice
    case "$choice" in
      1)
        echo
        bash "$SCRIPT_DIR/show-current.sh"
        pause
        ;;
      2)
        echo
        list_profiles_numbered || true
        pause
        ;;
      3)
        save_current_profile
        ;;
      4)
        add_new_account
        ;;
      5)
        switch_profile_by_number
        ;;
      6)
        advanced_menu
        ;;
      7)
        change_language
        ;;
      0)
        echo "$(t bye)"
        exit 0
        ;;
      *)
        echo
        echo "$(t invalid_choice)"
        pause
        ;;
    esac
  done
}

main_menu
