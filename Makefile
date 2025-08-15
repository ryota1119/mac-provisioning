SHELL := /bin/zsh

.PHONY: help
help:
	@echo "Targets:"
	@echo "  bootstrap  - Xcode-CLT, Homebrew, Ansible導入（zprofileは変更しない）"
	@echo "  provision  - Ansibleで brew bundle 実行（案A：common+host）"
	@echo "  vscode     - VSCode拡張インストール（任意）"
	@echo "  doctor     - 事前チェック（App Storeサインインなど）"
	@echo "  brew-upgrade - Homebrew アップグレード"
	@echo "  brew-upgrade-formula - Homebrew フォーミュラアップグレード"
	@echo "  brew-upgrade-cask - Homebrew キャスクアップグレード"
	@echo "  brew-upgrade-mas - MASアプリアップグレード"
	@echo "  all        - bootstrap → provision → vscode"

.PHONY: bootstrap
bootstrap:
	./scripts/bootstrap.sh

.PHONY: provision
provision:
	ansible-playbook playbook.yml

.PHONY: vscode
vscode:
	./scripts/install-vscode-extensions.sh

.PHONY: doctor
doctor:
	@command -v brew >/dev/null 2>&1 || echo "⚠️ Homebrew未導入（make bootstrap で導入）"

.PHONY: all
all: bootstrap provision vscode

.PHONY: brew-upgrade
brew-upgrade:
	ansible-playbook playbook.yml --tags brew-upgrade

.PHONY: brew-upgrade-formula
brew-upgrade-formula:
	ansible-playbook playbook.yml --tags brew-upgrade-formula

.PHONY: brew-upgrade-cask
brew-upgrade-cask:
	ansible-playbook playbook.yml --tags brew-upgrade-cask

.PHONY: brew-upgrade-mas
brew-upgrade-mas:
	ansible-playbook playbook.yml --tags brew-upgrade-mas
