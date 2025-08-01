-- =====================================================
-- SCRIPT ALTERNATIVO - DESACTIVAR RESTRICCIONES FK
-- =====================================================
-- Este script desactiva temporalmente las restricciones
-- para poder eliminar usuarios sin problemas

-- PASO 1: Crear backup de usuarios
CREATE TABLE usuarios_backup_2025_08_01 AS SELECT * FROM usuarios;

-- PASO 2: Verificar backup
SELECT COUNT(*) as registros_backup FROM usuarios_backup_2025_08_01;

-- PASO 3: Desactivar verificación de claves foráneas temporalmente
SET session_replication_role = replica;

-- PASO 4: Eliminar todos los usuarios
DELETE FROM usuarios;

-- PASO 5: Reactivar verificación de claves foráneas
SET session_replication_role = DEFAULT;

-- PASO 6: Verificar resultado
SELECT 
    COUNT(*) as usuarios_restantes,
    'Usuarios eliminados exitosamente' as resultado
FROM usuarios;

-- NOTA: Las otras tablas mantendrán referencias "huérfanas"
-- que puedes limpiar después si es necesario
