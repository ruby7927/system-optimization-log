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
  readonlyEmails: ["uleng@optlog.tw", "northeng@optlog.tw"]
};
