#!/usr/bin/env bash
# mame statusLine: 印一行 base，忙超過門檻時多印兩行豆知識。
# 刻意不用 set -e：statusLine 腳本一旦 exit 非零或無輸出整條就會變空白。

# 進階使用者選用：指向某支既有 statusLine 腳本。預設空字串 → 走自組 base 行。
# 也可用環境變數 MAME_STATUSLINE_BASE_CMD 覆寫（環境變數優先）。
BASE_CMD="${MAME_STATUSLINE_BASE_CMD:-}"

# 以下都可用對應的環境變數覆寫（沒設就用預設值）。
THRESHOLD="${MAME_STATUSLINE_THRESHOLD:-120}"           # 忙超過幾秒才顯示豆知識
ROTATE="${MAME_STATUSLINE_ROTATE:-30}"                  # 每幾秒輪播一則
LESSONS="${MAME_STATUSLINE_LESSONS:-$HOME/.claude/lessons/lessons.jsonl}"

# ANSI 色碼（格式字串裡寫死，使用者文字一律走 %s）
DIM=$'\033[2;37m'
CYAN=$'\033[36m'
RESET=$'\033[0m'

input="$(cat)"

# ---- base 行 ----
if [ -n "$BASE_CMD" ] && [ -f "$BASE_CMD" ]; then
  # 用 $(...) 包起來再補換行，避免對方腳本結尾沒換行造成黏行
  printf '%s\n' "$(printf '%s' "$input" | sh "$BASE_CMD")"
else
  model="$(printf '%s' "$input" | jq -r '.model.display_name // "?"' 2>/dev/null)"
  [ -z "$model" ] && model="?"
  cwd="$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)"
  [ -z "$cwd" ] && cwd="$PWD"
  ctx="$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)"
  if [ "$ctx" = "1000000" ]; then
    model="$model (1M context)"
  fi
  printf '%s@%s:%s [%s]\n' "$(whoami)" "$(hostname -s)" "$cwd" "$model"
fi

# ---- 是否顯示豆知識 ----
session_id="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
[ -z "$session_id" ] && exit 0

flag="/tmp/cc-lesson-busy-${session_id}"
[ -f "$flag" ] || exit 0

start="$(cat "$flag" 2>/dev/null)"
case "$start" in
  ''|*[!0-9]*) exit 0 ;;   # 內容不是純數字就略過
esac

now="$(date +%s)"
elapsed=$(( now - start ))
[ "$elapsed" -lt "$THRESHOLD" ] && exit 0

# ---- 挑一則 ----
[ -f "$LESSONS" ] || exit 0
count="$(jq -s 'length' "$LESSONS" 2>/dev/null)"
case "$count" in
  ''|*[!0-9]*) exit 0 ;;
esac
[ "$count" -gt 0 ] || exit 0

index=$(( (now / ROTATE) % count ))
line="$(jq -s -c ".[$index]" "$LESSONS" 2>/dev/null)"
[ -z "$line" ] && exit 0

insight="$(printf '%s' "$line" | jq -r '.insight // empty' 2>/dev/null)"
key="$(printf '%s' "$line" | jq -r '.key // empty' 2>/dev/null)"
[ -z "$insight" ] && exit 0

printf "${DIM}你知道嗎，%s${RESET}\n" "$insight"
[ -n "$key" ] && printf "${CYAN}/mame:learn %s${RESET}\n" "$key"

exit 0
