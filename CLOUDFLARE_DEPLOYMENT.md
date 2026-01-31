# 🌐 TRIP Cloudflare Pages 部署指南

本文件詳細說明如何將 TRIP 雙語應用程式部署到 Cloudflare Pages。

## 📋 目錄

- [準備工作](#準備工作)
- [方法一：透過 Git 自動部署（推薦）](#方法一透過-git-自動部署推薦)
- [方法二：手動上傳部署](#方法二手動上傳部署)
- [配置說明](#配置說明)
- [測試部署](#測試部署)
- [自訂網域](#自訂網域)
- [故障排除](#故障排除)

---

## 準備工作

### 1. Cloudflare 帳號
確保您有 Cloudflare 帳號：
- 前往 [Cloudflare](https://dash.cloudflare.com/sign-up)
- 註冊免費帳號（Pages 服務完全免費）

### 2. Git 儲存庫（方法一需要）
如果使用 Git 自動部署，請確保：
- 程式碼已推送到 GitHub、GitLab 或 Bitbucket
- 您有儲存庫的存取權限

### 3. 本地建置測試
在部署前先確認本地建置正常：

```bash
cd /Users/MING/Sites/trip/src
npm run build
```

確認 `dist/trip/browser/` 目錄下有 `en/` 和 `zh-Hant/` 兩個子目錄。

---

## 方法一：透過 Git 自動部署（推薦）

### 步驟 1：推送程式碼到 Git

如果尚未推送，請先推送：

```bash
cd /Users/MING/Sites/trip
git add .
git commit -m "feat: 加入繁體中文國際化支援"
git push origin main
```

### 步驟 2：建立 Cloudflare Pages 專案

1. 登入 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 點擊左側選單的 **Pages**
3. 點擊 **建立專案** → **連接到 Git**
4. 選擇您的 Git 提供商（GitHub/GitLab/Bitbucket）
5. 授權 Cloudflare 存取您的儲存庫
6. 選擇 `trip` 儲存庫

### 步驟 3：配置建置設定

在專案設定頁面填入以下資訊：

| 設定項目 | 值 |
|---------|---|
| **專案名稱** | `trip`（或您喜歡的名稱） |
| **生產分支** | `main`（或您的主要分支） |
| **框架預設** | 選擇 `Angular` |
| **建置命令** | `cd src && npm install && npm run build` |
| **建置輸出目錄** | `src/dist/trip/browser` |

#### 環境變數（可選）
如果需要，可以加入：
```
NODE_VERSION=18
```

### 步驟 4：開始部署

1. 點擊 **儲存並部署**
2. Cloudflare 會自動開始建置和部署
3. 等待 5-10 分鐘完成第一次部署

### 步驟 5：查看部署結果

部署完成後，您會看到：
- ✅ 部署成功訊息
- 🌐 自動生成的網址（例如：`trip.pages.dev`）
- 📊 部署日誌和詳細資訊

---

## 方法二：手動上傳部署

如果不想連接 Git，可以手動上傳建置檔案。

### 步驟 1：本地建置

```bash
cd /Users/MING/Sites/trip/src
./deploy-cloudflare.sh
```

或手動執行：

```bash
npm run build
```

### 步驟 2：安裝 Wrangler CLI（首次使用）

```bash
npm install -g wrangler
wrangler login
```

### 步驟 3：使用 Wrangler 部署

```bash
cd dist/trip/browser
npx wrangler pages deploy . --project-name=trip
```

### 步驟 4：確認部署

部署完成後，Wrangler 會顯示網址，例如：
```
✨ Success! Uploaded 100 files (2.5 MB)
🌎 Deployment complete! Visit: https://trip-abc.pages.dev
```

---

## 配置說明

### 檔案結構

部署到 Cloudflare Pages 的檔案結構：

```
dist/trip/browser/
├── index.html              # 根目錄重定向頁面
├── _redirects              # Cloudflare 重定向規則
├── _headers                # HTTP 標頭配置
├── en/                     # 英文版本
│   ├── index.html
│   ├── main-*.js
│   ├── styles-*.css
│   └── ...
└── zh-Hant/                # 繁體中文版本
    ├── index.html
    ├── main-*.js
    ├── styles-*.css
    └── ...
```

### _redirects 檔案

```
/*    /en/:splat    302
/en/*    /en/index.html    200
/zh-Hant/*    /zh-Hant/index.html    200
```

**說明**：
- 第 1 行：根路徑自動重定向到 `/en/`
- 第 2 行：英文版本的 SPA 路由回退
-第 3 行：繁體中文版本的 SPA 路由回退

### _headers 檔案

配置了以下安全標頭和快取策略：
- **安全標頭**：防止 XSS、點擊劫持等攻擊
- **靜態資源快取**：JS/CSS/圖片快取 1 年
- **HTML 快取**：不快取，確保更新即時生效

---

## 測試部署

### 1. 驗證語言版本

部署完成後，測試兩個語言版本：

**英文版本**：
```
https://your-site.pages.dev/en/
```

**繁體中文版本**：
```
https://your-site.pages.dev/zh-Hant/
```

### 2. 測試語言切換

1. 訪問任一語言版本
2. 點擊右上角設定圖示（⚙️）
3. 點擊語言按鈕（🌐）
4. 確認能正常切換語言

### 3. 測試路由

在每個語言版本中：
- 點擊不同的連結
- 手動輸入路由（如 `/en/trips`）
- 確認路由正常運作，不會出現 404

### 4. 測試根路徑重定向

訪問根路徑：
```
https://your-site.pages.dev/
```

應自動重定向到：
- 繁體中文用戶 → `/zh-Hant/`
- 其他用戶 → `/en/`

---

## 自訂網域

### 設定自訂網域

1. 在 Cloudflare Pages 專案中，點擊 **自訂網域**
2. 點擊 **設定自訂網域**
3. 輸入您的網域（例如：`trip.yourdomain.com`）
4. 按照指示設定 DNS 記錄

### DNS 設定範例

如果您的網域已在 Cloudflare：
```
類型: CNAME
名稱: trip
內容: your-project.pages.dev
Proxy: 已啟用（橘色雲朵）
```

如果網域不在 Cloudflare，需要加入 CNAME 記錄指向 `your-project.pages.dev`。

### 啟用 HTTPS

Cloudflare Pages 會自動為您的自訂網域提供免費的 SSL 憑證。通常在加入網域後 5-10 分鐘內生效。

---

## 故障排除

### 問題 1：建置失敗

**錯誤訊息**：
```
Error: Cannot find module '@angular/localize'
```

**解決方案**：
確保 `package.json` 中包含 `@angular/localize`：
```bash
cd src
npm install @angular/localize
git add package.json package-lock.json
git commit -m "fix: 加入 @angular/localize 依賴"
git push
```

### 問題 2：路由 404 錯誤

**症狀**：重新整理頁面或直接訪問子路由時出現 404。

**解決方案**：
1. 確認 `_redirects` 檔案存在於 `dist/trip/browser/`
2. 檢查 `angular.json` 中的 assets 配置是否正確
3. 重新建置並部署

### 問題 3：語言切換不工作

**症狀**：點擊語言按鈕後沒有反應。

**解決方案**：
1. 檢查瀏覽器控制台的錯誤訊息
2. 確認 `LanguageService` 已正確注入
3. 確認 `/en/` 和 `/zh-Hant/` 路徑都存在

### 問題 4：根路徑重定向循環

**症狀**：訪問根路徑時出現無限重定向。

**解決方案**：
1. 檢查 `_redirects` 檔案的第一行是否正確
2. 確認沒有在 Angular 路由中配置根路徑重定向
3. 清除瀏覽器快取後重試

### 問題 5：靜態資源載入失敗

**症狀**：CSS 或 JS 檔案 404。

**解決方案**：
1. 檢查 `angular.json` 中的 `baseHref` 設定
2. 確認建置輸出目錄結構正確
3. 查看 Cloudflare Pages 的部署日誌

---

## 進階配置

### 1. 環境變數

在 Cloudflare Pages 專案設定中，可以加入環境變數：

```
NODE_VERSION=18
NG_BUILD_CACHE=.angular
```

### 2. 預覽部署

Cloudflare Pages 會為每個 Pull Request 自動建立預覽部署：
- 每個 PR 都有獨立的預覽網址
- 可用於測試新功能
- 合併後自動部署到生產環境

### 3. 回滾部署

如果新部署出現問題：
1. 前往 Cloudflare Pages 專案
2. 點擊 **部署** 標籤
3. 找到上一個穩定版本
4. 點擊 **回滾到此部署**

### 4. 分析與監控

Cloudflare Pages 提供：
- 📊 流量統計
- ⚡ 效能指標
- 🌍 地理分布
- 📈 帶寬使用情況

---

## 效能優化

### 1. 啟用 Cloudflare 功能

在 Cloudflare Dashboard 中啟用：
- ⚡ **Auto Minify**：自動壓縮 JS/CSS/HTML
- 🖼️ **Polish**：自動優化圖片
- 🚀 **Rocket Loader**：優化 JavaScript 載入
- 📱 **Mobile Redirect**：移動裝置優化

### 2. 配置快取規則

在 `_headers` 檔案中已配置：
- 靜態資源：快取 1 年
- HTML 檔案：不快取
- 安全標頭：已啟用

### 3. 啟用 HTTP/3

Cloudflare 自動支援 HTTP/3（QUIC），無需額外配置。

---

## 成本

**Cloudflare Pages 完全免費**，包括：
- ✅ 無限制的建置次數
- ✅ 無限制的頻寬
- ✅ 免費的 SSL 憑證
- ✅ 全球 CDN
- ✅ 自動部署

**限制**（對於大多數專案來說已足夠）：
- 每月 500 次建置
- 單次建置時間 20 分鐘
- 單一檔案最大 25 MB

---

## 快速部署檢查清單

部署前確認：

- [ ] 本地建置成功（`npm run build`）
- [ ] 兩個語言版本都存在（`en/` 和 `zh-Hant/`）
- [ ] `_redirects` 檔案已建立
- [ ] `_headers` 檔案已建立
- [ ] `deploy-cloudflare.sh` 腳本可執行
- [ ] Git 儲存庫已推送到遠端
- [ ] Cloudflare 帳號已準備好

部署後測試：

- [ ] 英文版本可正常訪問
- [ ] 繁體中文版本可正常訪問
- [ ] 語言切換功能正常
- [ ] 路由導航正常
- [ ] 根路徑自動重定向正常

---

## 相關資源

- 📚 [Cloudflare Pages 官方文件](https://developers.cloudflare.com/pages/)
- 🔧 [Wrangler CLI 文件](https://developers.cloudflare.com/workers/wrangler/)
- 📖 [本專案 i18n 指南](./I18N_GUIDE.md)
- 🚀 [一般部署指南](./DEPLOYMENT_I18N.md)

---

## 需要協助？

如果遇到問題：
1. 查看 [故障排除](#故障排除) 章節
2. 檢查 Cloudflare Pages 的部署日誌
3. 在專案儲存庫提出 Issue

---

**祝您部署順利！** 🎉

如果部署成功，別忘了：
1. 設定自訂網域
2. 啟用效能優化功能
3. 監控流量和效能
4. 與朋友分享您的旅遊規劃應用！
