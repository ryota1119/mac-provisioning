# macOS Provisioning

macOS環境のセットアップと管理を自動化するAnsibleプロジェクトです。Homebrewを使用してアプリケーションのインストール、更新、管理を行います。

## 🚀 特徴

- **自動化されたセットアップ**: 新規macOS環境の初期設定を自動化
- **ホスト別設定**: 共通設定とホスト固有設定を分離して管理
- **Homebrew統合**: Brewfileを使用したアプリケーション管理
- **Ansible**: 冪等性を保った設定管理
- **VSCode拡張**: 開発環境の統一

## 📋 前提条件

- macOS 10.15以降
- 管理者権限
- インターネット接続

## 🛠️ セットアップ

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd mac-provisioning
```

### 2. 初期セットアップ

```bash
make bootstrap
```

このコマンドは以下を実行します：

- Xcode Command Line Toolsのインストール
- Homebrewのインストール
- Ansibleのインストール

### 3. プロビジョニング

```bash
make provision
```

Ansibleプレイブックを実行して、アプリケーションのインストールと設定を行います。

### 4. VSCode拡張のインストール（オプション）

```bash
make vscode
```

## 📁 プロジェクト構造

```plaintext
mac-provisioning/
├── ansible.cfg              # Ansible設定
├── playbook.yml             # メインプレイブック
├── Makefile                 # タスク管理
├── group_vars/
│   └── all.yml             # 共通変数
├── roles/
│   └── homebrew/           # Homebrew管理ロール
│       ├── tasks/
│       │   ├── main.yml    # メインタスク
│       │   └── upgrade.yml # アップグレードタスク
│       └── files/
│           ├── Brewfile.common      # 共通Brewfile
│           └── Brewfile.MBP16-2023  # ホスト固有Brewfile
└── scripts/
    ├── bootstrap.sh         # 初期セットアップスクリプト
    ├── build-brewfile.sh    # Brewfile構築スクリプト
    └── install-vscode-extensions.sh # VSCode拡張インストール
```

## 🎯 利用可能なコマンド

### 基本コマンド

- `make help` - 利用可能なコマンドの一覧表示
- `make bootstrap` - 初期セットアップ（Xcode-CLT、Homebrew、Ansible）
- `make provision` - Ansibleでプロビジョニング実行
- `make vscode` - VSCode拡張のインストール
- `make all` - bootstrap → provision → vscode を順次実行

### アップグレードコマンド

- `make brew-upgrade` - Homebrew全体のアップグレード
- `make brew-upgrade-formula` - Homebrewフォーミュラのアップグレード
- `make brew-upgrade-cask` - Homebrewキャスクのアップグレード
- `make brew-upgrade-mas` - MASアプリのアップグレード

### その他

- `make doctor` - 事前チェック（App Storeサインインなど）

## 🔧 設定

### ホスト別設定

`roles/homebrew/files/` ディレクトリに以下のファイルを作成して、ホスト固有の設定を行います：

- `Brewfile.common` - 全ホストで共通のアプリケーション
- `Brewfile.<ホスト名>` - 特定ホスト専用のアプリケーション

### 変数設定

`group_vars/all.yml` で以下の設定が可能です：

```yaml
brewfile_per_host: true        # ホスト別設定を有効化
brewfile_cleanup: false        # 不要なアプリケーションの削除
brewfile_file_path: "~/.Brewfile.tmp"  # 一時Brewfileのパス
```

## 📝 Brewfileの書き方

Brewfileは以下の形式で記述します：

```ruby
# フォーミュラ（CLIツール）
brew "git"
brew "vim"

# キャスク（GUIアプリケーション）
cask "visual-studio-code"
cask "google-chrome"

# MASアプリ（App Storeアプリ）
mas "1Password", id: 443987910
```

## 🔍 トラブルシューティング

### Homebrewが見つからない場合

```bash
make bootstrap
```

### 権限エラーが発生する場合

管理者権限でターミナルを実行してください。

### 特定のアプリケーションがインストールされない場合

Brewfileの構文を確認し、アプリケーション名が正しいかチェックしてください。

## 🤝 貢献

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🙏 謝辞

- [Homebrew](https://brew.sh/) - macOS用パッケージマネージャー
- [Ansible](https://www.ansible.com/) - 自動化ツール
- [Brewfile](https://github.com/Homebrew/homebrew-bundle) - Homebrew依存関係管理
