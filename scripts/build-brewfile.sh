#!/bin/bash
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === 設定 ===
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FILES_DIR="${REPO_ROOT}/roles/homebrew/files"

HOSTNAME_SHORT="$(hostname -s 2>/dev/null || scutil --get ComputerName)"
COMMON="${FILES_DIR}/Brewfile.common"
HOST="${FILES_DIR}/Brewfile.${HOSTNAME_SHORT}"

TMP_DIR="$(mktemp -d)"
DUMP="${TMP_DIR}/Brewfile.dump"

# === 関数定義 ===

# 前提確認と初期化
setup() {
    echo ">>> 初期化中..."

    # ディレクトリを作成
    mkdir -p "${FILES_DIR}"

    # ファイルを作成
    # HOSTNAME_SHORTが取得できない場合はエラー
    : "${HOSTNAME_SHORT:?failed to get hostname}"
    touch "${COMMON}"  # まだ無ければ空として扱う
    
    echo "初期化完了"
}

# パッケージをダンプ
dump_packages() {
    echo ">>> Dumping current Brew packages..."
    brew bundle dump --file="${DUMP}" --force
}

# 正規化処理
# - コメント行(#...)と空行を除去
# - 先頭/末尾の空白をトリム
normalize() {
    sed -E 's/[[:space:]]+$//; s/^[[:space:]]+//; /^#/d; /^[[:space:]]*$/d' "$1"
}

# vscodeの拡張機能を除外
remove_vscode_extensions() {
    sed -i '' '/^vscode /d' "$1"
}

# ファイル処理
process_files() {
    echo ">>> ファイル処理中..."

    remove_vscode_extensions "${DUMP}"

    COMMON_NORM="${TMP_DIR}/common.norm"
    DUMP_NORM="${TMP_DIR}/dump.norm"
    normalize "${COMMON}" > "${COMMON_NORM}" || true
    normalize "${DUMP}"   > "${DUMP_NORM}"

    # DUMP の"元の書式"を保ったまま、COMMON に無い行だけを抽出する
    HOST_OUT="${TMP_DIR}/host.out"
    awk -v COMMON_NORM="${COMMON_NORM}" '
        BEGIN{
            while ((getline line < COMMON_NORM) > 0) {
                norm=line
                common[norm]=1
            }
            close(COMMON_NORM)
        }
        function trim(s){ sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
        function is_skip_line(s){ return (s ~ /^[[:space:]]*$/ || s ~ /^[[:space:]]*#/) }
        {
            orig=$0
            if (is_skip_line(orig)) next
            norm=orig
            gsub(/[ \t\r\n]+$/, "", norm)
            sub(/^[ \t\r\n]+/, "", norm)
            if (!(norm in common)) {
                print orig
            }
        }
    ' "${DUMP}" > "${HOST_OUT}"
}

# 出力生成
generate_output() {
    echo ">>> 出力ファイル生成中..."

    # 出力（ヘッダ付き）
    {
        echo "# Brewfile (${HOSTNAME_SHORT}) generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# このファイルは現在の環境から、Brewfile.common に含まれない項目のみを抽出しています。"
        echo
        if [ -s "${TMP_DIR}/host.out" ]; then
            cat "${TMP_DIR}/host.out"
        else
            echo "# 共有化が進んでおり、このホスト固有の項目はありません。"
        fi
    } > "${HOST}"

    echo ">>> Wrote:"
    echo "    Common : ${COMMON}"
    echo "    Host   : ${HOST}"
}

# 使用方法の表示
show_usage_tips() {
    cat <<'EOS'

使い方のコツ:
- 共有したい項目は Brewfile.common に手で移す → 再度このスクリプトを実行すると Host 側から自動で消えます
- Ansible から適用する場合のコマンド例:
    brew bundle --file="roles/homebrew/files/Brewfile.common"
    brew bundle --file="roles/homebrew/files/Brewfile.$(hostname -s)"

補足:
- mas (App Store) のID, cask, tap も行単位で判定します（完全一致）
- 並び順は dump の順序を維持します
EOS
}

# 後始末
cleanup() {
    echo ">>> 後始末中..."
    rm -rf "${TMP_DIR}"
    echo "完了"
}

# メイン関数
main() {
    echo "=== Brewfile ビルド開始 ==="

    setup
    dump_packages
    process_files
    generate_output
    show_usage_tips
    cleanup

    echo "=== Brewfile ビルド完了 ==="
}

# エントリーポイント
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
