-- Remove o lote ficticio gerado para testes
begin;

delete from public.matches
where notes like 'Lote ficticio de teste 2026%';

select public.refresh_season_derived_data(id)
from public.seasons
where year = 2026;

commit;
