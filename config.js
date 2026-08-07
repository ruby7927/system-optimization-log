// ============================================================
// Supabase 連線設定
// 到 Supabase Dashboard → Project Settings → API 複製以下兩個值貼上
// ============================================================
window.SUPABASE_CONFIG = {
  url:     "https://zyvkdkmejsatatunvdfs.supabase.co",       // Project URL
  anonKey: "sb_publishable_zsUAVbdBpO4HBN3AtlgSUg_FzYjChQP"   // publishable (anon) key
};

// 唯讀（工程師）帳號清單：清單內的帳號登入後只能讀，看不到新增/編輯/刪除。
// 各帳號實際看得到哪些系統分類，由資料庫 viewer_categories 對應表控制。
// 其餘帳號（含你自己）皆可編輯。留空 = 所有人可編輯。
window.APP_CONFIG = {
  readonlyEmails: ["uleng@optlog.tw", "northeng@optlog.tw"],

  // 側邊分頁「需求書」：每個系統一個分頁；url 是該系統的雲端資料夾（可留空）
  // 名稱請與「系統分類」一致，工程師才會依權限只看到自己的系統
  requirements: [
    { name: "荷官排班系統",              url: "" },
    { name: "Incident Reporting System", url: "" },
    { name: "請假系統",                  url: "" },
    { name: "採購系統",                  url: "" },
    { name: "請假薪資系統",              url: "" }
  ]
};
