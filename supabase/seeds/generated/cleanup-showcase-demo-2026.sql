-- Remove a base showcase de demonstracao
begin;

delete from public.matches
where notes like 'Showcase app demo 2026%';

select public.refresh_season_derived_data(id)
from public.seasons
where year = 2026;

commit;
