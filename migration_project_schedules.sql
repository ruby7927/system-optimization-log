-- ============================================================
-- 專案排程（每個專案可有多條時間線／畫布）
-- 一個專案(系統分類)可有多列，每列＝一條時間線
-- 讀：擁有者看全部；工程師只看被指派分類。寫：只有擁有者。
-- 依賴 migration_per_engineer_categories.sql 的 is_owner() / can_view_category()
-- Supabase → SQL Editor → 貼上整份 → Run
-- ⚠️ 會重建 project_schedules 表（若先前已建立且有資料，將被清除）
-- ============================================================

drop table if exists public.project_schedules cascade;

create table public.project_schedules (
  id           uuid primary key default gen_random_uuid(),
  category     text not null,                     -- 專案(＝系統分類)
  name         text not null default '排程',      -- 時間線名稱，例：2026下半年排程
  start_date   date,
  end_date     date,
  general_note text,                              -- 整體備註（富文字 HTML）
  milestones   jsonb not null default '[]'::jsonb,-- [{label,date,color,content}]
  sort         int  not null default 0,           -- 同專案內的排序
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists idx_ps_category on public.project_schedules (category, sort);

drop trigger if exists trg_ps_updated_at on public.project_schedules;
create trigger trg_ps_updated_at
  before update on public.project_schedules
  for each row execute function public.set_updated_at();

alter table public.project_schedules enable row level security;

drop policy if exists "ps select by category" on public.project_schedules;
create policy "ps select by category" on public.project_schedules
  for select to authenticated using ( public.can_view_category(category) );

drop policy if exists "ps owner insert" on public.project_schedules;
create policy "ps owner insert" on public.project_schedules
  for insert to authenticated with check ( public.is_owner() );

drop policy if exists "ps owner update" on public.project_schedules;
create policy "ps owner update" on public.project_schedules
  for update to authenticated using ( public.is_owner() ) with check ( public.is_owner() );

drop policy if exists "ps owner delete" on public.project_schedules;
create policy "ps owner delete" on public.project_schedules
  for delete to authenticated using ( public.is_owner() );
