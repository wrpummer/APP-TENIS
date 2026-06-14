# Ranking Tenis Trianon

Aplicacao web moderna para substituir a planilha de ranking de tenis de duplas, com dashboard publico, area administrativa, importacao de legado Excel, ranking automatico e estrutura pronta para Supabase + Vercel.

## Meta de custo

O projeto foi ajustado para operar integralmente com custo mensal `R$ 0,00`.

- Supabase Free Tier para banco, auth e fotos.
- Vercel Free Tier para hospedagem.
- Nenhuma API paga.
- Nenhum serviço com exigência de cartão.
- Nenhuma biblioteca comercial.

## Stack

- React 19 + TypeScript estrito + Vite
- Material UI
- Supabase (PostgreSQL)
- Recharts
- PWA com `vite-plugin-pwa`
- Deploy em Vercel

## Estrutura

- [apps/web](/C:/Users/wesle/OneDrive/Documentos/New%20project/apps/web): frontend PWA.
- [supabase/migrations](/C:/Users/wesle/OneDrive/Documentos/New%20project/supabase/migrations): schema e funcoes do banco.
- [supabase/seeds](/C:/Users/wesle/OneDrive/Documentos/New%20project/supabase/seeds): dados base e artefatos gerados.
- [scripts](/C:/Users/wesle/OneDrive/Documentos/New%20project/scripts): importacao e auditoria da planilha.
- [docs/architecture.md](/C:/Users/wesle/OneDrive/Documentos/New%20project/docs/architecture.md): organizacao do projeto.
- [docs/cost-model.md](/C:/Users/wesle/OneDrive/Documentos/New%20project/docs/cost-model.md): guardrails para manter custo zero.

## Banco Supabase

Execute as migrations na ordem:

1. `supabase/migrations/20260614_001_initial_schema.sql`
2. `supabase/migrations/20260614_002_refresh_functions.sql`
3. `supabase/migrations/20260614_003_free_tier_policies.sql`
4. `supabase/seeds/001_base_seed.sql`
5. `supabase/seeds/002_sample_data.sql`

Tabelas principais:

- `players`
- `matches`
- `match_sets`
- `season_rankings`
- `player_statistics`
- `player_partners`
- `player_rivals`
- `hall_of_fame`
- `system_settings`
- `admin_access`
- extras de suporte: `seasons`, `legacy_import_rows`

## Variaveis de ambiente

Copie [.env.example](/C:/Users/wesle/OneDrive/Documentos/New%20project/.env.example) para `.env` e preencha:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

## Autenticacao administrativa sem custo

- Use Supabase Auth com email e senha.
- Cadastre o usuário administrador no painel gratuito do Supabase.
- Relacione o `auth_user_id` desse usuário em `public.admin_access`.
- Nao ha dependencia de OAuth pago nem de provedores externos.

## Desenvolvimento local

1. Instale as dependencias do `package.json`.
2. Rode `npm run dev`.
3. Abra `http://localhost:4173`.

## Build de producao

1. Rode `npm run build`.
2. Publique o conteudo de `apps/web/dist` na Vercel.
3. Garanta o rewrite configurado em [vercel.json](/C:/Users/wesle/OneDrive/Documentos/New%20project/vercel.json).

## Importacao da planilha existente

Fonte analisada: [Ranking Tennis 2026.xlsx](/C:/Users/wesle/Downloads/Ranking%20Tennis%202026.xlsx)

### Gerar o diagnostico

```powershell
python scripts/analyze_legacy_ranking.py
```

### Gerar o JSON de migracao

```powershell
python scripts/import_ranking_excel.py
```

Saida esperada:

- `supabase/seeds/generated/legacy-ranking-2026.json`

## Observacoes de compatibilidade

- A planilha atual guarda ranking mensal e anual, e tambem um bloco `RESULTADOS` com partidas em texto livre.
- As abas de `JUN` a `DEZ` trazem datas de 2025, entao o importador nao assume que todas pertencem a 2026.
- Apelidos como `Kadu` ou abreviacoes nao conciliadas sao listados no relatorio para conferencia manual.
- Estatisticas completas de sets e games so ficam 100% confiaveis quando as partidas passam a ser registradas no novo sistema com placar estruturado.

## Guardrails de Free Tier

- Bucket `player-photos` publico com limite de `1 MB` por imagem.
- Politicas RLS publicas apenas para leitura das telas abertas.
- Escrita restrita a administradores autenticados.
- Estrutura dimensionada para ate 50 jogadores e milhares de partidas sem servicos adicionais.
