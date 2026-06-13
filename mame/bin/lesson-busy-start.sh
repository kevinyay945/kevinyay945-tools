#!/usr/bin/env bash
# 掛 UserPromptSubmit：記錄這一輪開始時間。
# 絕對不可印任何東西到 stdout（UserPromptSubmit 的 stdout 會被當成脈絡注入）。

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
[ -z "$session_id" ] && exit 0

printf '%s' "$(date +%s)" > "/tmp/cc-lesson-busy-${session_id}" 2>/dev/null
exit 0
