#!/usr/bin/env bash
set -euo pipefail

# Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo ">>> Install Xcode Command Line Tools from the popup, then re-run."
  exit 1
fi

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # dotfiles で .zprofile を管理しているため、追記はしない
  # 現シェルのみ PATH を通して以降の処理を可能にする
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  # 既に brew がある場合も、念のため現シェルに PATH を通す（無害）
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Ansible
brew install ansible || true
ansible-galaxy collection install community.general

echo "Bootstrap done. Now run: make provision"
