---
name: add
description: 把一則我指定的工程心得直接寫進個人心得庫（含去重），不綁 commit。可手動用 /mame:add 呼叫，也可以被我自己的其他 skill 內嵌呼叫來塞入想記的內容。
---

# add — 直接往心得庫塞一則知識

純「添加」用的 skill：把使用者**指定的內容**寫進 `~/.claude/lessons/lessons.jsonl`（之後可用 `/mame:learn` 撈回、忙超過兩分鐘時在 statusLine 輪播）。和 `/mame:commit` 不同，這裡**不看 git、不做 commit、不自行判斷值不值得記** —— 使用者叫你記，你就記。

## 觸發方式

1. **手動**：使用者輸入 `/mame:add`，後面可帶上想記的內容。
2. **內嵌**：使用者自己的其他 skill 裡寫「記得呼叫 mame:add 把 X 存起來」時，照本 skill 流程把 X 寫進去。

## 流程

### 1. 蒐集六個欄位
從使用者輸入（或當前對話脈絡）整理出：

| 欄位 | 說明 | 缺了怎麼辦 |
| --- | --- | --- |
| `project` | 哪個專案 | 預設用 `basename "$(git rev-parse --show-toplevel 2>/dev/null)"`；不在 git repo 就用 `-` 或問使用者 |
| `key` | 之後 `/mame:learn` 要查的關鍵字（簡短、好記、最好唯一） | **必填**，沒有就問使用者 |
| `tags` | 技術／標籤，逗號分隔 | 可從內容推斷；真的沒有就傳 `-` |
| `insight` | 一句話洞見（豆知識會顯示的那行） | **必填**，沒有就問使用者 |
| `achieved` | 達成了什麼，能量化就量化 | 沒有就傳 `-` |
| `code` | 想一起記的程式碼／片段 | 沒有就免 |

- 只要 `key` 或 `insight` 缺，就先問使用者補齊，**不要自己亂編內容**。
- 其餘欄位能合理推斷就推斷，並把整理結果**先 show 給使用者確認**再寫入。

### 2. 寫入（呼叫共用腳本，含去重）
- 有 code：先把程式碼原樣寫進暫存檔，再把路徑當第 6 個參數傳入。
- 沒有 code：第 6 個參數傳 `-`。

```bash
# 有 code 時，先落地到暫存檔（保留換行與縮排）
cat > /tmp/mame-add-code-$$.txt <<'EOF'
<把要記的 code 原樣貼這裡>
EOF

bash "${CLAUDE_PLUGIN_ROOT}/bin/add-lesson.sh" \
  "<project>" "<key>" "<tag1,tag2>" "<insight>" "<achieved>" "/tmp/mame-add-code-$$.txt"
```

沒有 code 時：

```bash
bash "${CLAUDE_PLUGIN_ROOT}/bin/add-lesson.sh" \
  "<project>" "<key>" "<tag1,tag2>" "<insight>" "<achieved>" "-"
```

### 3. 回報結果
- `add-lesson.sh` 會自動去重：同 `key` + 同 `insight` 已存在時，它印「已存在（key=…），略過寫入」——這是**正常情形，不是錯誤**，照實轉達即可。
- 成功寫入時印「已記下心得：key=…」，把這行告訴使用者，並附上一句：之後可用 `/mame:learn <key>` 撈回。

> 注意：`add-lesson.sh` 共用於 `/mame:commit`，欄位 schema 與去重邏輯一致，所以這裡記的東西和 commit 記的東西完全相容、可一起被 `/mame:learn` 查到。
