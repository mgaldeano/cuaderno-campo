-- =====================================================
-- VERIFICAR USUARIO DE GMAIL
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. Ver todos los usuarios registrados
SELECT 
    'Todos los usuarios' as info,
    email,
    perfil_completo,
    nombre_pila,
    apellido,
    rol,
    created_at
FROM usuarios 
ORDER BY created_at DESC;

-- 2. Verificar específicamente usuarios con Gmail
SELECT 
    'Usuarios Gmail' as info,
    email,
    perfil_completo,
    nombre_pila,
    apellido,
    CASE 
        WHEN perfil_completo = false THEN 'WIZARD - Perfil incompleto'
        WHEN nombre_pila IS NULL OR nombre_pila = '' THEN 'WIZARD - Nombre vacío'
        ELSE 'DASHBOARD - Perfil completo'
    END as destino
FROM usuarios 
WHERE email LIKE '%gmail.com'
ORDER BY created_at DESC;

-- 3. Contar usuarios totales
SELECT 
    'Total usuarios' as info,
    COUNT(*) as cantidad
FROM usuarios;
