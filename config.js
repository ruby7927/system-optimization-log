// ============================================================
// Supabase 連線設定
// 到 Supabase Dashboard → Project Settings → API 複製以下兩個值貼上
// ============================================================
window.SUPABASE_CONFIG = {
  url:     "https://zyvkdkmejsatatunvdfs.supabase.co",       // Project URL
  anonKey: "sb_publishable_zsUAVbdBpO4HBN3AtlgSUg_FzYjChQP"   // publishable (anon) key
};

// 擁有者（可編輯）帳號 email，可多個。工程師帳號不在此清單 → 唯讀。
// 留空陣列 = 所有登入者皆可編輯（目前狀態）。
window.APP_CONFIG = {
  ownerEmails: []
};
