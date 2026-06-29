alter table public.funny_stories
  add column if not exists author_player_id uuid references public.players(id) on delete restrict;

update public.funny_stories as story
set author_player_id = player.id
from public.players as player
where story.author_player_id is null
  and lower(trim(story.author_name)) = lower(trim(player.display_name));

create or replace function public.sync_funny_story_author()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.author_player_id is null then
    raise exception 'Selecione um jogador cadastrado.';
  end if;

  select display_name
    into new.author_name
  from public.players
  where id = new.author_player_id;

  if new.author_name is null then
    raise exception 'Jogador não encontrado.';
  end if;

  return new;
end;
$$;

drop trigger if exists funny_stories_sync_author on public.funny_stories;
create trigger funny_stories_sync_author
before insert or update of author_player_id, author_name on public.funny_stories
for each row execute function public.sync_funny_story_author();

