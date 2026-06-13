---
name: learn
description: 從我的個人心得庫用關鍵字叫出之前的工程心得。當我輸入 /mame:learn <關鍵字>（例如 /mame:learn useSelector）時使用。會顯示這則心得來自哪個專案、用了什麼、達成什麼，以及完整的程式碼。
---

# learn — 回想一則工程心得

當使用者輸入 `/mame:learn <關鍵字>` 時：

1. 執行查表腳本（純查表，不要自行推測或補充內容）：
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/skills/learn/lookup.sh" "<關鍵字>"
   ```
2. 把腳本輸出清楚呈現給使用者：
   - 列出每則的 專案 / 標籤 / 洞見 / 達成 / 日期。
   - 程式碼用對應語言的 code block 包起來（依 tags 或內容判斷語言）。
3. 這是「快速回想」，不要額外展開成教學或長篇解釋。若查無命中，腳本會列出現有 key，直接把它呈現給使用者參考即可。
