-- 🔍 VERIFICACIÓN DE ESTRUCTURA ACTUAL PARA REFACTORING AUTH

-- 1. Verificar estructura de tabla usuarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'usuarios'
ORDER BY ordinal_position;

-- 2. Verificar datos actuales en usuarios
SELECT 
    id,
    nombre,
    nombre_pila,
    apellido,
    email,
    rol,
    organizacion_id,
    created_at
FROM usuarios
LIMIT 5;

-- 3. Verificar estructura auth.users metadata
SELECT 
    id,
    email,
    raw_user_meta_data,
    created_at
FROM auth.users
LIMIT 5;

-- 4. Comparar datos entre auth.users y usuarios
SELECT 
    au.id,
    au.email as auth_email,
    au.raw_user_meta_data,
    u.nombre,
    u.email as user_email,
    u.nombre_pila,
    u.apellido
FROM auth.users au
LEFT JOIN usuarios u ON au.id = u.id
LIMIT 5;

-- 5. Verificar políticas RLS actuales
SELECT 
    tablename,
    policyname,
    cmd,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public' 
    AND tablename = 'usuarios'
ORDER BY policyname;
