# Modelo de Custo Zero

Objetivo: manter custo operacional mensal em `R$ 0,00`.

## Serviços aprovados

- Banco de dados: Supabase Free Tier
- Autenticação: Supabase Auth com email e senha
- Armazenamento de fotos: Supabase Storage Free Tier
- Frontend e deploy: Vercel Free Tier

## Regras do projeto

- Não usar APIs pagas.
- Não usar serviços que exijam cartão de crédito.
- Não usar bibliotecas comerciais.
- Não usar autenticação social paga.
- Preferir processamento local, SQL e funções do próprio Supabase.

## Limites operacionais adotados

- Até 50 jogadores ativos/cadastrados.
- Fotos opcionais com compressão sugerida e limite de 1 MB.
- Histórico multitemporada com centenas ou milhares de partidas.
- Gráficos e relatórios gerados no cliente, sem serviços externos.

## Alternativas gratuitas já previstas

- Login administrativo: email e senha do Supabase Auth.
- Compartilhamento de ranking: geração de imagem no navegador.
- Exportações: geração local em frontend ou funções SQL, sem API externa.
