# 依存関係

`fzf` `ripgrep` `nodejs` `npm` `cmake` `make` `tree-sitter-cli`

より広いシステム依存関係は `packages_list` も参照してください。

LSP サーバーは Mason でインストールします。よく使うサーバー:
- TypeScript: `typescript-language-server` (ts_ls)
- C/C++: `clangd`
- Bash: `bash-language-server`
- Lua: `lua-language-server`

# キーマップ一覧

## LSP 関連
- `<leader>le`: 現在行の診断メッセージをポップアップで表示
- `[d`: 直前の診断へ移動
- `]d`: 次の診断へ移動
- `K`: 拡張したフロートで hover ドキュメントを表示
- `<leader>ld`: 定義へ移動
- `<leader>lD`: 宣言へ移動（サーバーが対応している場合）
- `<leader>lt`: 型定義へ移動
- `<leader>lx`: 型定義を水平分割で開く
- `<leader>lv`: 型定義を垂直分割で開く
- `<leader>lm`: 実装へ移動
- `<leader>lR`: 参照を検索
- `<leader>ls`: シグネチャヘルプ表示
- `<leader>li`: Inlay Hints の切り替え（サーバーが対応している場合）
- `<leader>lr`: リネーム
- `<leader>la`: コードアクション
- `<leader>lf`: フォーマット
- `<leader>lp`: 現在バッファに残ったまま型定義をプレビュー

## 補完
- `<C-d>`: ドキュメントを上に 4 行スクロール
- `<C-f>`: ドキュメントを下に 4 行スクロール
- `<C-s>`: 補完メニューを開く
- `<CR>`: 補完候補を確定
- `<C-n>`: 次の補完候補へ
- `<C-p>`: 前の補完候補へ
- 補完ドキュメントは rounded border のフロートで自動表示
- Copilot は inline panel/suggestion ではなく blink.cmp の source として表示

## 翻訳
- `<leader>td`（ノーマル）: カーソル位置の診断を翻訳
- `<leader>tc`（ノーマル）: 現在行のコメント本文を翻訳
- `<leader>tw`（ノーマル）: カーソル下の単語を翻訳
- `<leader>tt`（ノーマル）: 診断、コメント、単語の順で文脈翻訳
- `<leader>tt`（ビジュアル）: 選択範囲を翻訳
- `<leader>td`（ビジュアル）: 選択範囲を翻訳（互換用）
- `<leader>tr`（ビジュアル）: 選択範囲を翻訳して置換

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
- 補完（blink.cmp）セットアップ: `lua/plugins/cmp.lua`
- Copilot 連携: `lua/plugins/copilot.lua`
- Tree-sitter parser 管理: `lua/plugins/nvim-treesitter.lua`
- ネイティブ Tree-sitter 起動: `lua/config/treesitter.lua`
- 言語サーバー個別設定: `lua/lsp/servers/*.lua`

## LSP の挙動（Neovim 0.11 流儀）
- サーバーは Mason でインストールし、起動は Neovim ネイティブ API（`vim.lsp.start`）で実施
- バッファローカルのキーマップと `omnifunc` は `LspAttach` で付与
- LSP キーマップは attach したサーバーが対応 capability を持つ場合だけ作成
- Inlay Hints は対応サーバーではデフォルト有効、`<leader>li` で切替
- 診断 UI は `lua/config/config.lua` で一括設定

## 言語別 LSP オーバーライド
`lua/lsp/servers/<server>.lua` にテーブルを置くと、内蔵のデフォルト設定に深くマージされ、`vim.lsp.start` の直前に適用されます。

用意済み:
- TypeScript (ts_ls): `lua/lsp/servers/ts_ls.lua`
- C/C++ (clangd): `lua/lsp/servers/clangd.lua`
- Bash (bashls): `lua/lsp/servers/bashls.lua`
- Lua (lua_ls): `lua/lsp/servers/lua_ls.lua`

注意: 環境によってサーバー名が `tsserver` の場合もありますが、ローダー側で `ts_ls` にフォールバックします。

## 補完（blink.cmp）
- 設定は `lua/plugins/cmp.lua` に分離されています（LSP プラグインから独立）
- スニペットは blink.cmp の組み込み snippet source と `friendly-snippets` を使用
- 有効なソース: `lsp`, `path`, `snippets`, `buffer`, `copilot`
- Copilot の補完は `blink-cmp-copilot` を blink.cmp source として有効化
- 補完メニューの選択行とドキュメントフロートは見やすいように明示的に配色・表示設定

## Tree-sitter
- Parser のインストール管理は `neovim-treesitter/nvim-treesitter` と `treesitter-parser-registry` を使用
- 実際のハイライトや fold は Neovim ネイティブの `vim.treesitter.*` API で起動
- Parser は旧 nvim-treesitter の一括 module 設定ではなく、必要な言語を個別に導入する前提

## LSP テストファイル
- `test/ts/*.ts` と `test/cpp/*.{hpp,cpp}` は hover、定義、型定義、分割ジャンプ、参照、補完を確認するための snake_case サンプルです

## 追加ユーティリティ

- 診断とコード行のヤンク:
  - `<leader>yd`: カーソル行 + 最初の診断メッセージをヤンク
  - `<leader>yad`: ファイル全体をヤンクし、その後に診断のある行＋メッセージを列挙してヤンク
  - `<leader>ys`（ビジュアル）: 選択ブロック全体を貼り付け、続けて選択範囲の診断一覧をヤンク
  - 実装: `lua/config/yank.lua`
- 診断、コメント、単語、選択範囲の翻訳（`GEMINI_API_KEY` と `GEMINI_MODEL` が必要）:
  - `<leader>td`（ノーマル）: 診断
  - `<leader>tc`（ノーマル）: 現在行のコメント
  - `<leader>tw`（ノーマル）: カーソル下の単語
  - `<leader>tt`（ノーマル）: 診断／コメント／単語を文脈で選択
  - `<leader>tt` / `<leader>td`（ビジュアル）: 選択範囲
  - `<leader>tr`（ビジュアル）: 翻訳して置換
  - 実装: `lua/config/ai/translate.lua`
- `:messages` の表示を分割で開く:
  - `<leader>ms`
  - 実装: `lua/config/message.lua`
- シェルコマンドの出力を現在行の下へ挿入:
  - `<leader>si`: コマンドを入力して出力を挿入
  - `:ShellInsert git status`
  - 実装: `lua/config/shell_insert.lua`

## 標準機能での代替

- `:read !cmd`: 現在行の下にコマンド出力を挿入
- `:%!cmd`: バッファ全体をコマンド出力で置換
- `:'<,'>!cmd`: 選択範囲をコマンドでフィルタ
- 例: `:read !ls`, `:%!sort`, `:'<,'>!jq .`

## 備考

- ルート直下の `env` ファイル（存在すれば）は `init.lua` により読み込まれ、VCS からは除外されています
- `lazy-lock.json` は追跡しません（.gitignore）。プラグインバージョンを固定したい場合は、各自で `.gitignore` から除外してください
