-- =====================================================
-- VERIFICAR ESTADO EXACTO DEL USUARIO GMAIL
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- Verificar TODOS los campos del usuario Gmail
SELECT 
    'Datos completos usuario Gmail' as info,
    id,
    email,
    nombre,
    nombre_pila,
    apellido,
    rol,
    perfil_completo,
    organizacion_id,
    created_at,
    -- Verificar exactamente la lógica del frontend
    CASE 
        WHEN perfil_completo IS NULL THEN 'perfil_completo es NULL'
        WHEN perfil_completo = false THEN 'perfil_completo es FALSE'
        WHEN perfil_completo = true THEN 'perfil_completo es TRUE'
    END as estado_perfil_completo,
    CASE 
        WHEN nombre_pila IS NULL THEN 'nombre_pila es NULL'
        WHEN nombre_pila = '' THEN 'nombre_pila es STRING VACÍO'
        WHEN LENGTH(TRIM(nombre_pila)) = 0 THEN 'nombre_pila es SOLO ESPACIOS'
        ELSE 'nombre_pila tiene contenido: ' || nombre_pila
    END as estado_nombre_pila,
    -- Replicar exactamente la lógica del login-nuevo.html
    CASE 
        WHEN perfil_completo = false OR nombre_pila IS NULL OR TRIM(nombre_pila) = '' THEN 'WIZARD'
        ELSE 'DASHBOARD'
    END as decision_login
FROM usuarios 
WHERE email LIKE '%gmail.com'
ORDER BY created_at DESC;
