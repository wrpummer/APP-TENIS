insert into public.seasons (year, starts_at, ends_at, is_active)
values
  (2025, '2025-01-01', '2025-12-31', false),
  (2026, '2026-01-01', '2026-12-31', true)
on conflict (year) do update
set starts_at = excluded.starts_at,
    ends_at = excluded.ends_at,
    is_active = excluded.is_active;

insert into public.system_settings (key, value, description)
values
  (
    'ranking_rules',
    '{
      "win_points": 3,
      "loss_points": 1,
      "best_of_sets": 3,
      "tiebreak_enabled": true,
      "max_players": 50
    }'::jsonb,
    'Regras oficiais e limites operacionais do grupo.'
  ),
  (
    'branding',
    '{
      "club_name": "Grupo Duplas Trianon",
      "primary_color": "#0a4d3c",
      "accent_color": "#d8ff56"
    }'::jsonb,
    'Configuracoes visuais do aplicativo.'
  ),
  (
    'cost_guardrails',
    '{
      "monthly_budget_brl": 0,
      "max_players": 50,
      "photo_bucket": "player-photos",
      "photo_file_limit_bytes": 1048576,
      "providers": {
        "database": "supabase-free",
        "hosting": "vercel-free",
        "auth": "supabase-email-password",
        "storage": "supabase-storage-free"
      }
    }'::jsonb,
    'Regras de operacao para manter o sistema no plano gratuito.'
  )
on conflict (key) do update
set value = excluded.value,
    description = excluded.description,
    updated_at = timezone('utc', now());
