-- ============================================================
-- 需求書檔案清單（側邊分頁「需求書」用）
-- 讀：擁有者看全部；工程師只看被指派分類的檔案。寫：只有擁有者。
-- 依賴 migration_per_engineer_categories.sql 的 is_owner() / can_view_category()
-- Supabase → SQL Editor → 貼上整份 → Run
-- ============================================================

create table if not exists public.requirement_files (
  id          uuid primary key default gen_random_uuid(),
  category    text not null,                     -- 所屬系統（＝系統分類）
  file_name   text not null,                     -- 檔案名稱
  file_type   text not null default '文件',      -- 簡報 / 文件 / 試算表 / PDF / 影片 / 其他
  modified_at timestamp not null,                -- 最後修改（本地時間）
  owner       text,                              -- 擁有者
  url         text not null,                     -- 檔案連結
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_rf_category on public.requirement_files (category, modified_at desc);

drop trigger if exists trg_rf_updated_at on public.requirement_files;
create trigger trg_rf_updated_at
  before update on public.requirement_files
  for each row execute function public.set_updated_at();

-- 讓前端能查詢「我這個帳號可看到哪些分類」→ 用來過濾側邊分頁（擁有者回空集合＝全部）
create or replace function public.my_view_categories()
returns setof text language sql security definer stable set search_path = public as $$
  select category from public.viewer_categories where user_email = (auth.jwt() ->> 'email');
$$;
grant execute on function public.my_view_categories() to authenticated;

-- RLS：沿用 optimizations 的分類權限
alter table public.requirement_files enable row level security;

drop policy if exists "rf select by category" on public.requirement_files;
create policy "rf select by category" on public.requirement_files
  for select to authenticated using ( public.can_view_category(category) );

drop policy if exists "rf owner insert" on public.requirement_files;
create policy "rf owner insert" on public.requirement_files
  for insert to authenticated with check ( public.is_owner() );

drop policy if exists "rf owner update" on public.requirement_files;
create policy "rf owner update" on public.requirement_files
  for update to authenticated using ( public.is_owner() ) with check ( public.is_owner() );

drop policy if exists "rf owner delete" on public.requirement_files;
create policy "rf owner delete" on public.requirement_files
  for delete to authenticated using ( public.is_owner() );
