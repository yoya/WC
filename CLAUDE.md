# WC (Window Cluster)

FF11 の複数窓をキーで切り替える Windower アドオン。
仕様は [README.md](README.md)。

## 開発環境

- **Lua 5.1**（Windower が改造したもの）。5.2 以降の書き方は使わない。
- **静的チェック**: `~/.luarocks/bin/luacheck .`（Lua 5.4 版）。設定は `.luacheckrc`。
- **テスト**: `cd tests && lua run.lua`

## 構成

2 ファイルだけ。windower に触るかどうかで割っている。

| | 中身 |
|---|---|
| `focus.lua` | AccountList → 窓番号の表、次の窓の計算。windower に触らないのでテストできる |
| `WC.lua` | bind、コマンド、IPC 送受信、`take_focus()`、イベント登録 |

これ以上ファイルを増やさない。増えるなら、それは WC の仕事ではない可能性が高い。

## 決めごと

- **グローバル関数を定義しない。** `.luacheckrc` の `globals` は `_addon` だけ。
- IPC のメッセージは `WC.focus.<番号>` の 1 種類だけ。増やすなら理由を書く。
- AC と同時に動く。AC の IPC (`AC.` で始まる) は無視するし、AC も `WC.` を無視する。
- `bind` は Windower 全体で共有される。AC 側と同じキーを取らない。
