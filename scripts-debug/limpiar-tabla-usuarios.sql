-- =====================================================
-- SCRIPT PARA LIMPIAR TABLA USUARIOS
-- =====================================================
-- Fecha: 2025-08-01
-- Propósito: Eliminar todos los registros de la tabla usuarios
-- ADVERTENCIA: Esta operación no se puede deshacer

-- 1. VERIFICAR CANTIDAD DE REGISTROS ACTUALES
SELECT 
    'usuarios' as tabla,
    COUNT(*) as registros_actuales,
    COUNT(CASE WHEN perfil_completo = true THEN 1 END) as perfiles_completos,
    COUNT(CASE WHEN perfil_completo = false THEN 1 END) as perfiles_incompletos
FROM usuarios;

-- 2. VERIFICAR DEPENDENCIAS (tablas que referencian usuarios)
-- Esto nos ayuda a entender qué otras tablas podrían verse afectadas

SELECT 
    'fincas' as tabla,
    COUNT(*) as registros_dependientes
FROM fincas 
WHERE usuario_id IS NOT NULL
UNION ALL
SELECT 
    'cuarteles' as tabla,
    COUNT(*) as registros_dependientes
FROM cuarteles 
WHERE propietario_id IS NOT NULL
UNION ALL
SELECT 
    'visitas' as tabla,
    COUNT(*) as registros_dependientes
FROM visitas 
WHERE usuario_id IS NOT NULL
UNION ALL
SELECT 
    'tareas' as tabla,
    COUNT(*) as registros_dependientes
FROM tareas 
WHERE responsable_id IS NOT NULL;

-- 3. BACKUP DE DATOS IMPORTANTES (opcional)
-- Crear una tabla temporal con los datos antes de eliminar
CREATE TABLE IF NOT EXISTS usuarios_backup_2025_08_01 AS
SELECT * FROM usuarios;

-- Verificar que el backup se creó correctamente
SELECT COUNT(*) as registros_backup FROM usuarios_backup_2025_08_01;

-- 4. OPCIÓN A: ELIMINAR TODOS LOS REGISTROS (CUIDADO!)
-- Descomenta la siguiente línea solo si estás seguro
-- DELETE FROM usuarios;

-- 5. OPCIÓN B: ELIMINAR SOLO REGISTROS CON PERFIL INCOMPLETO
-- Esta opción es más conservadora
-- DELETE FROM usuarios WHERE perfil_completo = false OR perfil_completo IS NULL;

-- 6. OPCIÓN C: ELIMINAR REGISTROS CREADOS EN LAS ÚLTIMAS 24 HORAS
-- Útil si solo quieres eliminar registros de prueba recientes
-- DELETE FROM usuarios WHERE created_at > NOW() - INTERVAL '24 hours';

-- 7. REINICIAR SECUENCIAS (si las hay)
-- Esto reinicia cualquier contador automático

-- 8. VERIFICAR RESULTADO
SELECT 
    'usuarios' as tabla,
    COUNT(*) as registros_restantes
FROM usuarios;

-- 9. LIMPIAR AUTH.USERS (SOLO SI ES NECESARIO)
-- ADVERTENCIA: Esto eliminará usuarios del sistema de autenticación
-- Solo descomenta si también quieres eliminar las cuentas de auth
-- 
-- Para eliminar usuarios de auth.users, necesitas hacerlo desde el dashboard
-- de Supabase o usar la función administrativa

-- 10. VERIFICACIÓN FINAL
SELECT 
    NOW() as fecha_limpieza,
    (SELECT COUNT(*) FROM usuarios) as usuarios_restantes,
    (SELECT COUNT(*) FROM usuarios_backup_2025_08_01) as backup_registros;

-- =====================================================
-- INSTRUCCIONES DE USO:
-- =====================================================
-- 1. Ejecuta las consultas de verificación (pasos 1-2) primero
-- 2. Decide qué opción usar (A, B, o C)
-- 3. Descomenta SOLO la línea DELETE que quieras usar
-- 4. Ejecuta el script completo
-- 5. Verifica el resultado con las consultas finales
