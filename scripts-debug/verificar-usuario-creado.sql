-- =====================================================
-- VERIFICAR USUARIO CREADO Y FUNCIONAMIENTO
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. Ver el último usuario creado
SELECT 
    id,
    email,
    nombre,
    nombre_pila,
    apellido,
    rol,
    perfil_completo,
    organizacion_id,
    created_at
FROM usuarios 
ORDER BY created_at DESC 
LIMIT 3;

-- 2. Verificar si hay usuarios en auth.users también
-- (No podemos consultarlo directamente, pero podemos ver si coinciden los IDs)
