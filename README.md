# kevinyay945-tools

kevinyay945 的 Claude Code plugin marketplace。一個 repo 收納多個 plugin，每個 plugin 各自一個資料夾。

## 安裝 marketplace

```
/plugin marketplace add kevinyay945/kevinyay945-tools
```

## Plugins

| Plugin | 資料夾 | 一句話 |
| --- | --- | --- |
| [mame](./mame) | `mame/` | 等 AI 跑指令超過 30 秒時，在 statusLine 冒出一則你過去 commit 累積的工程豆知識。 |

安裝個別 plugin：

```
/plugin install mame@kevinyay945-tools
```

各 plugin 的詳細用法看它自己資料夾裡的 README。

## 結構

```
.
├── .claude-plugin/
│   └── marketplace.json   # marketplace 清單，列出每個 plugin 與其 source 路徑
└── mame/                  # 一個 plugin = 一個資料夾
    ├── .claude-plugin/
    │   └── plugin.json     # 此 plugin 的 manifest
    ├── skills/             # /mame:commit、/mame:learn、/mame:add
    ├── hooks/hooks.json
    ├── bin/                # statusline 與 hook 腳本
    ├── lessons.example.jsonl
    └── README.md
```

## 新增一個 plugin

1. 開一個新資料夾 `<plugin-name>/`，放進 `.claude-plugin/plugin.json` 與 `skills/`、`hooks/`、`commands/` 等元件。
2. 在 `.claude-plugin/marketplace.json` 的 `plugins` 陣列加一筆，`source` 指向 `./<plugin-name>`。
3. 在上面的 Plugins 表格補一列。

> plugin 元件（hooks、skills 裡的腳本）一律用 `${CLAUDE_PLUGIN_ROOT}` 來指路徑，搬資料夾不會壞。唯一例外是寫進 `~/.claude/settings.json` 的 `statusLine.command`（沒有 plugin context），要用 `$HOME/.claude/plugins/marketplaces/kevinyay945-tools/<plugin>/...` 這種絕對路徑。
