# mame — statusLine 豆知識

等 AI 跑指令、而且這一輪超過 2 分鐘時，`mame` 會在 statusLine 上多冒出一則你過去 commit 累積的工程心得（豆知識），外加一行可單獨複製的 `/mame:learn` 指令。平常完全可無視，AI 一跑完豆知識就消失。

示意（忙超過兩分鐘時的三行）：

```
kevin@mac:~/code/jp-flashcard-2026 [Opus 4.8 (1M context)]
你知道嗎，useSelector 傳第二個參數 shallowEqual 可避免每次 store 變動就重渲染整棵元件樹
/mame:learn useSelector
```

三個組件，透過同一份 JSONL 知識庫串起來：

- **擷取** `/mame:commit`：用 Conventional Commits 風格 commit，commit 後視情況把心得寫進知識庫（含去重）。
- **顯示** statusLine 腳本 + 一對 hook：只在這一輪忙超過 120 秒時顯示豆知識。
- **回想** `/mame:learn <關鍵字>`：從知識庫撈出當初哪個專案、用了什麼、達成什麼、完整 code。

程式碼（plugin）與資料（知識庫 `~/.claude/lessons/lessons.jsonl`）分離。

## 前置需求

- `jq`
- `git`
- Claude Code **2.1.97+**（statusLine 的 `refreshInterval` 需要此版本）

## 安裝

```
/plugin marketplace add kevinyay945/kevinyay945-tools
/plugin install mame@kevinyay945-tools
```

## 設定 statusLine（手動，一次性）

statusLine 是全域單一插槽，會覆蓋你原本設定的那個，所以 plugin 不會自動幫你塞。請在 `~/.claude/settings.json` 手動加上：

```json
{
  "statusLine": {
    "type": "command",
    "command": "${CLAUDE_PLUGIN_ROOT}/bin/statusline.sh",
    "refreshInterval": 5
  }
}
```

> `refreshInterval: 5` 讓 statusLine 約每 5 秒重整一次，這樣忙超過門檻時豆知識才會自己冒出來、輪播。

乾淨環境下 statusLine 第一行（`user@host:cwd [model]`）由腳本自組，**不需要任何額外設定**，裝完即可運作。

**進階選用**：如果你已經有自己的 statusLine 腳本想保留，可編輯 `bin/statusline.sh` 把 `BASE_CMD` 設成那支腳本的路徑，第一行就會改用它。預設留空即可。

## 初始化知識庫

二選一：

```bash
# A. 用內附範例起步
mkdir -p ~/.claude/lessons && cp lessons.example.jsonl ~/.claude/lessons/lessons.jsonl

# B. 留空，從第一次 /mame:commit 開始長出來（腳本會自動建立檔案）
```

## 自我測試（免等兩分鐘）

```bash
echo $(( $(date +%s) - 300 )) > /tmp/cc-lesson-busy-test
echo '{"session_id":"test","model":{"display_name":"Opus 4.8"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"context_window_size":1000000}}' \
  | bin/statusline.sh
rm /tmp/cc-lesson-busy-test
```

應印出三行：base 行、`你知道嗎，…`、`/mame:learn <key>`。

## 用法

- 日常：無視它。AI 跑很久時瞄一眼豆知識。
- 好奇某則：把豆知識下面那行 `/mame:learn xxx` 複製貼回輸入框。
- 想 alias 查表：`alias lesson='bash <plugin>/skills/learn/lookup.sh'`，之後 `lesson useSelector`。

## JSONL schema（一行一則）

| 欄位 | 說明 |
| --- | --- |
| `project` | 哪個專案 |
| `key` | `/mame:learn` 用的查詢關鍵字 |
| `tags` | 技術／標籤字串陣列 |
| `insight` | 一句話洞見（豆知識顯示的那行） |
| `achieved` | 達成了什麼，能量化就量化 |
| `code` | 完整程式碼字串（可含 `\n`），或指向檔案／URL 的指標 |
| `added` | 日期 `YYYY-MM-DD` |
