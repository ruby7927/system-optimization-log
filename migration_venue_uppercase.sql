-- ============================================================
-- 把已存的場地 'siv' 轉成大寫 'SIV'
-- Supabase → SQL Editor → 貼上 → Run
-- ============================================================
update public.optimizations
set venues = array_replace(venues, 'siv', 'SIV')
where venues @> array['siv'];
