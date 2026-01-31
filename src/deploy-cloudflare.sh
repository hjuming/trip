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
if [ ! -d "dist/browser/en" ] || [ ! -d "dist/browser/zh-Hant" ]; then
    echo "❌ 建置失敗：找不到語言目錄"
    exit 1
fi

# 複製 Cloudflare 配置檔案到根目錄
echo "📋 複製 Cloudflare 配置檔案..."
cp src/_redirects dist/browser/
cp src/_headers dist/browser/

# 複製或建立根目錄的 index.html
echo "📄 建立根目錄重定向頁面..."
if [ -f "public/index.html" ]; then
    cp public/index.html dist/browser/
else
    cat > dist/browser/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>TRIP - Redirecting...</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="0; url=/en/">
    <script>
        const lang = navigator.language || navigator.userLanguage;
        const path = window.location.pathname;
        if (!path.startsWith('/en') && !path.startsWith('/zh-Hant')) {
            if (lang.startsWith('zh')) {
                window.location.href = '/zh-Hant/';
            } else {
                window.location.href = '/en/';
            }
        }
    </script>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container { text-align: center; }
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 4px solid white;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        a { color: white; text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌏 TRIP</h1>
        <div class="spinner"></div>
        <p>Redirecting to your language...</p>
        <p>正在重定向到您的語言版本...</p>
        <p style="margin-top: 30px; font-size: 14px;">
            <a href="/en/">English</a> | 
            <a href="/zh-Hant/">繁體中文</a>
        </p>
    </div>
</body>
</html>
EOF
fi

# 檢查必要檔案
echo "✅ 檢查必要檔案..."
if [ -f "dist/browser/_redirects" ] && [ -f "dist/browser/_headers" ] && [ -f "dist/browser/index.html" ]; then
    echo "✅ 所有必要檔案都已就緒"
else
    echo "⚠️  警告：部分檔案可能缺失"
    ls -la dist/browser/ | head -10
fi

echo "✅ 建置完成！"
echo ""
echo "📦 建置產物位置："
echo "   dist/browser/"
echo ""
echo "📊 檔案統計："
echo "   英文版本："
du -sh dist/browser/en 2>/dev/null || echo "   無法計算大小"
echo "   繁體中文版本："
du -sh dist/browser/zh-Hant 2>/dev/null || echo "   無法計算大小"
echo ""
echo "🎯 Cloudflare Pages 設定："
echo "   建置命令：cd src && npm install && ./deploy-cloudflare.sh"
echo "   建置輸出目錄：src/dist/browser"
echo ""
echo "📚 詳細說明請參考 CLOUDFLARE_DEPLOYMENT.md"
