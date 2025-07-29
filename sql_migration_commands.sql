-- =====================================================
-- MIGRACIÓN: Provincia y Departamento de Cuarteles a Fincas
-- =====================================================

-- PASO 1: AGREGAR NUEVOS CAMPOS A LA TABLA FINCAS
-- =====================================================

-- Agregar campos provincia y departamento a la tabla fincas
ALTER TABLE fincas 
ADD COLUMN IF NOT EXISTS provincia TEXT,
ADD COLUMN IF NOT EXISTS departamento TEXT;

-- =====================================================
-- PASO 2: MIGRAR DATOS EXISTENTES (EJECUTAR SOLO UNA VEZ)
-- =====================================================

-- Migrar datos de provincia y departamento desde cuarteles hacia fincas
-- Solo actualiza fincas que no tienen estos datos y cuyos cuarteles sí los tienen
UPDATE fincas 
SET provincia = subquery.provincia,
    departamento = subquery.departamento
FROM (
    SELECT DISTINCT 
        c.finca_id,
        FIRST_VALUE(c.provincia) OVER (
            PARTITION BY c.finca_id 
            ORDER BY c.created_at DESC
        ) as provincia,
        FIRST_VALUE(c.departamento) OVER (
            PARTITION BY c.finca_id 
            ORDER BY c.created_at DESC
        ) as departamento
    FROM cuarteles c
    WHERE c.provincia IS NOT NULL 
       OR c.departamento IS NOT NULL
) as subquery
WHERE fincas.id = subquery.finca_id
  AND (fincas.provincia IS NULL OR fincas.departamento IS NULL);

-- =====================================================
-- PASO 3: VERIFICAR MIGRACIÓN (COMANDOS DE CONSULTA)
-- =====================================================

-- Verificar cuántas fincas tienen ahora provincia/departamento
SELECT 
    COUNT(*) as total_fincas,
    COUNT(provincia) as fincas_con_provincia,
    COUNT(departamento) as fincas_con_departamento
FROM fincas;

-- Verificar datos migrados
SELECT 
    f.id,
    f.nombre_finca,
    f.provincia,
    f.departamento,
    COUNT(c.id) as cuarteles_asociados
FROM fincas f
LEFT JOIN cuarteles c ON c.finca_id = f.id
GROUP BY f.id, f.nombre_finca, f.provincia, f.departamento
ORDER BY f.nombre_finca;

-- =====================================================
-- PASO 4: LIMPIAR TABLA CUARTELES (DESPUÉS DE VERIFICAR)
-- =====================================================

-- IMPORTANTE: Solo ejecutar después de verificar que la migración fue exitosa
-- Comentar/descomentar según sea necesario

-- Eliminar campos provincia y departamento de la tabla cuarteles
-- ALTER TABLE cuarteles 
-- DROP COLUMN IF EXISTS provincia,
-- DROP COLUMN IF EXISTS departamento;

-- =====================================================
-- PASO 5: POLÍTICAS DE SEGURIDAD PARA NUEVOS CAMPOS
-- =====================================================

-- Las políticas existentes para la tabla fincas deberían cubrir automáticamente 
-- los nuevos campos provincia y departamento, pero verificamos:

-- Verificar políticas existentes en fincas
SELECT schemaname, tablename, policyname, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'fincas';

-- Si es necesario, crear políticas específicas para los nuevos campos:

-- Política para SELECT (lectura) - los usuarios pueden ver sus propias fincas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'fincas' AND policyname = 'Users can view own fincas'
    ) THEN
        CREATE POLICY "Users can view own fincas" ON fincas
            FOR SELECT USING (auth.uid() = usuario_id);
    END IF;
END
$$;

-- Política para INSERT (creación) - los usuarios pueden crear fincas para sí mismos
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'fincas' AND policyname = 'Users can insert own fincas'
    ) THEN
        CREATE POLICY "Users can insert own fincas" ON fincas
            FOR INSERT WITH CHECK (auth.uid() = usuario_id);
    END IF;
END
$$;

-- Política para UPDATE (edición) - los usuarios pueden editar sus propias fincas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'fincas' AND policyname = 'Users can update own fincas'
    ) THEN
        CREATE POLICY "Users can update own fincas" ON fincas
            FOR UPDATE USING (auth.uid() = usuario_id);
    END IF;
END
$$;

-- Política para DELETE (eliminación) - los usuarios pueden eliminar sus propias fincas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'fincas' AND policyname = 'Users can delete own fincas'
    ) THEN
        CREATE POLICY "Users can delete own fincas" ON fincas
            FOR DELETE USING (auth.uid() = usuario_id);
    END IF;
END
$$;

-- Habilitar RLS (Row Level Security) si no está habilitado
ALTER TABLE fincas ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- COMANDOS DE ROLLBACK (EN CASO DE PROBLEMAS)
-- =====================================================

-- Si necesitas revertir los cambios:

-- 1. Restaurar datos en cuarteles (solo si tienes backup)
-- UPDATE cuarteles SET provincia = fincas.provincia, departamento = fincas.departamento
-- FROM fincas WHERE cuarteles.finca_id = fincas.id;

-- 2. Eliminar campos de fincas
-- ALTER TABLE fincas 
-- DROP COLUMN IF EXISTS provincia,
-- DROP COLUMN IF EXISTS departamento;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

/*
1. ORDEN DE EJECUCIÓN:
   - Ejecutar PASO 1 primero
   - Verificar que no hay errores
   - Ejecutar PASO 2 para migrar datos
   - Ejecutar PASO 3 para verificar
   - Solo después ejecutar PASO 4 para limpiar

2. BACKUP:
   - Hacer backup de las tablas antes de ejecutar
   - Especialmente importante antes del PASO 4

3. TESTING:
   - Probar en entorno de desarrollo primero
   - Verificar que la aplicación funciona correctamente
   - Confirmar que los datos se muestran correctamente

4. POLÍTICAS:
   - Las políticas existentes deberían cubrir los nuevos campos
   - PASO 5 es principalmente preventivo/verificación
*/
