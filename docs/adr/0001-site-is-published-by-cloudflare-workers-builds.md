# ADR-0001: サイトは Cloudflare Workers Builds で nrlcs.shortarrow.jp に公開する

- 状態: 採用

## 文脈

サイトは Hugo でビルドし、GitHub Actions から GitHub Pages に公開していた。持ち主のほかの静的サイト（vhabitat.shortarrow.jp など）は、shortarrow.jp の下で静的アセットを配る Cloudflare Workers で、それぞれのリポジトリから Workers Builds がビルドしている。Cloudflare は GitHub の OIDC トークンを受け付けないので、GitHub Actions から公開するには、長命の Cloudflare の API トークンをリポジトリのシークレットに置くことになる。

テーマ（`github.com/panr/hugo-theme-terminal` の 2022 年 12 月の版）は、新しい Hugo で取り除かれた `_internal/google_analytics.html` や `.Site.Author` を使い、SCSS を `resources.ToCSS` で変換する。

## 決定

- サイトは、nrlcs.shortarrow.jp で `public/` を静的アセットとして配る Worker とする。Workers Builds をリポジトリにつなぎ、`main` を公開し、ほかのブランチは preview としてビルドする。
- ビルドコマンドは `wrangler.jsonc` の `build.command` に置き、`wrangler deploy` がビルドから公開までを行う。Hugo の版は Workers Builds の環境変数 `HUGO_VERSION` で指定し、GitHub Pages で使っていた `0.108.0`（extended）を引き継ぐ。
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

- ローカルで `wrangler dev` や `wrangler deploy` を使うには、`HUGO_VERSION` と同じ版の Hugo extended が PATH に要る。
- Hugo を上げるときは、テーマも一緒に上げる。
