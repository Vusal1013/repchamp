-- ============================================================
-- RepChamp — Supabase Database Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- 0. Extensions
create extension if not exists "pgcrypto";

-- ============================================================
-- 1. TABLES
-- ============================================================

-- 1a. Profiles (extends auth.users)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  avatar_url text,
  level int default 1,
  xp int default 0,
  streak int default 0,
  created_at timestamptz default now()
);

-- 1b. Workout sessions (solo mode)
create table if not exists workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  exercise_type text not null check (exercise_type in ('push_up', 'squat')),
  rep_count int not null,
  duration_seconds int,
  created_at timestamptz default now()
);

-- 1c. Duel rooms
create table if not exists duel_rooms (
  id uuid primary key default gen_random_uuid(),
  status text default 'waiting' check (status in ('waiting', 'active', 'finished')),
  exercise_type text not null check (exercise_type in ('push_up', 'squat')),
  duration_seconds int default 60,
  start_time timestamptz,
  winner_id uuid references profiles(id),
  created_at timestamptz default now()
);

-- 1d. Duel players (real-time rep tracking)
create table if not exists duel_players (
  id uuid primary key default gen_random_uuid(),
  room_id uuid references duel_rooms(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  reps int default 0,
  ready boolean default false,
  joined_at timestamptz default now(),
  unique(room_id, user_id)
);

-- 1e. Friendships
create table if not exists friendships (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  friend_id uuid references profiles(id) on delete cascade not null,
  status text default 'pending' check (status in ('pending', 'accepted')),
  created_at timestamptz default now(),
  unique(user_id, friend_id)
);

-- ============================================================
-- 2. INDEXES
-- ============================================================

create index if not exists idx_workout_sessions_user_id on workout_sessions(user_id);
create index if not exists idx_workout_sessions_created_at on workout_sessions(created_at desc);
create index if not exists idx_duel_rooms_status on duel_rooms(status);
create index if not exists idx_duel_players_room_id on duel_players(room_id);
create index if not exists idx_friendships_user_id on friendships(user_id);
create index if not exists idx_friendships_friend_id on friendships(friend_id);

-- ============================================================
-- 3. ROW LEVEL SECURITY
-- ============================================================

-- 3a. Profiles
alter table profiles enable row level security;

create policy "Profiles are viewable by everyone"
  on profiles for select
  using (true);

create policy "Users can update their own profile"
  on profiles for update
  using (auth.uid() = id);

create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

-- 3b. Workout sessions
alter table workout_sessions enable row level security;

create policy "Users can view their own workout sessions"
  on workout_sessions for select
  using (auth.uid() = user_id);

create policy "Users can insert their own workout sessions"
  on workout_sessions for insert
  with check (auth.uid() = user_id);

-- 3c. Duel rooms
alter table duel_rooms enable row level security;

create policy "Anyone can view duel rooms"
  on duel_rooms for select
  using (true);

create policy "Authenticated users can create duel rooms"
  on duel_rooms for insert
  with check (auth.role() = 'authenticated');

create policy "Participants can update duel rooms"
  on duel_rooms for update
  using (
    exists (
      select 1 from duel_players
      where room_id = duel_rooms.id
        and user_id = auth.uid()
    )
  );

-- 3d. Duel players
alter table duel_players enable row level security;

create policy "Participants can view duel players in their room"
  on duel_players for select
  using (
    exists (
      select 1 from duel_players dp
      where dp.room_id = duel_players.room_id
        and dp.user_id = auth.uid()
    )
  );

create policy "Users can join a duel room"
  on duel_players for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own duel player row"
  on duel_players for update
  using (auth.uid() = user_id);

-- 3e. Friendships
alter table friendships enable row level security;

create policy "Users can view their own friendships"
  on friendships for select
  using (auth.uid() = user_id or auth.uid() = friend_id);

create policy "Users can send friend requests"
  on friendships for insert
  with check (auth.uid() = user_id);

create policy "Users can update friendships they are involved in"
  on friendships for update
  using (auth.uid() = user_id or auth.uid() = friend_id);

-- ============================================================
-- 4. FUNCTIONS (RPC)
-- ============================================================

-- Leaderboard: top users by total reps across all sessions
create or replace function get_leaderboard(limit_count int default 20)
returns table (
  user_id uuid,
  username text,
  avatar_url text,
  total_reps bigint,
  total_sessions bigint,
  level int,
  streak int
)
language sql
security definer
as $$
  select
    p.id,
    p.username,
    p.avatar_url,
    coalesce(sum(ws.rep_count), 0)::bigint as total_reps,
    count(ws.id)::bigint as total_sessions,
    p.level,
    p.streak
  from profiles p
  left join workout_sessions ws on ws.user_id = p.id
  group by p.id, p.username, p.avatar_url, p.level, p.streak
  order by total_reps desc
  limit limit_count;
$$;

-- Auto-create profile on signup trigger
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', 'user_' || substr(new.id::text, 1, 8))
  );
  return new;
end;
$$;

-- Trigger the function every time a user is created
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
