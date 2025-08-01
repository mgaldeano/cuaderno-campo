-- =====================================================
-- VERIFICAR PROBLEMA ESPECÍFICO DEL WIZARD
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- Verificar EXACTAMENTE qué campos tiene tu usuario
SELECT 
    'Datos detallados del usuario' as info,
    email,
    perfil_completo,
    nombre_pila,
    apellido,
    nombre,
    CASE 
        WHEN perfil_completo = false THEN 'PROBLEMA: perfil_completo es false'
        WHEN nombre_pila IS NULL OR nombre_pila = '' THEN 'PROBLEMA: nombre_pila está vacío'
        WHEN apellido IS NULL OR apellido = '' THEN 'PROBLEMA: apellido está vacío'
        ELSE 'TODO BIEN: Debería ir al dashboard'
    END as diagnostico_wizard
FROM usuarios 
WHERE email = 'martingaldeano@hotmail.com';

-- Esta consulta replica exactamente lo que hace el frontend:
-- return !data.perfil_completo || !data.nombre_pila;
SELECT 
    'Lógica del frontend' as info,
    perfil_completo,
    nombre_pila,
    CASE 
        WHEN perfil_completo = false OR nombre_pila IS NULL OR nombre_pila = '' THEN 
            'WIZARD - Frontend enviará al wizard'
        ELSE 
            'DASHBOARD - Frontend enviará al dashboard'
    END as decision_frontend
FROM usuarios 
WHERE email = 'martingaldeano@hotmail.com';
