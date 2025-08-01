-- =====================================================
-- SCRIPT DIRECTO PARA SUPABASE - LIMPIAR TABLA USUARIOS
-- VERSIÓN CORREGIDA CON APLICADORES_OPERARIOS
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor
-- Fecha: 2025-08-01

-- PASO 1: Verificar registros actuales
SELECT 'usuarios' as tabla, COUNT(*) as registros FROM usuarios
UNION ALL
SELECT 'aplicadores_operarios' as tabla, COUNT(*) as registros FROM aplicadores_operarios;

-- PASO 2: Eliminar aplicadores_operarios que referencian usuarios
DELETE FROM aplicadores_operarios WHERE usuario_id IS NOT NULL;

-- PASO 3: Desactivar verificación de claves foráneas temporalmente
SET session_replication_role = replica;

-- PASO 4: Eliminar todos los usuarios
DELETE FROM usuarios;

-- PASO 5: Reactivar verificación de claves foráneas
SET session_replication_role = DEFAULT;

-- PASO 6: Verificar resultado final
SELECT 'usuarios' as tabla, COUNT(*) as registros_restantes FROM usuarios
UNION ALL
SELECT 'aplicadores_operarios' as tabla, COUNT(*) as registros_restantes FROM aplicadores_operarios WHERE usuario_id IS NOT NULL;

-- PASO 7: Confirmar operación
SELECT 
    NOW() as fecha_limpieza,
    'Usuarios y aplicadores_operarios eliminados exitosamente' as resultado;
