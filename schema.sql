-- Guardiões do Clima: esquema dedicado. Execute em projeto Supabase EXCLUSIVO do aplicativo.
create table if not exists public.guardioes_monitors (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null check (role in ('monitor','admin')),
 enabled boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.measurements (
 id uuid primary key default gen_random_uuid(),
 place text not null check(length(btrim(place)) between 1 and 80),
 observed_at timestamptz not null,
 temperature numeric check(temperature between -20 and 65),
 humidity numeric check(humidity between 0 and 100),
 pressure numeric check(pressure between 700 and 1100),
 wind numeric check(wind between 0 and 80),
 rain numeric check(rain between 0 and 2000),
 rain_start timestamptz,
 conditions text check(length(conditions)<=60),
 notes text check(length(notes)<=300),
 created_at timestamptz not null default now(),
 created_by uuid not null default auth.uid() references auth.users(id),
 constraint guardioes_has_metric check(num_nonnulls(temperature,humidity,pressure,wind,rain)>=1),
 constraint guardioes_rain_window check(rain is null or (rain_start is not null and rain_start < observed_at))
);
create index if not exists guardioes_measurements_observed_at_idx on public.measurements(observed_at desc);
alter table public.guardioes_monitors enable row level security;
alter table public.measurements enable row level security;
grant select on public.measurements to anon, authenticated;
grant insert,update,delete on public.measurements to authenticated;
grant select on public.guardioes_monitors to authenticated;
drop policy if exists "public read measurements" on public.measurements;
create policy "public read measurements" on public.measurements for select to anon,authenticated using (true);
drop policy if exists "authenticated insert own measurements" on public.measurements;
create policy "only enabled monitors can publish" on public.measurements for insert to authenticated
 with check (created_by=(select auth.uid()) and exists
 (select 1 from public.guardioes_monitors m where m.user_id=(select auth.uid()) and m.enabled));
create policy "admins can edit measurements" on public.measurements for update to authenticated
 using (exists(select 1 from public.guardioes_monitors m where m.user_id=(select auth.uid()) and m.enabled and m.role='admin'))
 with check (exists(select 1 from public.guardioes_monitors m where m.user_id=(select auth.uid()) and m.enabled and m.role='admin'));
create policy "admins can delete measurements" on public.measurements for delete to authenticated
 using (exists(select 1 from public.guardioes_monitors m where m.user_id=(select auth.uid()) and m.enabled and m.role='admin'));
create policy "monitors see own status" on public.guardioes_monitors for select to authenticated
 using (user_id=(select auth.uid()));
-- A inclusão/revogação de monitores é feita com privilégios administrativos
-- no SQL Editor Supabase, nunca com chave de serviço exposta ao navegador.
-- Exemplo, após criar a conta em Authentication > Users:
-- insert into public.guardioes_monitors(user_id,role)
-- values ('UUID-DA-CONTA','admin');
do $$ begin
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='measurements') then
   alter publication supabase_realtime add table public.measurements;
 end if;
end $$;
