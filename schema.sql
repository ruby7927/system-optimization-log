-- ============================================================
-- 系統優化紀錄系統 — Supabase 資料庫 Schema
-- 在 Supabase Dashboard → SQL Editor 貼上執行一次即可
-- ============================================================

-- 優化紀錄主表
create table if not exists public.optimizations (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  category        text not null,                 -- 系統分類（可自由新增）
  title           text not null,                 -- 標題
  description      text,                          -- 說明（做了什麼）
  release_date     date,                          -- 更版日期
  requirement_url  text,                          -- 需求書連結（網址）
  executor         text,                          -- 執行人
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- 常用查詢索引
create index if not exists idx_opt_user        on public.optimizations (user_id);
create index if not exists idx_opt_category    on public.optimizations (user_id, category);
create index if not exists idx_opt_release     on public.optimizations (user_id, release_date desc);

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
-- Row Level Security：每個人只能看到/操作自己的資料
-- ============================================================
alter table public.optimizations enable row level security;

drop policy if exists "own rows - select" on public.optimizations;
create policy "own rows - select" on public.optimizations
  for select using (auth.uid() = user_id);

drop policy if exists "own rows - insert" on public.optimizations;
create policy "own rows - insert" on public.optimizations
  for insert with check (auth.uid() = user_id);

drop policy if exists "own rows - update" on public.optimizations;
create policy "own rows - update" on public.optimizations
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own rows - delete" on public.optimizations;
create policy "own rows - delete" on public.optimizations
  for delete using (auth.uid() = user_id);
