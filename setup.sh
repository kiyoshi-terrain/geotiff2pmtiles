#!/usr/bin/env bash
# setup.sh — geotiff2pmtiles の依存関係をインストール (macOS)
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}geotiff2pmtiles セットアップ${NC}"
echo "================================"
echo ""

# macOS チェック
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${YELLOW}[WARN]${NC} このスクリプトは macOS 用です。"
    echo "  Linux の場合: sudo apt install gdal-bin && pip install pmtiles"
    exit 1
fi

# Homebrew チェック & インストール
if ! command -v brew &>/dev/null; then
    echo -e "${BLUE}[INFO]${NC} Homebrew をインストールしています..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}[OK]${NC}   Homebrew $(brew --version | head -1)"
fi

# GDAL インストール
if ! command -v gdalinfo &>/dev/null; then
    echo -e "${BLUE}[INFO]${NC} GDAL をインストールしています..."
    brew install gdal
else
    local_gdal_ver=$(gdalinfo --version 2>/dev/null | head -1)
    echo -e "${GREEN}[OK]${NC}   ${local_gdal_ver}"
fi

# pmtiles CLI インストール
if ! command -v pmtiles &>/dev/null; then
    echo -e "${BLUE}[INFO]${NC} pmtiles CLI をインストールしています..."
    brew install pmtiles
else
    local_pm_ver=$(pmtiles --version 2>/dev/null || pmtiles version 2>/dev/null || echo "pmtiles (installed)")
    echo -e "${GREEN}[OK]${NC}   ${local_pm_ver}"
fi

# WebP サポート確認
echo ""
if gdal_translate --formats 2>/dev/null | grep -qi "WEBP"; then
    echo -e "${GREEN}[OK]${NC}   GDAL WebP サポート: あり"
else
    echo -e "${RED}[ERROR]${NC} GDAL WebP サポート: なし"
    echo "  修正: brew reinstall gdal"
    exit 1
fi

# python3 確認
if command -v python3 &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}   python3 $(python3 --version 2>&1)"
else
    echo -e "${YELLOW}[WARN]${NC} python3 が見つかりません (EPSG自動検出に必要)"
    echo "  インストール: brew install python3"
fi

# 設定ファイル
CONFIG_FILE="${HOME}/.geotiff2pmtiles.conf"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -f "$CONFIG_FILE" ]]; then
    if [[ -f "${SCRIPT_DIR}/.geotiff2pmtiles.conf.example" ]]; then
        cp "${SCRIPT_DIR}/.geotiff2pmtiles.conf.example" "$CONFIG_FILE"
        echo ""
        echo -e "${GREEN}[OK]${NC}   設定ファイルを作成しました: ${CONFIG_FILE}"
        echo "       必要に応じて DEFAULT_ZONE 等を編集してください。"
    fi
else
    echo -e "${GREEN}[OK]${NC}   設定ファイル: ${CONFIG_FILE} (既存)"
fi

# PATH 追加の案内
BIN_DIR="${SCRIPT_DIR}/bin"
echo ""
echo "================================"
echo ""

if echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
    echo -e "${GREEN}[OK]${NC}   PATH に bin/ が含まれています"
else
    echo -e "${YELLOW}[INFO]${NC} PATH に bin/ を追加するには:"
    echo ""
    echo "  echo 'export PATH=\"${BIN_DIR}:\$PATH\"' >> ~/.zshrc"
    echo "  source ~/.zshrc"
    echo ""
    echo "  または直接実行:"
    echo "  ${BIN_DIR}/geotiff2pmtiles --help"
fi

echo ""
echo -e "${GREEN}${BOLD}セットアップ完了!${NC}"
echo ""
echo "  使い方:"
echo "    geotiff2pmtiles --zone IV input.tif"
echo "    geotiff2pmtiles --help"
echo ""
