---
name: commit
description: 用 Conventional Commits 風格幫我把目前的變更 commit 起來，並在 commit 之後，視情況把這次值得記的工程心得寫進我的個人心得庫。當我輸入 /mame:commit 時使用。
---

# commit — Conventional Commits 並視情況擷取心得

當使用者輸入 `/mame:commit` 時，依序做三步：

## 1. 看狀態，決定要 commit 什麼
- 跑 `git status` 與 `git diff --staged`、`git diff`。
- 有 staged 變更 → 直接用 staged 的內容。
- 沒有 staged、但有未追蹤／未暫存變更 → **先摘要這些變更**，問使用者要全部加入還是挑特定檔案。**不要自作主張 `git add -A`。**

## 2. 寫 Conventional Commits 訊息並 commit
- 格式：`type(scope): subject`
  - 常用 type：`feat`、`fix`、`docs`、`style`、`refactor`、`perf`、`test`、`build`、`ci`、`chore`。
  - subject：祈使句、≤72 字、句尾無句號。
  - 破壞性變更：type 後加 `!`，並在結尾加 `BREAKING CHANGE:` footer。
  - 非瑣碎變更：加 body 說明「為什麼」這樣改。
- **不要**加任何 `Generated with Claude Code` 或 `Co-authored-by` trailer。
- 把完成的 commit 訊息 show 給使用者，再執行 commit。

## 3. 視情況擷取心得（只在值得時）
- 例行修改（錯字、排版、版本號、機械式改名、套件更新）→ **直接跳過**，不要記。
- 真的學到可重用的東西才整理，並呼叫 add-lesson.sh：
  - `project`：用 `basename "$(git rev-parse --show-toplevel)"`。
  - `key`：之後 `/mame:learn` 會查的關鍵字（簡短、可記）。
  - `tags`：技術／標籤，逗號分隔。
  - `insight`：一句話洞見（就是豆知識會顯示的那行）。
  - `achieved`：達成了什麼，能量化就量化。
  - 把關鍵 code 寫進一個暫存檔（例如 `/tmp/mame-code-$$.txt`），路徑當第 6 個參數傳入；沒有 code 就傳 `-`。
  ```bash
  bash "${CLAUDE_PLUGIN_ROOT}/bin/add-lesson.sh" \
    "<project>" "<key>" "<tag1,tag2>" "<insight>" "<achieved>" "/tmp/mame-code-$$.txt"
  ```
- add-lesson.sh 會自動去重；它印出「已存在」是正常情形，不是錯誤。
