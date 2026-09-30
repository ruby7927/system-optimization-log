-- ============================================================
-- 權限改為「依 email 網域」（搭配 Google 登入）
-- 管理者：ruby.hsieh@united-link.com.tw（可編輯全部）
-- @united-link.com.tw → 荷官排班系統 / Incident Reporting System / 請假系統 / 採購系統（唯讀）
-- @north.com.tw       → 請假薪資系統（唯讀）
-- 改寫 is_owner()/can_view_category()/my_view_categories()，四個功能表全部自動套用
-- Supabase → SQL Editor → 貼上整份 → Run
-- ============================================================

-- 1) 管理者名單（完整 email）
create table if not exists public.owners (email text primary key);
alter table public.owners enable row level security;   -- 不建 policy＝前端不可直接讀寫，僅函式判斷
insert into public.owners(email) values ('ruby.hsieh@united-link.com.tw') on conflict do nothing;

-- 2) 網域 → 可見分類
create table if not exists public.viewer_domains (
  domain   text not null,
  category text not null,
  primary key (domain, category)
);
alter table public.viewer_domains enable row level security;
insert into public.viewer_domains(domain, category) values
  ('united-link.com.tw', '荷官排班系統'),
  ('united-link.com.tw', 'Incident Reporting System'),
  ('united-link.com.tw', '請假系統'),
  ('united-link.com.tw', '採購系統'),
  ('north.com.tw',       '請假薪資系統')
on conflict do nothing;

-- 3) 改寫判斷函式（沿用相同名稱，各表 RLS 不用改）
create or replace function public.is_owner()
returns boolean language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.owners o
                 where o.email = lower(auth.jwt() ->> 'email'));
$$;

create or replace function public.can_view_category(cat text)
returns boolean language sql security definer stable set search_path = public as $$
  select
    exists (select 1 from public.owners o
            where o.email = lower(auth.jwt() ->> 'email'))
    or exists (select 1 from public.viewer_domains vd
               where vd.domain = split_part(lower(auth.jwt() ->> 'email'), '@', 2)
                 and vd.category = cat);
$$;

create or replace function public.my_view_categories()
returns setof text language sql security definer stable set search_path = public as $$
  select category from public.viewer_domains
  where domain = split_part(lower(auth.jwt() ->> 'email'), '@', 2);
$$;

grant execute on function public.is_owner() to authenticated;
grant execute on function public.can_view_category(text) to authenticated;
grant execute on function public.my_view_categories() to authenticated;

-- 4) 移除舊的「依 email」對應表（已改用網域，不再需要）
drop table if exists public.viewer_categories;
