-- =====================================================
-- DIAGNOSTICAR ESTRUCTURA REAL DE LA TABLA
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. Ver la estructura REAL de la tabla usuarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- 2. Verificar estado del usuario actual (sin updated_at)
SELECT 
    'Estado del usuario' as info,
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
WHERE email = 'martingaldeano@hotmail.com';

-- 3. Verificar qué devuelve la función verificar_perfil_usuario
SELECT verificar_perfil_usuario() as perfil_estado;

-- 4. Verificar diagnóstico del perfil
SELECT 
    CASE 
        WHEN perfil_completo = true THEN 'Perfil COMPLETO - No debería mostrar wizard'
        WHEN perfil_completo = false THEN 'Perfil INCOMPLETO - Mostrará wizard'
        WHEN perfil_completo IS NULL THEN 'Perfil NULL - Problema en la base de datos'
    END as diagnostico
FROM usuarios 
WHERE email = 'martingaldeano@hotmail.com';
