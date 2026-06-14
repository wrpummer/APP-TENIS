alter table public.match_sets
  add column if not exists is_super_tiebreak boolean not null default false,
  add column if not exists deuces_count smallint,
  add column if not exists set_notes text;

alter table public.match_sets
  drop constraint if exists match_sets_deuces_count_check;

alter table public.match_sets
  add constraint match_sets_deuces_count_check
  check (deuces_count is null or deuces_count between 0 and 30);
