#!/usr/bin/env bash
# 掛 Stop 與 StopFailure：清除這一輪的旗標。

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
[ -z "$session_id" ] && exit 0

rm -f "/tmp/cc-lesson-busy-${session_id}"
exit 0
