-- =====================================================
-- DEBUG EXACTO DEL USUARIO GMAIL
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- Ver exactamente qué tiene el usuario Gmail que está causando el problema
SELECT 
    'Debug usuario Gmail exacto' as info,
    email,
    perfil_completo,
    nombre_pila,
    CHAR_LENGTH(nombre_pila) as longitud_nombre_pila,
    ASCII(SUBSTRING(nombre_pila, 1, 1)) as primer_caracter_ascii,
    apellido,
    -- Replicar EXACTAMENTE la lógica del frontend
    CASE 
        WHEN perfil_completo IS NULL THEN 'perfil_completo es NULL'
        WHEN perfil_completo = false THEN 'perfil_completo es FALSE'  
        WHEN perfil_completo = true THEN 'perfil_completo es TRUE'
    END as estado_perfil,
    CASE 
        WHEN nombre_pila IS NULL THEN 'nombre_pila es NULL'
        WHEN TRIM(nombre_pila) = '' THEN 'nombre_pila es STRING VACÍO después de TRIM'
        ELSE 'nombre_pila OK: "' || nombre_pila || '"'
    END as estado_nombre,
    -- La lógica exacta: perfilIncompleto || nombreVacio
    (perfil_completo = false OR perfil_completo IS NULL) as perfil_incompleto,
    (nombre_pila IS NULL OR TRIM(nombre_pila) = '') as nombre_vacio,
    -- Resultado final
    CASE 
        WHEN (perfil_completo = false OR perfil_completo IS NULL) OR (nombre_pila IS NULL OR TRIM(nombre_pila) = '') THEN 'WIZARD'
        ELSE 'DASHBOARD'
    END as decision_final
FROM usuarios 
WHERE email LIKE '%gmail.com'
ORDER BY created_at DESC;
