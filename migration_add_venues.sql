-- ============================================================
-- 升級：新增「場地」欄位（可複選 CB / MX / siv）
-- Supabase → SQL Editor → 貼上 → Run
-- ============================================================
alter table public.optimizations
  add column if not exists venues text[];
