#!/bin/bash

# TRIP Cloudflare Pages 部署腳本

set -e

echo "🚀 開始建置 TRIP..."

if [ ! -f "package.json" ]; then
    echo "❌ 錯誤：請在 src 目錄中執行此腳本"
    exit 1
fi

echo "🧹 清理舊的建置檔案..."
rm -rf dist

if [ ! -d "node_modules" ]; then
    echo "📦 安裝依賴..."
    npm install
fi

echo "🔨 建置應用程式..."
npm run build

if [ ! -d "dist/browser" ]; then
    echo "❌ 建置失敗：找不到輸出目錄"
    exit 1
fi

echo "✅ 建置完成！"
echo ""
echo "📦 建置產物位置："
echo "   dist/browser/"
echo ""
du -sh dist/browser 2>/dev/null || echo "   無法計算大小"
echo ""
echo "🎯 Cloudflare Pages 設定："
echo "   建置命令：cd src && npm install && npm run build"
echo "   建置輸出目錄：src/dist/browser"
