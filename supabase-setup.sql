-- Αυτοψία: στήσιμο βάσης Supabase (κοινή λίστα για την ομάδα)
-- Τρέξ' το: Supabase › SQL Editor › New query › επικόλληση › Run.
-- Μπορεί να ξανατρέξει χωρίς πρόβλημα. ΠΡΟΣΟΧΗ: σβήνει τον παλιό πίνακα cars αν υπάρχει.

-- 0) Καθάρισμα προηγούμενης (ατομικής) εκδοχής
drop table if exists public.cars cascade;

-- 1) Μέλη: μόνο αυτά τα email βλέπουν και γράφουν δεδομένα
create table if not exists public.members (
  email text primary key check (email = lower(email))
);
alter table public.members enable row level security;
drop policy if exists "members: read own" on public.members;
create policy "members: read own" on public.members
  for select to authenticated using (email = lower(auth.jwt() ->> 'email'));

create or replace function public.is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members where email = lower(auth.jwt() ->> 'email'));
$$;
grant execute on function public.is_member() to authenticated;

-- >>> ΒΑΛΕ ΕΔΩ ΤΑ EMAIL ΤΗΣ ΟΜΑΔΑΣ (με μικρά γράμματα) <<<
insert into public.members (email) values
  ('email-σου@example.com'),
  ('email-γυναίκας@example.com'),
  ('email-υπαλλήλου@example.com')
on conflict do nothing;

-- 2) Κοινός πίνακας αυτοκινήτων
create table public.cars (
  id         text primary key,
  data       jsonb  not null,
  updated_at bigint not null default 0,
  created_by uuid   default auth.uid(),
  synced_at  timestamptz not null default now()
);
create index cars_synced on public.cars (synced_at);

-- synced_at = ώρα του server σε κάθε αλλαγή (για αξιόπιστο συγχρονισμό μεταξύ κινητών)
create or replace function public.touch_synced_at() returns trigger language plpgsql as $$
begin new.synced_at := clock_timestamp(); return new; end $$;
drop trigger if exists cars_touch on public.cars;
create trigger cars_touch before insert or update on public.cars
  for each row execute function public.touch_synced_at();

alter table public.cars enable row level security;
drop policy if exists "cars: members" on public.cars;
create policy "cars: members" on public.cars
  for all to authenticated
  using (public.is_member())
  with check (public.is_member());

-- 3) Ιδιωτικός χώρος για φωτογραφίες
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "photos: own read"   on storage.objects;
drop policy if exists "photos: own insert" on storage.objects;
drop policy if exists "photos: own update" on storage.objects;
drop policy if exists "photos: own delete" on storage.objects;
drop policy if exists "photos: members"    on storage.objects;

create policy "photos: members" on storage.objects
  for all to authenticated
  using (bucket_id = 'photos' and public.is_member())
  with check (bucket_id = 'photos' and public.is_member());

-- Για να προσθέσεις αργότερα μέλος:
--   insert into public.members (email) values ('νέο@email.com');
-- Για να αφαιρέσεις:
--   delete from public.members where email = 'παλιό@email.com';
