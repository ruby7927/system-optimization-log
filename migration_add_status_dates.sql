-- ============================================================
-- 升級：新增「上 UAT 日期 / 測試完成日期」，更版日期改為含時間
-- 資料表已存在時執行此檔（Supabase → SQL Editor → 貼上 → Run）
-- ============================================================

alter table public.optimizations
  add column if not exists uat_date       date,
  add column if not exists test_done_date date;

-- 更版日期改為含時分秒（timestamp）
alter table public.optimizations
  alter column release_date type timestamp using release_date::timestamp;

-- 篩選改以上 UAT 日期為主
drop index if exists idx_opt_release;
create index if not exists idx_opt_uat on public.optimizations (user_id, uat_date desc);
