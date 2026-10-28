-- Rode no SQL Editor do Supabase. Ative Realtime > publications > supabase_realtime para public.measurements.
-- Crie usuários em Authentication > Users; sem cadastro público para impedir escrita anônima.
create table if not exists public.measurements (
 id uuid primary key default gen_random_uuid(),
 place text not null check(length(place) between 1 and 80),
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
 created_by uuid not null default auth.uid(),
 constraint at_least_one_metric check(num_nonnulls(temperature,humidity,pressure,wind,rain)>=1),
 constraint rain_interval check(rain is null or (rain_start is not null and rain_start < observed_at))
);
alter table public.measurements enable row level security;
-- Todos podem ler. Apenas contas autorizadas podem escrever.
create policy "public read measurements" on public.measurements for select to anon, authenticated using (true);
create policy "authenticated insert own measurements" on public.measurements for insert to authenticated with check (created_by=auth.uid());
-- Para impedir que qualquer conta nova publique, desative cadastro público no Auth e crie contas manualmente.
-- Se seu projeto também permite outras contas, substitua a política de INSERT por uma lista explícita de monitores.
alter publication supabase_realtime add table public.measurements;
