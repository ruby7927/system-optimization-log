-- ============================================================
-- 專案排程（側邊分頁「專案排程」用）
-- 每個專案(系統分類)一列；里程碑以 JSONB 陣列儲存
-- 讀：擁有者看全部；工程師只看被指派分類。寫：只有擁有者。
-- 依賴 migration_per_engineer_categories.sql 的 is_owner() / can_view_category()
-- Supabase → SQL Editor → 貼上整份 → Run
-- ============================================================

create table if not exists public.project_schedules (
  category     text primary key,                  -- 專案(＝系統分類)
  start_date   date,                              -- 專案開始
  end_date     date,                              -- 專案結束
  general_note text,                              -- 整體專案備註（富文字 HTML）
  milestones   jsonb not null default '[]'::jsonb,-- [{label,date,color,content}]
  updated_at   timestamptz not null default now()
);

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
