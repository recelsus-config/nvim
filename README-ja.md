# 依存関係

`fzf` `ripgrep` `nodejs` `npm` `cmake` `make`

LSP サーバーは Mason でインストールします。よく使うサーバー:
- TypeScript: `typescript-language-server` (ts_ls)
- C/C++: `clangd`
- Bash: `bash-language-server`
- Lua: `lua-language-server`

# キーマップ一覧

## タブ関連
- `<leader>1`: 1 番目のタブへ移動
- `<leader>2`: 2 番目のタブへ移動
- `<leader>3`: 3 番目のタブへ移動
- `<leader>4`: 4 番目のタブへ移動
- `<leader>t`: 新しいタブを開く (`:tabnew<CR>`)
- `<leader>q`: 現在のタブを閉じる (`:tabclose<CR>`)

## LSP 関連
- `<leader>e`: 現在行の診断メッセージをポップアップで表示
- `[d`: 直前の診断へ移動
- `]d`: 次の診断へ移動
- `K`: カーソル下シンボルのドキュメント表示（hover）
- `gd`: 定義へ移動（goto definition）
- `gi`: 実装へ移動（goto implementation）
- `gr`: 参照を検索（goto references）
- `gs`: シグネチャヘルプ表示（signature help）
- `<leader>ih`: Inlay Hints の切り替え（サーバーが対応している場合）
- `<leader>lr`: リネーム
- `<leader>la`: コードアクション
- `<leader>lf`: フォーマット

## 補完（cmp）
- `<C-d>`: ドキュメントを上に 4 行スクロール
- `<C-f>`: ドキュメントを下に 4 行スクロール
- `<C-s>`: 補完メニューを開く
- `<C-e>`: 補完メニューを閉じる
- `<CR>`: 補完候補を確定
- `<C-n>`: 次の補完候補へ
- `<C-p>`: 前の補完候補へ

## Telescope
- `<leader>ff`: ファイル検索（`Telescope find_files`）
- `<leader>fg`: テキスト検索（`Telescope live_grep`）
- `<leader>fb`: バッファ一覧（`Telescope buffers`）
- `<leader>fh`: ヘルプタグ検索（`Telescope help_tags`）
- `<leader>fk`: キーマップ検索（`builtin.keymaps`）

# 設定構成

- プラグインマネージャ: `lazy.nvim`（`init.lua`）
- エディタ全体設定 & 診断表示: `lua/config/config.lua`
- LSP コア（Mason + ネイティブ LSP + LspAttach マッピング）: `lua/plugins/nvim-lsp.lua`
- 補完（cmp）セットアップ: `lua/plugins/cmp.lua`
- Copilot 連携: `lua/plugins/copilot.lua`
- 言語サーバー個別設定: `lua/lsp/servers/*.lua`

## LSP の挙動（Neovim 0.11 流儀）
- サーバーは Mason でインストールし、起動は Neovim ネイティブ API（`vim.lsp.config` + `vim.lsp.start`）で実施
- バッファローカルのキーマップと `omnifunc` は `LspAttach` で付与
- Inlay Hints は対応サーバーではデフォルト有効、`<leader>ih` で切替
- 診断 UI は `lua/config/config.lua` で一括設定

## 言語別 LSP オーバーライド
`lua/lsp/servers/<server>.lua` にテーブルを置くと、内蔵のデフォルト設定に深くマージされ、`vim.lsp.start` の直前に適用されます。

用意済み:
- TypeScript (ts_ls): `lua/lsp/servers/ts_ls.lua`
- C/C++ (clangd): `lua/lsp/servers/clangd.lua`
- Bash (bashls): `lua/lsp/servers/bashls.lua`
- Lua (lua_ls): `lua/lsp/servers/lua_ls.lua`

注意: 環境によってサーバー名が `tsserver` の場合もありますが、ローダー側で `ts_ls` にフォールバックします。

## 補完（cmp）
- 設定は `lua/plugins/cmp.lua` に分離されています（LSP プラグインから独立）
- 有効なソース: `nvim_lsp`, `nvim_lsp_document_symbol`, `nvim_lsp_signature_help`, `copilot`, `buffer`, `path`
- Copilot の補完は `copilot-cmp` 連携で有効化（`lua/plugins/copilot.lua`）

## 追加ユーティリティ

- 診断とコード行のヤンク:
  - `<leader>yd`: カーソル行 + 最初の診断メッセージをヤンク
  - `<leader>yad`: 診断のあるすべての行＋メッセージをヤンク
  - 実装: `lua/config/yank.lua`
- 診断メッセージやビジュアル選択の翻訳（外部プロバイダ設定が必要な場合あり）:
  - `<leader>td`（ノーマル／ビジュアル）
  - 実装: `lua/config/translate.lua`
- `:messages` の表示を分割で開く:
  - `<leader>ms`
  - 実装: `lua/config/message.lua`

## 備考

- ルート直下の `env` ファイル（存在すれば）は `init.lua` により読み込まれ、VCS からは除外されています
- `lazy-lock.json` は追跡しません（.gitignore）。プラグインバージョンを固定したい場合は、各自で `.gitignore` から除外してください
