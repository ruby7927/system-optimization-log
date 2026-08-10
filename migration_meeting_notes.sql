-- ============================================================
-- 會議記錄（側邊分頁「會議記錄」用，每系統一頁）
-- 讀：擁有者看全部；工程師只看被指派分類。寫：只有擁有者。
-- 依賴 migration_per_engineer_categories.sql 的 is_owner() / can_view_category()
-- Supabase → SQL Editor → 貼上整份 → Run
-- ============================================================

create table if not exists public.meeting_notes (
  id          uuid primary key default gen_random_uuid(),
  category    text not null,                     -- 所屬系統（＝系統分類）
  meet_date   date not null,                     -- 會議日期
  title       text not null,                     -- 主題
  content     text,                              -- 會議內容（富文字 HTML）
  decisions   text,                              -- 決議／待辦事項
  venues      text[],                            -- 場地（CB/MX/SIV，可複選）
  link        text,                              -- 相關連結
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_mn_category on public.meeting_notes (category, meet_date desc);

drop trigger if exists trg_mn_updated_at on public.meeting_notes;
create trigger trg_mn_updated_at
  before update on public.meeting_notes
  for each row execute function public.set_updated_at();

-- RLS：沿用分類權限
alter table public.meeting_notes enable row level security;

drop policy if exists "mn select by category" on public.meeting_notes;
create policy "mn select by category" on public.meeting_notes
  for select to authenticated using ( public.can_view_category(category) );

drop policy if exists "mn owner insert" on public.meeting_notes;
create policy "mn owner insert" on public.meeting_notes
  for insert to authenticated with check ( public.is_owner() );

drop policy if exists "mn owner update" on public.meeting_notes;
create policy "mn owner update" on public.meeting_notes
  for update to authenticated using ( public.is_owner() ) with check ( public.is_owner() );

drop policy if exists "mn owner delete" on public.meeting_notes;
create policy "mn owner delete" on public.meeting_notes
  for delete to authenticated using ( public.is_owner() );
