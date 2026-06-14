# Arquitetura do Projeto

## Estrutura

- `apps/web`: SPA React + TypeScript + Material UI + PWA.
- `supabase/migrations`: schema, views, funções e políticas SQL.
- `supabase/seeds`: dados iniciais e configurações padrão.
- `scripts`: importação da planilha Excel e utilitários de auditoria.
- `docs`: documentação de arquitetura e decisões de migração.

## Camadas

1. `src/services`: acesso ao Supabase, queries e mutações.
2. `src/hooks`: composição de dados para telas públicas e administrativas.
3. `src/features`: páginas por domínio de negócio.
4. `src/components`: blocos visuais reutilizáveis.
5. `src/utils`: cálculo de ranking, parsing e exportação.

## Estratégia de Dados

- `matches` armazena a partida em nível de confronto.
- `match_sets` armazena cada set, inclusive super tiebreak.
- `player_statistics`, `player_partners`, `player_rivals` e `hall_of_fame` são tabelas derivadas alimentadas por função SQL.
- `season_rankings` guarda snapshots por mês e por temporada para consultas rápidas.
- `legacy_import_rows` preserva a origem da planilha Excel para auditoria e conciliação.

## Restrições de Custo

- Banco, autenticação e storage usam exclusivamente Supabase Free Tier.
- Deploy e hospedagem frontend usam Vercel Free Tier.
- Fotos de perfil ficam no bucket público `player-photos` com limite de 1 MB por arquivo.
- A autenticação administrativa usa Supabase Auth com email e senha, sem provedores pagos de terceiros.
- O sistema foi desenhado para até 50 jogadores, fotos opcionais e milhares de partidas sem dependência de APIs pagas.
