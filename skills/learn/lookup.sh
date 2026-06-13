#!/usr/bin/env bash
# 純查表，不動模型。用法：lookup.sh <keyword>
# 也可當 alias：alias lesson='bash <plugin>/skills/learn/lookup.sh'

set -u

LESSONS="$HOME/.claude/lessons/lessons.jsonl"

if [ "$#" -lt 1 ] || [ -z "${1:-}" ]; then
  echo "用法：lookup.sh <關鍵字>" >&2
  exit 1
fi
keyword="$1"

if [ ! -f "$LESSONS" ]; then
  echo "找不到知識庫：$LESSONS"
  echo "可先執行：mkdir -p ~/.claude/lessons && touch ~/.claude/lessons/lessons.jsonl"
  exit 0
fi

# key / insight / tags 任一含關鍵字（不分大小寫）即命中
matches="$(jq -s -c --arg kw "$keyword" '
  ($kw | ascii_downcase) as $q |
  map(select(
    ((.key // "") | ascii_downcase | contains($q)) or
    ((.insight // "") | ascii_downcase | contains($q)) or
    (((.tags // []) | map(ascii_downcase) | join(" ")) | contains($q))
  ))
' "$LESSONS" 2>/dev/null)"

n="$(printf '%s' "$matches" | jq 'length' 2>/dev/null)"
case "$n" in ''|*[!0-9]*) n=0 ;; esac

if [ "$n" -eq 0 ]; then
  echo "查無「${keyword}」。目前知識庫現有的 key："
  jq -r '.key // empty' "$LESSONS" 2>/dev/null | sed 's/^/  - /'
  exit 0
fi

echo "命中 $n 則："
printf '%s' "$matches" | jq -r '
  .[] |
  "\n────────────────────────────────────\n" +
  "專案：" + (.project // "-") + "\n" +
  "標籤：" + ((.tags // []) | join(", ")) + "\n" +
  "洞見：" + (.insight // "-") + "\n" +
  "達成：" + (.achieved // "-") + "\n" +
  "日期：" + (.added // "-") + "\n" +
  "程式碼：\n" + (.code // "-")
'
exit 0
