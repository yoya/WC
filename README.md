# WC (Window Cluster)

Windower addon。複数窓の FF11 を、キーひとつで切り替える。

もとは [AC (AccountCluster)](https://github.com/yoya/AC) の `ac/focus.lua` だった処理を
切り出したもの。AC とは独立に動く（両方入れても、片方だけでも良い）。

## 仕組み

キーを押した窓が「#N を前に出せ」と IPC で全窓に投げ、自分が #N の窓だけが
`windower.take_focus()` する。押した窓＝今フォーカスされている窓なので、
「次の窓」も押した側で計算できる。

## キー

| キー | 動作 |
|---|---|
| `Win + <番号>` | その番号の窓を前に出す |

実際に効くのはこれだけ。`Alt + <番号>`、`Ctrl + Tab`、`Win + L`、`Win + M` も
bind はしているが反応しない。「次の窓」は `wc focus next` コマンドで。

## コマンド

```
wc focus <番号>|next
wc show                 窓番号とキャラ名の対応を出す
wc reload
wc help
```

## 設定

`data/settings.xml.sample` を `data/settings.xml` にコピーして書く。
タグの番号がそのまま窓番号になる。1 つの窓で複数キャラを使い分けるなら、
カンマ区切りで全部並べる。

```xml
<AccountList>
    <1> Taro, Jiro </1>
    <2> Hanako </2>
</AccountList>
```

AccountList に無いキャラでログインした窓は、切り替え先にならない。
ログイン時に警告が出る。

## インストール

`Windower/addons/WC/` に置いて、`Windower/scripts/init.txt` に足す。

```
lua load WC
```

設定を変えたら `wc reload`。
