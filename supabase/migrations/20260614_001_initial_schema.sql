create extension if not exists "pgcrypto";

create table if not exists public.seasons (
  id uuid primary key default gen_random_uuid(),
  year integer not null unique check (year >= 2020),
  starts_at date not null,
  ends_at date not null,
  is_active boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint seasons_dates_check check (starts_at <= ends_at)
);

create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  legacy_code text,
  full_name text not null,
  display_name text not null,
  normalized_name text not null unique,
  phone text,
  photo_url text,
  status text not null default 'active' check (status in ('active', 'inactive')),
  notes text,
  registered_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.admin_access (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique,
  email text not null unique,
  role text not null default 'admin' check (role in ('admin', 'editor')),
  is_active boolean not null default true,
  last_login_at timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.system_settings (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  value jsonb not null default '{}'::jsonb,
  description text,
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete restrict,
  match_date date not null,
  start_time time,
  court_name text,
  team_a_player_1_id uuid not null references public.players(id) on delete restrict,
  team_a_player_2_id uuid not null references public.players(id) on delete restrict,
  team_b_player_1_id uuid not null references public.players(id) on delete restrict,
  team_b_player_2_id uuid not null references public.players(id) on delete restrict,
  winner_team text not null check (winner_team in ('A', 'B')),
  result_summary text not null,
  source text not null default 'manual' check (source in ('manual', 'legacy_import')),
  notes text,
  created_by uuid references public.admin_access(id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint matches_distinct_players check (
    team_a_player_1_id <> team_a_player_2_id
    and team_b_player_1_id <> team_b_player_2_id
    and team_a_player_1_id <> team_b_player_1_id
    and team_a_player_1_id <> team_b_player_2_id
    and team_a_player_2_id <> team_b_player_1_id
    and team_a_player_2_id <> team_b_player_2_id
  )
);

create table if not exists public.match_sets (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references public.matches(id) on delete cascade,
  set_order smallint not null check (set_order between 1 and 3),
  team_a_games smallint not null check (team_a_games between 0 and 20),
  team_b_games smallint not null check (team_b_games between 0 and 20),
  is_tiebreak boolean not null default false,
  tiebreak_points_a smallint,
  tiebreak_points_b smallint,
  created_at timestamptz not null default timezone('utc', now()),
  unique (match_id, set_order)
);

create table if not exists public.season_rankings (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  scope text not null check (scope in ('monthly', 'season')),
  scope_month smallint check (scope_month between 1 and 12),
  ranking_position integer not null default 0,
  points integer not null default 0,
  matches_played integer not null default 0,
  wins integer not null default 0,
  losses integer not null default 0,
  win_rate numeric(6, 2) not null default 0,
  sets_won integer not null default 0,
  sets_lost integer not null default 0,
  games_won integer not null default 0,
  games_lost integer not null default 0,
  imported_from_legacy boolean not null default false,
  recorded_at timestamptz not null default timezone('utc', now()),
  unique (season_id, player_id, scope, scope_month)
);

create table if not exists public.player_statistics (
  player_id uuid primary key references public.players(id) on delete cascade,
  season_id uuid references public.seasons(id) on delete cascade,
  matches_played integer not null default 0,
  wins integer not null default 0,
  losses integer not null default 0,
  points integer not null default 0,
  sets_won integer not null default 0,
  sets_lost integer not null default 0,
  games_won integer not null default 0,
  games_lost integer not null default 0,
  best_win_streak integer not null default 0,
  worst_loss_streak integer not null default 0,
  best_month smallint,
  favorite_partner_id uuid references public.players(id) on delete set null,
  best_partner_id uuid references public.players(id) on delete set null,
  most_faced_rival_id uuid references public.players(id) on delete set null,
  hardest_rival_id uuid references public.players(id) on delete set null,
  updated_at timestamptz not null default timezone('utc', now()),
  unique (player_id, season_id)
);

create table if not exists public.player_partners (
  id uuid primary key default gen_random_uuid(),
  season_id uuid references public.seasons(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  partner_id uuid not null references public.players(id) on delete cascade,
  matches_played integer not null default 0,
  wins integer not null default 0,
  losses integer not null default 0,
  win_rate numeric(6, 2) not null default 0,
  updated_at timestamptz not null default timezone('utc', now()),
  unique (season_id, player_id, partner_id),
  constraint player_partner_distinct check (player_id <> partner_id)
);

create table if not exists public.player_rivals (
  id uuid primary key default gen_random_uuid(),
  season_id uuid references public.seasons(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  rival_id uuid not null references public.players(id) on delete cascade,
  matches_played integer not null default 0,
  wins integer not null default 0,
  losses integer not null default 0,
  win_rate numeric(6, 2) not null default 0,
  updated_at timestamptz not null default timezone('utc', now()),
  unique (season_id, player_id, rival_id),
  constraint player_rival_distinct check (player_id <> rival_id)
);

create table if not exists public.hall_of_fame (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons(id) on delete cascade,
  category text not null,
  player_id uuid not null references public.players(id) on delete cascade,
  value_text text,
  value_number numeric(10, 2),
  created_at timestamptz not null default timezone('utc', now()),
  unique (season_id, category)
);

create table if not exists public.legacy_import_rows (
  id uuid primary key default gen_random_uuid(),
  season_id uuid references public.seasons(id) on delete set null,
  sheet_name text not null,
  row_label text not null,
  match_date date,
  metric text not null,
  raw_value text,
  parsed_value numeric(10, 2),
  source_line integer,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_matches_season_date on public.matches (season_id, match_date desc);
create index if not exists idx_match_sets_match on public.match_sets (match_id, set_order);
create index if not exists idx_rankings_season_scope on public.season_rankings (season_id, scope, scope_month, ranking_position);
create index if not exists idx_statistics_season on public.player_statistics (season_id, points desc);
create index if not exists idx_legacy_sheet_metric on public.legacy_import_rows (sheet_name, metric);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists players_touch_updated_at on public.players;
create trigger players_touch_updated_at
before update on public.players
for each row execute function public.touch_updated_at();

drop trigger if exists matches_touch_updated_at on public.matches;
create trigger matches_touch_updated_at
before update on public.matches
for each row execute function public.touch_updated_at();

drop trigger if exists settings_touch_updated_at on public.system_settings;
create trigger settings_touch_updated_at
before update on public.system_settings
for each row execute function public.touch_updated_at();

create or replace view public.ranking_live as
with per_player as (
  select
    m.season_id,
    p.id as player_id,
    p.display_name,
    count(distinct m.id) as matches_played,
    sum(case when (slot.team = m.winner_team) then 1 else 0 end) as wins,
    sum(case when (slot.team <> m.winner_team) then 1 else 0 end) as losses,
    sum(case when (slot.team = m.winner_team) then 3 else 1 end) as points
  from public.matches m
  join lateral (
    values
      (m.team_a_player_1_id, 'A'),
      (m.team_a_player_2_id, 'A'),
      (m.team_b_player_1_id, 'B'),
      (m.team_b_player_2_id, 'B')
  ) as slot(player_id, team) on true
  join public.players p on p.id = slot.player_id
  group by m.season_id, p.id, p.display_name
)
select
  pp.*,
  round((pp.wins::numeric / nullif(pp.matches_played, 0)) * 100, 2) as win_rate
from per_player pp;
