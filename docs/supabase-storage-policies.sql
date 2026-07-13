-- ============================================================================
-- XANEE — Policies de Storage para el bucket `scores`
-- Ejecutar en Supabase: SQL Editor → New query → Run.
--
-- Un bucket "público" solo habilita la LECTURA anónima vía URL pública; para
-- SUBIR (insert) hace falta una policy explícita. Estas policies permiten a los
-- usuarios autenticados subir/gestionar partituras en el bucket `scores`.
-- ============================================================================

-- Subir (insert) al bucket `scores` — usuarios autenticados
create policy "xanee_scores_insert"
on storage.objects for insert to authenticated
with check (bucket_id = 'scores');

-- Leer (select) el bucket `scores` — autenticados (la lectura pública anónima ya
-- la habilita el flag "public" del bucket vía la CDN)
create policy "xanee_scores_select"
on storage.objects for select to authenticated
using (bucket_id = 'scores');

-- Actualizar/borrar los propios ficheros — usuarios autenticados
create policy "xanee_scores_update"
on storage.objects for update to authenticated
using (bucket_id = 'scores');

create policy "xanee_scores_delete"
on storage.objects for delete to authenticated
using (bucket_id = 'scores');
