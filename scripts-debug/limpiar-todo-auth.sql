-- =====================================================
-- LIMPIAR TODO Y EMPEZAR DE CERO
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. Limpiar tabla usuarios (ya está vacía pero por seguridad)
DELETE FROM usuarios;

-- 2. Ver usuarios en auth antes de borrar
SELECT 
    'Usuarios en auth antes de limpiar' as estado,
    id, 
    email, 
    created_at 
FROM auth.users 
ORDER BY created_at;

-- 3. BORRAR todos los usuarios de auth
-- CUIDADO: Esto borra TODOS los usuarios de autenticación
DELETE FROM auth.users;

-- 4. Verificar que todo está limpio
SELECT 
    'Usuarios en auth después de limpiar' as estado,
    COUNT(*) as total
FROM auth.users;

SELECT 
    'Usuarios en tabla usuarios después de limpiar' as estado,
    COUNT(*) as total
FROM usuarios;

-- 5. Verificar que el trigger existe y está activo
SELECT 
    'Estado del trigger' as info,
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- RESULTADO ESPERADO:
-- - 0 usuarios en auth.users
-- - 0 usuarios en tabla usuarios  
-- - Trigger activo y funcionando
