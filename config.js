// ============================================================
// Supabase 連線設定
// 到 Supabase Dashboard → Project Settings → API 複製以下兩個值貼上
// ============================================================
window.SUPABASE_CONFIG = {
  url:     "https://zyvkdkmejsatatunvdfs.supabase.co",       // Project URL
  anonKey: "sb_publishable_zsUAVbdBpO4HBN3AtlgSUg_FzYjChQP"   // publishable (anon) key
};

// 管理者 email（可編輯全部）。其餘登入者一律唯讀。
// 各人實際看得到哪些系統，由資料庫 viewer_domains（依 email 網域）控制。
window.APP_CONFIG = {
  ownerEmails: ["ruby.hsieh@united-link.com.tw"],

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
