alter table public.matches
  add column if not exists is_walkover boolean not null default false,
  add column if not exists walkover_team text;

alter table public.matches
  drop constraint if exists matches_walkover_team_check;

alter table public.matches
  add constraint matches_walkover_team_check
  check (
    (is_walkover = false and walkover_team is null)
    or (is_walkover = true and walkover_team in ('A', 'B'))
  );

