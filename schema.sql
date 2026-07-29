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
-- 讀：擁有者(不在 viewer_categories)看全部；工程師只看被指派分類
-- 寫：只有擁有者
-- 帳號↔分類對應與函式見 migration_per_engineer_categories.sql
-- ============================================================

-- 帳號 ↔ 可見分類 對應表
create table if not exists public.viewer_categories (
  user_email text not null,
  category   text not null,
  primary key (user_email, category)
);
alter table public.viewer_categories enable row level security;  -- 不建 policy = 前端不可直接存取

-- 判斷函式（SECURITY DEFINER 繞過對應表 RLS）
create or replace function public.is_owner()
returns boolean language sql security definer stable set search_path = public as $$
  select not exists (select 1 from public.viewer_categories vc
                     where vc.user_email = (auth.jwt() ->> 'email'));
$$;
create or replace function public.can_view_category(cat text)
returns boolean language sql security definer stable set search_path = public as $$
  select not exists (select 1 from public.viewer_categories vc
                     where vc.user_email = (auth.jwt() ->> 'email'))
      or exists (select 1 from public.viewer_categories vc
                 where vc.user_email = (auth.jwt() ->> 'email') and vc.category = cat);
$$;
grant execute on function public.is_owner() to authenticated;
grant execute on function public.can_view_category(text) to authenticated;

alter table public.optimizations enable row level security;

drop policy if exists "select by category" on public.optimizations;
create policy "select by category" on public.optimizations
  for select to authenticated using ( public.can_view_category(category) );

drop policy if exists "owner write - insert" on public.optimizations;
create policy "owner write - insert" on public.optimizations
  for insert to authenticated with check ( public.is_owner() );

drop policy if exists "owner write - update" on public.optimizations;
create policy "owner write - update" on public.optimizations
  for update to authenticated using ( public.is_owner() ) with check ( public.is_owner() );

drop policy if exists "owner write - delete" on public.optimizations;
create policy "owner write - delete" on public.optimizations
  for delete to authenticated using ( public.is_owner() );
