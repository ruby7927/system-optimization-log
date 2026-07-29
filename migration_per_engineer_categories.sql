-- ============================================================
-- 每個工程師帳號只能看到「被指派的系統分類」
-- 擁有者(不在對應表) = 看全部可編輯；工程師(在對應表) = 只看指派分類、唯讀
-- Supabase → SQL Editor → 貼上整段 → Run
-- ============================================================

-- 1) 帳號 ↔ 可見分類 對應表
create table if not exists public.viewer_categories (
  user_email text not null,
  category   text not null,
  primary key (user_email, category)
);
-- 開啟 RLS 且不建任何 policy = 前端無法直接讀寫（只透過下方函式判斷）
alter table public.viewer_categories enable row level security;

-- 2) 判斷函式（SECURITY DEFINER：可繞過對應表 RLS 做判斷）
create or replace function public.is_owner()
returns boolean language sql security definer stable set search_path = public as $$
  select not exists (
    select 1 from public.viewer_categories vc
    where vc.user_email = (auth.jwt() ->> 'email')
  );
$$;

create or replace function public.can_view_category(cat text)
returns boolean language sql security definer stable set search_path = public as $$
  select
    -- 擁有者：看全部
    not exists (select 1 from public.viewer_categories vc
                where vc.user_email = (auth.jwt() ->> 'email'))
    -- 工程師：只看被指派的分類
    or exists (select 1 from public.viewer_categories vc
               where vc.user_email = (auth.jwt() ->> 'email') and vc.category = cat);
$$;

grant execute on function public.is_owner() to authenticated;
grant execute on function public.can_view_category(text) to authenticated;

-- 3) 重寫 optimizations 的 RLS
-- 讀取：依可見分類
drop policy if exists "read all authenticated" on public.optimizations;
drop policy if exists "select by category" on public.optimizations;
create policy "select by category" on public.optimizations
  for select to authenticated
  using ( public.can_view_category(category) );

-- 寫入：只有擁有者
drop policy if exists "write except viewer - insert" on public.optimizations;
drop policy if exists "owner write - insert" on public.optimizations;
create policy "owner write - insert" on public.optimizations
  for insert to authenticated
  with check ( public.is_owner() );

drop policy if exists "write except viewer - update" on public.optimizations;
drop policy if exists "owner write - update" on public.optimizations;
create policy "owner write - update" on public.optimizations
  for update to authenticated
  using ( public.is_owner() ) with check ( public.is_owner() );

drop policy if exists "write except viewer - delete" on public.optimizations;
drop policy if exists "owner write - delete" on public.optimizations;
create policy "owner write - delete" on public.optimizations
  for delete to authenticated
  using ( public.is_owner() );

-- 4) 指派各工程師可見的分類
--    ⚠️ 分類名稱必須與你新增紀錄時輸入的「系統分類」完全一致（含空格/大小寫）
insert into public.viewer_categories (user_email, category) values
  ('uleng@optlog.tw',    '荷官排班系統'),
  ('uleng@optlog.tw',    'Incident Reporting System'),
  ('uleng@optlog.tw',    '請假系統'),
  ('uleng@optlog.tw',    '採購系統'),
  ('northeng@optlog.tw', '請假薪資系統')
on conflict do nothing;
