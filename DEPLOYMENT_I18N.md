# 雙語系統部署指南

本文件說明如何將支援雙語（英文/繁體中文）的 TRIP 應用程式部署到生產環境。

## 🎯 部署概覽

建置後的應用程式會生成兩個語言版本：
- `/en/` - 英文版本
- `/zh-Hant/` - 繁體中文版本

根據網頁伺服器的不同，您需要配置路由規則以正確提供兩個語言版本。

## 📦 建置生產版本

```bash
cd src
npm run build
```

建置產物位於 `dist/trip/browser/` 目錄：
```
dist/trip/browser/
├── en/
│   ├── index.html
│   ├── main-*.js
│   └── ...
├── zh-Hant/
│   ├── index.html
│   ├── main-*.js
│   └── ...
└── 3rdpartylicenses.txt
```

## 🌐 Web 伺服器配置

### Nginx 配置範例

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/trip/browser;

    # 預設重定向到英文版本
    location = / {
        return 302 /en/;
    }

    # 英文版本
    location /en/ {
        alias /var/www/trip/browser/en/;
        try_files $uri $uri/ /en/index.html;
    }

    # 繁體中文版本
    location /zh-Hant/ {
        alias /var/www/trip/browser/zh-Hant/;
        try_files $uri $uri/ /zh-Hant/index.html;
    }

    # 根據瀏覽器語言自動重定向（可選）
    location = /auto {
        if ($http_accept_language ~* "zh") {
            return 302 /zh-Hant/;
        }
        return 302 /en/;
    }

    # 壓縮配置
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_min_length 1000;
}
```

### Apache 配置範例

`.htaccess` 檔案：

```apache
RewriteEngine On

# 預設重定向到英文版本
RewriteRule ^$ /en/ [R=302,L]

# 根據瀏覽器語言自動重定向（可選）
RewriteCond %{HTTP:Accept-Language} ^zh [NC]
RewriteRule ^auto$ /zh-Hant/ [R=302,L]
RewriteRule ^auto$ /en/ [R=302,L]

# Angular 路由支援
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^en/(.*)$ /en/index.html [L]
RewriteRule ^zh-Hant/(.*)$ /zh-Hant/index.html [L]
```

### Docker + Nginx 配置

`nginx.conf`:
```nginx
server {
    listen 80;
    root /usr/share/nginx/html;

    location = / {
        return 302 /en/;
    }

    location /en/ {
        alias /usr/share/nginx/html/en/;
        try_files $uri $uri/ /en/index.html;
    }

    location /zh-Hant/ {
        alias /usr/share/nginx/html/zh-Hant/;
        try_files $uri $uri/ /zh-Hant/index.html;
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
}
```

`Dockerfile`:
```dockerfile
FROM nginx:alpine

# 複製建置產物
COPY dist/trip/browser /usr/share/nginx/html

# 複製 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

## 🔄 語言偵測選項

### 選項 1：預設語言 + 手動切換
最簡單的方式，使用者訪問時預設顯示英文，可透過設定面板手動切換。

```nginx
location = / {
    return 302 /en/;
}
```

### 選項 2：根據瀏覽器語言自動選擇
根據使用者瀏覽器的 `Accept-Language` 標頭自動選擇語言。

```nginx
location = / {
    if ($http_accept_language ~* "zh-TW|zh-HK|zh-Hant") {
        return 302 /zh-Hant/;
    }
    return 302 /en/;
}
```

### 選項 3：使用 Cookie 記住使用者偏好
```nginx
location = / {
    # 檢查 cookie
    if ($cookie_preferred_lang = "zh-Hant") {
        return 302 /zh-Hant/;
    }
    if ($cookie_preferred_lang = "en") {
        return 302 /en/;
    }
    # 預設使用瀏覽器語言
    if ($http_accept_language ~* "zh") {
        return 302 /zh-Hant/;
    }
    return 302 /en/;
}
```

## 🐳 Docker Compose 完整範例

`docker-compose.yml`:
```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./src
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    restart: unless-stopped
```

## 📱 更新現有的 Docker 配置

如果您已經在使用 Docker 部署 TRIP，需要更新以下檔案：

1. **更新 Dockerfile**（在 `/src` 目錄）:
```dockerfile
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/trip/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

2. **建立 `nginx.conf`**（在 `/src` 目錄）:
使用上述 Nginx 配置範例。

3. **更新建置命令**:
```bash
cd src
docker build -t trip-i18n .
docker run -d -p 8080:80 trip-i18n
```

## 🔍 驗證部署

部署完成後，驗證兩個語言版本都正常運作：

1. 訪問 `http://your-domain.com/en/` - 應顯示英文界面
2. 訪問 `http://your-domain.com/zh-Hant/` - 應顯示繁體中文界面
3. 在設定面板中點擊語言切換按鈕，確認可以正常切換

## 💡 SEO 建議

如果需要 SEO 優化，建議在每個 `index.html` 中加入 `<link>` 標籤：

**英文版 (`en/index.html`)**:
```html
<link rel="alternate" hreflang="en" href="https://your-domain.com/en/" />
<link rel="alternate" hreflang="zh-Hant" href="https://your-domain.com/zh-Hant/" />
<link rel="alternate" hreflang="x-default" href="https://your-domain.com/en/" />
```

**繁體中文版 (`zh-Hant/index.html`)**:
```html
<link rel="alternate" hreflang="en" href="https://your-domain.com/en/" />
<link rel="alternate" hreflang="zh-Hant" href="https://your-domain.com/zh-Hant/" />
<link rel="alternate" hreflang="x-default" href="https://your-domain.com/en/" />
```

## 🔧 故障排除

### 問題：切換語言後出現 404
**解決方案**：檢查 Web 伺服器配置，確保 `try_files` 指令正確設定。

### 問題：部分文字沒有翻譯
**解決方案**：
1. 確認該文字已加入 i18n 標記
2. 執行 `npm run extract-i18n`
3. 在 `messages.zh-Hant.xlf` 中加入翻譯
4. 重新建置

### 問題：語言切換按鈕無作用
**解決方案**：檢查 `language.service.ts` 是否正確注入到組件中。

---

如需更多協助，請參考 [I18N_GUIDE.md](./I18N_GUIDE.md) 或提出 Issue。
