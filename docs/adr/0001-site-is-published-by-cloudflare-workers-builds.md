# ADR-0001: サイトは Cloudflare Workers Builds で neovim-reverse-lookup.shortarrow.jp に公開する

- 状態: 採用

## 文脈

サイトは Hugo でビルドし、GitHub Actions から GitHub Pages に公開していた。持ち主のほかの静的サイト（vhabitat.shortarrow.jp など）は、shortarrow.jp の下で静的アセットを配る Cloudflare Workers で、それぞれのリポジトリから Workers Builds がビルドしている。Cloudflare は GitHub の OIDC トークンを受け付けないので、GitHub Actions から公開するには、長命の Cloudflare の API トークンをリポジトリのシークレットに置くことになる。

テーマ（`github.com/panr/hugo-theme-terminal` の 2022 年 12 月の版）は、新しい Hugo で取り除かれた `_internal/google_analytics.html` や `.Site.Author` を使い、SCSS を `resources.ToCSS` で変換する。

## 決定

- サイトは、neovim-reverse-lookup.shortarrow.jp で `public/` を静的アセットとして配る Worker とする。Workers Builds をリポジトリにつなぎ、`main` を公開し、ほかのブランチは preview としてビルドする。
- ビルドコマンドは `wrangler.jsonc` の `build.command` に置き、`wrangler deploy` がビルドから公開までを行う。ビルドコマンドは `scripts/build.sh` で、GitHub Pages で使っていた Hugo extended `0.108.0` を取得し、SHA-256 を確かめてから実行する。Workers Builds の環境変数 `HUGO_VERSION` で入る Hugo は extended ではないので、テーマの SCSS を変換できない。
- `baseURL` は `config.toml` に絶対 URL で書く。GitHub Pages のワークフローは `--baseURL` で渡していたが、Workers Builds は渡さない。
- 本番のサイトは workers.dev では配らない。
- GitHub Actions のワークフローは置かない。

## 理由

- サイトが、持ち主のほかのサイトと同じドメインとアカウントに並ぶ。
- GitHub に Cloudflare の認証情報を置かない。
- ビルドコマンドがリポジトリにあるので、ダッシュボードの設定とリポジトリが食い違わない。
- Hugo の版を据え置けば、テーマを変えずにこれまでと同じサイトが出る。

## 採らなかった案

- GitHub Pages に置き続ける：shortarrow.jp の下にあるほかのサイトとは別に、サイトを置く場所がもう一つ増える。
- GitHub Actions から Wrangler で公開する：長命の Cloudflare の API トークンをリポジトリのシークレットに置くことになる。
- 移行と同時に Hugo を上げる：テーマも上げる必要があり、移行とは別の変更になる。

## 結果

- Hugo の版とハッシュは `scripts/build.sh` だけに置く。Workers Builds の環境変数 `HUGO_VERSION` は要らない。
- ローカルでも `scripts/build.sh` で同じ Hugo でビルドできる（linux-amd64 のみ）。
- Hugo を上げるときは、テーマも一緒に上げる。
