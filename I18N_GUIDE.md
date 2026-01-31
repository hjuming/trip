# TRIP 多語言支援說明

本專案已成功整合 Angular i18n 國際化系統，支援**英文**和**繁體中文（台灣）**雙語界面。

## 🌍 支援語言

- **英文（English）** - `en`
- **繁體中文（台灣）** - `zh-Hant`

## 📦 建置

### 建置所有語言版本
```bash
cd src
npm run build
```

這會在 `dist/trip/browser/` 目錄下生成兩個語言版本：
- `en/` - 英文版本
- `zh-Hant/` - 繁體中文版本

### 只建置繁體中文版本
```bash
cd src
npm run build:zh
```

## 🚀 開發與測試

### 啟動英文版本開發伺服器
```bash
cd src
npm start
```

### 啟動繁體中文版本開發伺服器
```bash
cd src
npm start:zh
```

## 🔄 更新翻譯流程

當您修改或新增 UI 文字時，請依照以下步驟更新翻譯：

### 1. 在模板中標記文字

在 HTML 模板中使用 `i18n` 屬性：
```html
<span i18n="@@uniqueId">Text to translate</span>
```

對於屬性，使用 `i18n-屬性名`:
```html
<button i18n-label="@@buttonLabel" label="Click me"></button>
```

### 2. 在 TypeScript 中使用 $localize

首先宣告 $localize：
```typescript
declare const $localize: any;
```

然後在程式碼中使用：
```typescript
const message = $localize`:@@messageId:Message text`;
```

### 3. 提取翻譯訊息

```bash
cd src
npm run extract-i18n
```

這會更新 `src/locale/messages.xlf` 檔案。

### 4. 更新繁體中文翻譯

編輯 `src/locale/messages.zh-Hant.xlf`，為新的 `<trans-unit>` 項目加入 `<target>` 標籤：

```xml
<trans-unit id="uniqueId" datatype="html">
  <source>Text to translate</source>
  <target>要翻譯的文字</target>
  <context-group purpose="location">
    ...
  </context-group>
</trans-unit>
```

### 5. 重新建置並測試

```bash
npm run build
```

## 🎨 語言切換功能

使用者可以在應用程式的設定面板中切換語言：

1. 點擊右上角的設定圖示（齒輪）
2. 在設定面板頂部找到「語言」按鈕（地球儀圖示）
3. 點擊即可在英文和繁體中文之間切換

語言切換會重新載入頁面，並切換到選定的語言版本。

## 📝 台灣繁體中文用語參考

以下是本專案使用的台灣繁體中文用語：

- **Trip** → 行程
- **Place** → 地點
- **Map** → 地圖
- **Filters** → 篩選
- **Categories** → 分類
- **Settings** → 設定
- **Backup** → 備份
- **Currency** → 貨幣
- **Password** → 密碼
- **Security** → 安全性
- **Two-Factor Auth** → 雙重驗證
- **API Key** → API 金鑰
- **Dog-friendly** → 友善寵物
- **Favorites** → 我的最愛
- **Visited** → 已造訪

## 📂 檔案結構

```
src/
├── locale/
│   ├── messages.xlf          # 英文原始訊息（自動生成）
│   └── messages.zh-Hant.xlf  # 繁體中文翻譯
├── src/
│   └── app/
│       ├── services/
│       │   └── language.service.ts  # 語言切換服務
│       └── components/
│           ├── dashboard/
│           ├── trips/
│           └── ...
└── angular.json               # i18n 配置
```

## 🔧 配置檔案

### angular.json

```json
{
  "i18n": {
    "sourceLocale": "en",
    "locales": {
      "zh-Hant": {
        "translation": "src/locale/messages.zh-Hant.xlf",
        "baseHref": ""
      }
    }
  }
}
```

## ✅ 目前翻譯狀態

已完成翻譯的組件：
- ✅ Dashboard（主控台）
- ✅ Trips（行程列表）
- ✅ Settings（設定面板）
- ⏳ Trip 詳情頁面（待完成）
- ⏳ 各種模態框（待完成）

## 🚧 待完成項目

為了完整支援繁體中文，以下項目仍需處理：

1. **Trip 詳情頁面**：為 `trip.component.html` 加入 i18n 標記
2. **所有模態框組件**：為各個模態框的文字加入翻譯
3. **錯誤訊息**：為 TypeScript 中的錯誤訊息加入 $localize
4. **Toast 通知**：為通知訊息加入翻譯
5. **驗證訊息**：為表單驗證訊息加入翻譯

## 📖 參考資源

- [Angular i18n 官方文件](https://angular.dev/guide/i18n)
- [XLIFF 格式規範](https://docs.oasis-open.org/xliff/xliff-core/v1.2/os/xliff-core-1.2-os.html)

---

如有任何問題或建議，歡迎提出 Issue 或 Pull Request！
