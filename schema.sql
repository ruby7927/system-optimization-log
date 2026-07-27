-- ============================================================
-- 系統優化紀錄系統 — Supabase 資料庫 Schema
-- 在 Supabase Dashboard → SQL Editor 貼上執行一次即可
-- ============================================================

-- 優化紀錄主表
create table if not exists public.optimizations (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  category        text not null,                 -- 系統分類（可自由新增）
  venues          text[],                        -- 場地（可複選：CB / MX / siv）
  title           text not null,                 -- 標題
  description      text,                          -- 說明（做了什麼）
  uat_date         date,                          -- 上 UAT 日期
  test_done_date   date,                          -- 測試完成日期
  release_date     timestamp,                     -- 更版日期時間（含時分秒）
  requirement_url  text,                          -- 需求書連結（網址）
  executor         text,                          -- 執行人
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
-- 狀態（測試中/測試完成/上正式）由三個日期於前端自動判斷，不另存欄位

-- 常用查詢索引（篩選以上 UAT 日期為主）
create index if not exists idx_opt_user        on public.optimizations (user_id);
create index if not exists idx_opt_category    on public.optimizations (user_id, category);
create index if not exists idx_opt_uat         on public.optimizations (user_id, uat_date desc);

-- updated_at 自動更新
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_opt_updated_at on public.optimizations;
create trigger trg_opt_updated_at
  before update on public.optimizations
  for each row execute function public.set_updated_at();

-- ============================================================
-- Row Level Security
-- 讀：所有登入者可讀全部；寫：除公用唯讀帳號外皆可
-- 公用唯讀帳號 email = engineer@optlog.tw
-- ============================================================
alter table public.optimizations enable row level security;

drop policy if exists "read all authenticated" on public.optimizations;
create policy "read all authenticated" on public.optimizations
  for select to authenticated using (true);

drop policy if exists "write except viewer - insert" on public.optimizations;
create policy "write except viewer - insert" on public.optimizations
  for insert to authenticated
  with check ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' );

drop policy if exists "write except viewer - update" on public.optimizations;
create policy "write except viewer - update" on public.optimizations
  for update to authenticated
  using      ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' )
  with check ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' );

drop policy if exists "write except viewer - delete" on public.optimizations;
create policy "write except viewer - delete" on public.optimizations
  for delete to authenticated
  using ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' );
