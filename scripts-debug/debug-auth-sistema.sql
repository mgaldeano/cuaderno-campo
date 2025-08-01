-- =====================================================
-- DEBUG: VERIFICAR CONFIGURACIÓN DEL SISTEMA AUTH
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. Verificar que la columna perfil_completo existe
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
AND column_name = 'perfil_completo';

-- 2. Verificar que el trigger existe
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'usuarios'
AND trigger_name = 'on_auth_user_created';

-- 3. Verificar que las funciones RPC existen
SELECT 
    routine_name,
    routine_type,
    external_language
FROM information_schema.routines 
WHERE routine_name IN ('completar_setup_usuario', 'verificar_perfil_usuario')
AND routine_type = 'FUNCTION';

-- 4. Verificar políticas RLS en tabla usuarios
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'usuarios';

-- 5. Probar la función completar_setup_usuario manualmente
-- (Esto fallará si no hay usuario autenticado, pero nos dirá si existe)
SELECT 'Función completar_setup_usuario existe' as resultado
WHERE EXISTS (
    SELECT 1 FROM information_schema.routines 
    WHERE routine_name = 'completar_setup_usuario'
);

-- 6. Verificar permisos de la función
SELECT 
    routine_name,
    grantee,
    privilege_type
FROM information_schema.routine_privileges 
WHERE routine_name = 'completar_setup_usuario';

-- 7. Verificar estructura completa de la tabla usuarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- 8. Verificar todos los registros en tabla usuarios (sin columnas específicas)
SELECT * FROM usuarios 
ORDER BY created_at DESC 
LIMIT 5;
