-- ============================================================
-- 工程師公用唯讀帳號 — 資料庫端權限（RLS）
-- 規則：所有登入者可「讀」全部；除了公用帳號外皆可「寫」
-- 公用唯讀帳號 email = engineer@optlog.tw（如要改，下面三處一起改）
-- Supabase → SQL Editor → 貼上 → Run
-- ============================================================

-- 讀取：任何登入者都能看全部紀錄（工程師才看得到你的內容）
drop policy if exists "own rows - select" on public.optimizations;
drop policy if exists "read all authenticated" on public.optimizations;
create policy "read all authenticated" on public.optimizations
  for select to authenticated using (true);

-- 新增：公用唯讀帳號禁止
drop policy if exists "own rows - insert" on public.optimizations;
drop policy if exists "write except viewer - insert" on public.optimizations;
create policy "write except viewer - insert" on public.optimizations
  for insert to authenticated
  with check ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' );

-- 修改：公用唯讀帳號禁止
drop policy if exists "own rows - update" on public.optimizations;
drop policy if exists "write except viewer - update" on public.optimizations;
create policy "write except viewer - update" on public.optimizations
  for update to authenticated
  using      ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' )
  with check ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' );

-- 刪除：公用唯讀帳號禁止
drop policy if exists "own rows - delete" on public.optimizations;
drop policy if exists "write except viewer - delete" on public.optimizations;
create policy "write except viewer - delete" on public.optimizations
  for delete to authenticated
  using ( (auth.jwt() ->> 'email') <> 'engineer@optlog.tw' );
