-- =====================================================
-- DIAGNOSTICAR Y REPARAR TRIGGER
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. Verificar si el trigger existe
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- 2. Verificar si la función existe
SELECT 
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';

-- 3. Ver los usuarios en auth (los que no tienen registro en usuarios)
-- Esta consulta mostrará qué usuarios de auth no tienen su registro correspondiente
SELECT 
    'Usuario en auth sin registro en usuarios' as estado,
    auth.users.id,
    auth.users.email,
    auth.users.created_at
FROM auth.users 
LEFT JOIN usuarios ON auth.users.id = usuarios.id
WHERE usuarios.id IS NULL
ORDER BY auth.users.created_at;

-- 4. Verificar RLS en tabla usuarios
SELECT schemaname, tablename, rowsecurity, hasrlspolicy
FROM pg_tables t
LEFT JOIN pg_class c ON t.tablename = c.relname
WHERE tablename = 'usuarios';
