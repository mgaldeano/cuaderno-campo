-- =====================================================
-- SCRIPT DE VERIFICACIÓN DE COLUMNAS
-- =====================================================
-- Ejecutar PRIMERO para ver qué columnas existen realmente

-- Verificar columnas de la tabla usuarios
SELECT 'usuarios' as tabla, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- Verificar columnas de la tabla tareas
SELECT 'tareas' as tabla, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tareas' 
ORDER BY ordinal_position;

-- Verificar columnas de la tabla visitas
SELECT 'visitas' as tabla, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'visitas' 
ORDER BY ordinal_position;

-- Verificar columnas de la tabla cuarteles
SELECT 'cuarteles' as tabla, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'cuarteles' 
ORDER BY ordinal_position;

-- Verificar columnas de la tabla fincas
SELECT 'fincas' as tabla, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'fincas' 
ORDER BY ordinal_position;

-- Verificar columnas de la tabla aplicadores_operarios
SELECT 'aplicadores_operarios' as tabla, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'aplicadores_operarios' 
ORDER BY ordinal_position;
