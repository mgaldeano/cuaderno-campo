-- 🔍 SCRIPT DE DEBUGGING PARA VARIEDADES RLS
-- Ejecutar en Supabase SQL Editor para diagnosticar problemas de actualización

-- 1. Verificar estructura de la tabla variedades
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'variedades' 
ORDER BY ordinal_position;

-- 2. Verificar políticas RLS en variedades
SELECT 
    schemaname,
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'variedades';

-- 3. Verificar si RLS está habilitado
SELECT 
    schemaname, 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE tablename = 'variedades';

-- 4. Buscar el registro específico que está fallando
-- Reemplazar 'TU_UUID_AQUI' con: eee681d8-5ae1-434b-9296-85aa0f60d152
SELECT * FROM variedades WHERE id = 'eee681d8-5ae1-434b-9296-85aa0f60d152';

-- 5. Verificar permisos del usuario actual
SELECT current_user, session_user;

-- 6. Intentar actualizar manualmente (reemplazar UUID)
-- UPDATE variedades 
-- SET nombre = 'Test Update' 
-- WHERE id = 'eee681d8-5ae1-434b-9296-85aa0f60d152';

-- 7. Verificar constraints y triggers
SELECT 
    constraint_name, 
    constraint_type, 
    table_name
FROM information_schema.table_constraints 
WHERE table_name = 'variedades';

-- 8. Ver detalles de los constraints CHECK específicos
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint 
WHERE conrelid = 'variedades'::regclass;

-- 9. Ver columnas con restricciones NOT NULL
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'variedades' 
AND is_nullable = 'NO'
ORDER BY ordinal_position;

-- 10. Intentar UPDATE con datos específicos (reemplazar UUID real)
UPDATE variedades 
SET 
    nombre = 'Bonarda Updated',
    especie_id = '550e8400-e29b-41d4-a716-446655440001',
    color = 'tinta',
    tipo_destino = 'tinto'
WHERE id = 'eee681d8-5ae1-434b-9296-85aa0f60d152';

-- 11. Verificar resultado del UPDATE
SELECT ROW_COUNT() as rows_affected;
