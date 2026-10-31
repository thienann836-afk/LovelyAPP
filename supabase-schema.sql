-- BAN LINH ONLINE — Supabase schema (run once in SQL Editor)
-- Only public profile + focus totals are online. Journals/check-ins/plans/SOS remain local.

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null default 'Đạo hữu mới' check (char_length(nickname) between 2 and 24),
  avatar text not null default '🧙🏻‍♂️',
  region text not null default '' check (char_length(region) <= 80),
  is_public boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.player_stats (
  user_id uuid primary key references auth.users(id) on delete cascade,
  xp integer not null default 0 check (xp >= 0),
  focus_minutes integer not null default 0 check (focus_minutes >= 0),
  focus_sessions integer not null default 0 check (focus_sessions >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.focus_sessions (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  client_session_id uuid not null,
  minutes integer not null check (minutes in (2,5,10)),
  xp_awarded integer not null default 0 check (xp_awarded between 0 and 20),
  created_at timestamptz not null default now(),
  unique(user_id, client_session_id)
);
create index if not exists focus_sessions_user_created_idx on public.focus_sessions(user_id, created_at desc);
create index if not exists player_stats_xp_idx on public.player_stats(xp desc);

-- Migration compatibility with the earlier MVP SQL package, if it was already run.
alter table public.profiles add column if not exists is_public boolean not null default true;
alter table public.profiles add column if not exists updated_at timestamptz not null default now();
alter table public.player_stats add column if not exists focus_minutes integer not null default 0;
alter table public.player_stats add column if not exists focus_sessions integer not null default 0;
update public.profiles set region = '' where region is null;
alter table public.profiles alter column region set default '';
alter table public.profiles alter column region set not null;
alter table public.profiles alter column avatar set default '🧙🏻‍♂️';
update public.profiles set avatar = '🧙🏻‍♂️'
  where avatar not in ('🧑🏻‍🌾','🧙🏻‍♂️','⚔️','🐉','🌙','🪷','🦊','🦅');
alter table public.profiles drop constraint if exists profiles_avatar_allowed;
alter table public.profiles add constraint profiles_avatar_allowed
  check (avatar in ('🧑🏻‍🌾','🧙🏻‍♂️','⚔️','🐉','🌙','🪷','🦊','🦅'));
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='profiles' and column_name='public_profile'
  ) then
    execute 'update public.profiles set is_public = coalesce(public_profile, true)';
  end if;
end $$;


-- Auth trigger creates an initial public profile and an empty aggregate stats row.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text;
  v_avatar text;
begin
  v_name := case
    when char_length(trim(coalesce(new.raw_user_meta_data->>'nickname',''))) between 2 and 24
      then trim(left(new.raw_user_meta_data->>'nickname',24))
    else 'Đạo hữu mới'
  end;
  v_avatar := case
    when new.raw_user_meta_data->>'avatar' in ('🧑🏻‍🌾','🧙🏻‍♂️','⚔️','🐉','🌙','🪷','🦊','🦅')
      then new.raw_user_meta_data->>'avatar'
    else '🧙🏻‍♂️'
  end;
  insert into public.profiles(id,nickname,avatar) values(new.id,v_name,v_avatar)
    on conflict(id) do nothing;
  insert into public.player_stats(user_id) values(new.id)
    on conflict(user_id) do nothing;
  return new;
end;
$$;
revoke all on function private.handle_new_user() from public, anon, authenticated;
drop trigger if exists on_auth_user_created_banlinh on auth.users;
drop function if exists public.handle_new_user();
drop function if exists public.record_public_activity(integer,integer);
-- Legacy MVP data is retained, but old per-day journal/check-in metadata is no longer
-- accessible through the client API and no old RPC can write to it.
do $$
begin
  if to_regclass('public.activity_daily') is not null then
    execute 'alter table public.activity_daily enable row level security';
    execute 'revoke all on public.activity_daily from anon, authenticated';
  end if;
end $$;
-- The old aggregate focus_blocks is retained for history but is not granted to client roles.

create trigger on_auth_user_created_banlinh
  after insert on auth.users
  for each row execute procedure private.handle_new_user();

alter table public.profiles enable row level security;
alter table public.player_stats enable row level security;
alter table public.focus_sessions enable row level security;

-- Remove broad default privileges, then grant least privilege.
revoke all on public.profiles from anon, authenticated;
revoke all on public.player_stats from anon, authenticated;
revoke all on public.focus_sessions from anon, authenticated;
grant select (id, nickname, avatar, region, is_public) on public.profiles to anon, authenticated;
grant insert (id, nickname, avatar, is_public) on public.profiles to authenticated;
grant update (id, nickname, avatar, region, is_public, updated_at) on public.profiles to authenticated;
grant select (user_id, xp, focus_minutes, focus_sessions) on public.player_stats to anon, authenticated;
-- focus_sessions has no direct client access; only the private RPC may insert rows.

drop policy if exists "profiles public read" on public.profiles;
drop policy if exists "profiles owner update" on public.profiles;
drop policy if exists "stats owner read" on public.player_stats;
drop policy if exists "Public profiles are visible" on public.profiles;
create policy "Public profiles are visible" on public.profiles
  for select to anon, authenticated
  using (is_public = true or id = (select auth.uid()));
drop policy if exists "Users create their own profile" on public.profiles;
create policy "Users create their own profile" on public.profiles
  for insert to authenticated
  with check (id = (select auth.uid()));
drop policy if exists "Users update their own profile" on public.profiles;
create policy "Users update their own profile" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

drop policy if exists "Public stats for public profiles" on public.player_stats;
create policy "Public stats for public profiles" on public.player_stats
  for select to anon, authenticated
  using (
    user_id = (select auth.uid())
    or exists (
      select 1 from public.profiles p
      where p.id = player_stats.user_id and p.is_public = true
    )
  );
drop policy if exists "Users read their own focus sessions" on public.focus_sessions;
create policy "Users read their own focus sessions" on public.focus_sessions
  for select to authenticated
  using (user_id = (select auth.uid()));

-- Private implementation: not exposed through the Supabase Data API.
-- It serializes XP updates per user, checks duplicate session IDs, caps sessions
-- at 6/day and XP at 50/day, and requires a minimum gap matching session length.
create or replace function private.record_focus_session(p_session_id uuid, p_minutes integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_count integer;
  v_today_xp integer;
  v_last timestamptz;
  v_award integer;
  v_today_start timestamptz;
begin
  if v_uid is null then
    raise exception 'Bạn cần đăng nhập trước khi ghi nhận XP.';
  end if;
  if p_session_id is null or p_minutes not in (2,5,10) then
    raise exception 'Phiên tập trung không hợp lệ.';
  end if;

  insert into public.player_stats(user_id) values(v_uid)
    on conflict(user_id) do nothing;
  perform 1 from public.player_stats where user_id = v_uid for update;

  -- Reset the daily XP allowance at midnight in the app's intended timezone.
  v_today_start := date_trunc('day', now() at time zone 'Asia/Ho_Chi_Minh') at time zone 'Asia/Ho_Chi_Minh';
  select count(*), coalesce(sum(xp_awarded),0), max(created_at)
    into v_count, v_today_xp, v_last
    from public.focus_sessions
    where user_id = v_uid and created_at >= v_today_start;

  if v_count >= 6 then
    return jsonb_build_object('ok',false,'message','Bạn đã đạt giới hạn 6 phiên trực tuyến hôm nay. Tiến trình cục bộ vẫn được lưu.');
  end if;
  if v_last is not null and now() - v_last < make_interval(mins => p_minutes) then
    return jsonb_build_object('ok',false,'message','Máy chủ cần thêm thời gian giữa các phiên để hạn chế cộng XP liên tục.');
  end if;

  v_award := least(p_minutes * 2, greatest(0, 50 - v_today_xp));
  insert into public.focus_sessions(user_id,client_session_id,minutes,xp_awarded)
    values(v_uid,p_session_id,p_minutes,v_award)
    on conflict(user_id,client_session_id) do nothing;
  if not found then
    return jsonb_build_object('ok',false,'duplicate',true,'message','Phiên này đã được ghi nhận trước đó.');
  end if;

  update public.player_stats
    set xp = xp + v_award,
        focus_minutes = focus_minutes + p_minutes,
        focus_sessions = focus_sessions + 1,
        updated_at = now()
    where user_id = v_uid;

  return jsonb_build_object('ok',true,'xp_awarded',v_award,'daily_xp',v_today_xp+v_award,'sessions_today',v_count+1);
end;
$$;
revoke all on function private.record_focus_session(uuid,integer) from public, anon;
grant execute on function private.record_focus_session(uuid,integer) to authenticated;

-- Public API wrapper is SECURITY INVOKER; privileged work stays in private schema.
create or replace function public.record_focus_session(p_session_id uuid, p_minutes integer)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.record_focus_session(p_session_id,p_minutes);
$$;
revoke all on function public.record_focus_session(uuid,integer) from public, anon;
grant execute on function public.record_focus_session(uuid,integer) to authenticated;

-- The earlier MVP view had a different column structure; replace it safely.
drop view if exists public.public_leaderboard;
-- The view obeys the RLS policies of its source tables.
create view public.public_leaderboard
with (security_invoker = true)
as
select p.id as user_id, p.nickname, p.avatar, p.region,
       s.xp, s.focus_minutes
from public.profiles p
join public.player_stats s on s.user_id = p.id
where p.is_public = true;
grant select on public.public_leaderboard to anon, authenticated;

comment on table public.profiles is 'Public nickname/avatar/region only. No journals, check-ins, plans or SOS history.';
comment on table public.player_stats is 'Public aggregate XP and focus totals.';
comment on table public.focus_sessions is 'Private focus-session event records used for basic XP rate limiting.';
