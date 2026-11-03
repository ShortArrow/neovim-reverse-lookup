---
title: "Neovim 逆引きチートシート"
---
# Neovim 逆引きチートシート

困っていることから引けるように、上から緊急度の高い順に並べています。版によって使えないものには「0.11 以降」のように書いています。

## 症状から探す {#index}

| 症状 | 見るところ |
| --- | --- |
| 何かおかしい。どこから手を付ければいいか分からない | [まず最初に](#first-steps) |
| 起動しない、エラーだらけ、設定を直したい | [起動しない・壊れた](#broken) |
| 設定したオプションやキーマップが効かない | [設定・キーマップが効かない](#config) |
| 補完や定義ジャンプが動かない | [LSP が動かない](#lsp) |
| 起動が遅い | [起動が遅い](#slow) |
| 色やハイライトがおかしい | [色・ハイライトがおかしい](#highlight) |
| ヤンクしたものを外に貼れない | [クリップボードが使えない](#clipboard) |
| Lua のエラーが出る、値を確かめたい | [Lua を調べる](#lua) |
| 不具合を報告したい、ヘルプを探したい | [調べる・報告する](#report) |

# まず最初に {#first-steps}

原因が分からないときは、この順に見ます。

## 1. エラーメッセージを確認する {#messages}

起動時などに一瞬出て消えたメッセージも、ここで読み直せます。

```vim
:messages
```

## 2. 健康診断をする {#checkhealth}

設定や外部ツールの問題を一覧で教えてくれます。

```vim
:checkhealth
```

## 3. 設定のせいかどうか切り分ける {#clean}

自分の設定とプラグインを読まずに起動します。これで直るなら、原因は設定かプラグインです。

```sh
nvim --clean
```

# 起動しない・壊れた {#broken}

## 設定ファイルの場所を知る {#config-path}

`$MYVIMRC` は読み込まれた設定ファイルです。設定のせいで起動できないときは、`nvim --clean` で開いてから直します。

```vim
:echo $MYVIMRC
:echo stdpath('config')
```

ほかのディレクトリも `stdpath()` で分かります。

| 引数 | 置かれるもの |
| --- | --- |
| `config` | 設定（`init.lua` など） |
| `data` | プラグインなど |
| `state` | ShaDa（履歴など）、スワップファイル、undo |
| `cache` | キャッシュ |
| `log` | ログ |

## 最小構成で再現する {#minimal-repro}

原因のプラグインを絞り込むときや、不具合を報告するときに使います。`repro.lua` を作り、必要なプラグインだけを並べます。次は lazy.nvim を使う例で、作業ディレクトリの `.repro` にすべて入るので、普段の環境を汚しません。

```lua
-- repro.lua
vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").repro({
  spec = {
    -- Add only the plugins needed to reproduce the problem.
  },
})
```

```sh
nvim -u repro.lua
```

# 設定・キーマップが効かない {#config}

## オプションを最後に設定した場所を知る {#verbose-set}

ほかの設定やプラグインに上書きされていないか確かめます。

```vim
:verbose set tabstop?
```

Lua で設定された場合は `Last set from Lua` としか出ません。ファイルと行まで知りたいときは、`-V1` を付けて起動してから同じコマンドを実行します。

```sh
nvim -V1
```

## キーマップの定義元を知る {#verbose-map}

```vim
:verbose map <leader>f
:verbose nmap
```

`<leader>` は `mapleader` の値に置き換わります。Lua で定義されたものの場所は、上と同じく `nvim -V1` で分かります。

## 端末が送っているキーを確かめる {#check-key}

挿入モードで `<C-v>` を押してから、確かめたいキーを押します。Neovim に届いたキーがそのまま入力されます。何も入らないときや別のキーになるときは、端末や tmux がキーを横取りしています。

```text
i  <C-v>  (確かめたいキー)
```

# LSP が動かない {#lsp}

## LSP の状態を確認する {#lsp-health}

起動しているクライアント、対応している filetype、ログの場所などが出ます。

```vim
" 0.11 以降
:checkhealth vim.lsp
" それより前（nvim-lspconfig）
:LspInfo
```

## LSP のログを見る {#lsp-log}

ログファイルの場所を表示して開きます。

```vim
:lua =vim.lsp.get_log_path()
:execute 'tabnew' v:lua.vim.lsp.get_log_path()
```

nvim-lspconfig を入れていれば `:LspLog` でも開けます。詳しいログが欲しいときは、サーバーが起動する前（`init.lua` の先頭など）にログレベルを上げます。

```lua
require("vim.lsp.log").set_level("debug")
```

ログはすぐに大きくなるので、調べ終わったら元に戻します。

# 起動が遅い {#slow}

## 起動時間を計る {#startuptime}

読み込んだファイルごとにかかった時間が `startup.log` に書き出されます。

```sh
nvim --startuptime startup.log
```

# 色・ハイライトがおかしい {#highlight}

## カーソル下のハイライトグループを知る {#inspect}

0.9 以降。Treesitter、LSP のセマンティックトークン、構文ハイライトのどれが色を付けているか分かります。

```vim
:Inspect
```

# クリップボードが使えない {#clipboard}

## クリップボードが使えるか確かめる {#clipboard-check}

```vim
:echo has('clipboard')
:set clipboard?
:checkhealth
```

`:checkhealth` の結果に Clipboard の節があり、どのツールを使っているかが分かります。使えないときは OS に合ったツールを入れます。

| 環境 | ツール |
| --- | --- |
| macOS | `pbcopy`（標準で入っている） |
| Linux（Wayland） | `wl-clipboard` |
| Linux（X11） | `xclip` か `xsel` |
| WSL | `win32yank` |

常にシステムのクリップボードを使うには `vim.opt.clipboard = "unnamedplus"` を設定します。

# Lua を調べる {#lua}

## Lua の値を表示する {#lua-print}

`:lua =式` で値を整形して表示します（0.9 以降）。

```vim
:lua =vim.bo.filetype
:lua =vim.fn.stdpath("config")
```

スクリプトの中では `vim.print()` を使います。

```lua
vim.print(vim.opt.runtimepath:get())
```

## Lua ガイド

<https://neovim.io/doc/user/lua-guide.html>

# 調べる・報告する {#report}

## バージョンとビルド情報を確認する {#version}

不具合を報告するときに必ず要る情報です。

```vim
:version
```

```sh
nvim --version
```

## ヘルプを全文検索する {#helpgrep}

単語がどのヘルプに出てくるかを検索します。見つかったものは `:cnext` と `:cprev` で順に見られます。

```vim
:helpgrep {pattern}
```

# 基本

## チュートリアルを始める

```vim
:Tutor
```

# リンク

- [Neovim official site](https://neovim.io/)
- [Official repository](https://github.com/neovim/neovim)

# 貢献

- [repo](https://github.com/ShortArrow/neovim-reverse-lookup/)
