#!/usr/bin/env bash
# 給 /mame:commit 呼叫，把一則心得 append 進知識庫（含去重）。
# 用法：add-lesson.sh <project> <key> <tags逗號分隔> <insight> <achieved> [code檔路徑或 -]

set -u

if [ "$#" -lt 5 ]; then
  echo "用法：add-lesson.sh <project> <key> <tags逗號分隔> <insight> <achieved> [code檔路徑或 -]" >&2
  exit 1
fi

project="$1"
key="$2"
tags_csv="$3"
insight="$4"
achieved="$5"
code_arg="${6:--}"

LESSONS_DIR="$HOME/.claude/lessons"
LESSONS="$LESSONS_DIR/lessons.jsonl"
mkdir -p "$LESSONS_DIR"
touch "$LESSONS"

# 去重：同 key + 同 insight 已存在就略過
if jq -e --arg k "$key" --arg i "$insight" \
     'select(.key == $k and .insight == $i)' "$LESSONS" >/dev/null 2>&1; then
  echo "已存在（key=${key}），略過寫入。"
  exit 0
fi

# code：從檔案讀入，'-' 或讀不到則空字串
code=""
if [ "$code_arg" != "-" ] && [ -f "$code_arg" ]; then
  code="$(cat "$code_arg")"
fi

added="$(date +%Y-%m-%d)"

line="$(jq -n -c \
  --arg project "$project" \
  --arg key "$key" \
  --arg tags "$tags_csv" \
  --arg insight "$insight" \
  --arg achieved "$achieved" \
  --arg code "$code" \
  --arg added "$added" \
  '{
     project: $project,
     key: $key,
     tags: ($tags | split(",") | map(select(length > 0)) | map(gsub("^\\s+|\\s+$"; ""))),
     insight: $insight,
     achieved: $achieved,
     code: $code,
     added: $added
   }')"

if [ -z "$line" ]; then
  echo "組 JSON 失敗，未寫入。" >&2
  exit 1
fi

printf '%s\n' "$line" >> "$LESSONS"
echo "已記下心得：key=$key"
exit 0
