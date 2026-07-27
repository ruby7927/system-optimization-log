# 系統優化紀錄系統

記錄各系統的優化內容，支援分類 / 關鍵字 / 日期查詢，並可將單筆或整份清單匯出成 PDF。

- 前端：純靜態網頁（可部署到 GitHub Pages）
- 後端 / 資料庫 / 登入：Supabase
- PDF：html2pdf.js 前端產生，正確支援中文

## 資料欄位
系統分類、標題、說明、更版日期、需求書連結（網址）、執行人

---

## 設定步驟

### 1. 建立 Supabase 專案
1. 到 <https://supabase.com> 建立一個 Project
2. 進 **SQL Editor**，貼上 `schema.sql` 的內容並執行（建立資料表與權限）

### 2. 填入連線設定
1. Supabase → **Project Settings → API**
2. 複製 **Project URL** 與 **anon public key**
3. 編輯 `config.js`，把兩個值填進去

### 3. 建立你的帳號
- 第一次打開網頁，點「註冊」，用 Email + 密碼建立帳號
- （選用）Supabase → Authentication → Providers → Email，可決定要不要開「Confirm email」信箱驗證

### 4. 本機測試
因為用到瀏覽器模組與 Supabase，建議用簡單的本機伺服器開啟（不要用 file:// 直接開）：

```bash
# 在專案資料夾內
python -m http.server 5500
# 然後瀏覽器開 http://localhost:5500
```

### 5. 部署到 GitHub Pages（雲端）
1. 建一個 GitHub repo，把這個資料夾的檔案 push 上去
2. repo → Settings → Pages → Source 選 `main` 分支 `/root`
3. 幾分鐘後就會有一個網址，手機電腦都能開

> ⚠️ `config.js` 內的 anon key 是「公開金鑰」，本來就設計成可放前端。
> 真正的資料安全由 Supabase 的 Row Level Security 保護（每個帳號只能看到自己的資料）。

---

## 使用說明
- **新增**：右上「＋ 新增紀錄」
- **查詢**：上方工具列可用關鍵字、系統分類、日期區間組合篩選（即時）
- **系統分類**：直接在輸入框打字即可新增；打過的分類會出現在下拉建議
- **匯出 PDF**：
  - 每筆紀錄右下「📄 匯出 PDF」→ 單筆詳情
  - 篩選後點「📄 匯出清單 PDF」→ 目前結果整份報告
