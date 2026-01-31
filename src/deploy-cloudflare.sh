#!/bin/bash

# TRIP Cloudflare Pages 部署腳本
# 此腳本會建置應用程式並準備用於 Cloudflare Pages 部署的檔案

set -e  # 遇到錯誤立即停止

echo "🚀 開始建置 TRIP 雙語版本..."

# 確認在正確的目錄
if [ ! -f "package.json" ]; then
    echo "❌ 錯誤：請在 src 目錄中執行此腳本"
    exit 1
fi

# 清理舊的建置檔案
echo "🧹 清理舊的建置檔案..."
rm -rf dist

# 安裝依賴（如果需要）
if [ ! -d "node_modules" ]; then
    echo "📦 安裝依賴..."
    npm install
fi

# 建置應用程式
echo "🔨 建置應用程式（英文 + 繁體中文）..."
npm run build

# 檢查建置是否成功
if [ ! -d "dist/trip/browser/en" ] || [ ! -d "dist/trip/browser/zh-Hant" ]; then
    echo "❌ 建置失敗：找不到語言目錄"
    exit 1
fi

# 複製 Cloudflare 配置檔案到建置目錄
echo "📋 複製 Cloudflare 配置檔案..."
cp _redirects dist/trip/browser/
cp _headers dist/trip/browser/

# 建立根目錄的 index.html（重定向到英文版）
echo "📄 建立根目錄重定向頁面..."
cat > dist/trip/browser/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>TRIP - Redirecting...</title>
    <meta http-equiv="refresh" content="0; url=/en/">
    <script>
        // 根據瀏覽器語言自動重定向
        const lang = navigator.language || navigator.userLanguage;
        if (lang.startsWith('zh')) {
            window.location.href = '/zh-Hant/';
        } else {
            window.location.href = '/en/';
        }
    </script>
</head>
<body>
    <p>Redirecting to <a href="/en/">TRIP</a>...</p>
    <p>正在重定向到 <a href="/zh-Hant/">TRIP</a>...</p>
</body>
</html>
EOF

echo "✅ 建置完成！"
echo ""
echo "📦 建置產物位置："
echo "   dist/trip/browser/"
echo ""
echo "📊 檔案統計："
echo "   英文版本："
du -sh dist/trip/browser/en 2>/dev/null || echo "   無法計算大小"
echo "   繁體中文版本："
du -sh dist/trip/browser/zh-Hant 2>/dev/null || echo "   無法計算大小"
echo ""
echo "🎯 下一步："
echo "   1. 前往 Cloudflare Pages 控制台"
echo "   2. 連接您的 Git 儲存庫"
echo "   3. 設定建置命令：cd src && npm run build"
echo "   4. 設定建置輸出目錄：src/dist/trip/browser"
echo "   5. 部署！"
echo ""
echo "📚 詳細說明請參考 CLOUDFLARE_DEPLOYMENT.md"
