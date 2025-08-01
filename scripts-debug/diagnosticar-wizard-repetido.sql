-- =====================================================
-- DIAGNOSTICAR PROBLEMA DEL WIZARD
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. Verificar estado del usuario actual
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
    created_at,
    updated_at
FROM usuarios 
WHERE email = 'martingaldeano@hotmail.com';

-- 2. Verificar qué devuelve la función verificar_perfil_usuario
SELECT verificar_perfil_usuario() as perfil_estado;

-- 3. Verificar si el perfil_completo está en true
SELECT 
    CASE 
        WHEN perfil_completo = true THEN 'Perfil COMPLETO - No debería mostrar wizard'
        WHEN perfil_completo = false THEN 'Perfil INCOMPLETO - Mostrará wizard'
        WHEN perfil_completo IS NULL THEN 'Perfil NULL - Problema en la base de datos'
    END as diagnostico
FROM usuarios 
WHERE email = 'martingaldeano@hotmail.com';

-- RESULTADO ESPERADO:
-- Si perfil_completo = false, ahí está el problema
-- Necesitamos actualizarlo a true después de completar el wizard
