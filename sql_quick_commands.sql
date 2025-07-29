-- =====================================================
-- COMANDOS SQL RÁPIDOS - EJECUCIÓN PASO A PASO
-- =====================================================

-- PASO 1: AGREGAR CAMPOS A FINCAS
-- Copiar y pegar en el SQL Editor de Supabase:

ALTER TABLE fincas 
ADD COLUMN IF NOT EXISTS provincia TEXT,
ADD COLUMN IF NOT EXISTS departamento TEXT;

-- =====================================================

-- PASO 2: VERIFICAR QUE LOS CAMPOS SE AGREGARON
-- Copiar y pegar para verificar:

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'fincas'
ORDER BY ordinal_position;

-- =====================================================

-- PASO 3: MIGRAR DATOS DE CUARTELES A FINCAS
-- IMPORTANTE: Solo ejecutar UNA VEZ

UPDATE fincas 
SET provincia = (
    SELECT DISTINCT provincia 
    FROM cuarteles 
    WHERE cuarteles.finca_id = fincas.id 
    AND provincia IS NOT NULL 
    LIMIT 1
),
departamento = (
    SELECT DISTINCT departamento 
    FROM cuarteles 
    WHERE cuarteles.finca_id = fincas.id 
    AND departamento IS NOT NULL 
    LIMIT 1
)
WHERE EXISTS (
    SELECT 1 FROM cuarteles 
    WHERE cuarteles.finca_id = fincas.id 
    AND (provincia IS NOT NULL OR departamento IS NOT NULL)
);

-- =====================================================

-- PASO 4: VERIFICAR MIGRACIÓN
-- Ver cuántos datos se migraron:

SELECT 
    COUNT(*) as total_fincas,
    COUNT(provincia) as fincas_con_provincia,
    COUNT(departamento) as fincas_con_departamento
FROM fincas;

-- Ver datos específicos migrados:
SELECT nombre_finca, provincia, departamento FROM fincas WHERE provincia IS NOT NULL OR departamento IS NOT NULL;

-- =====================================================

-- PASO 5: (OPCIONAL) ELIMINAR CAMPOS DE CUARTELES
-- SOLO ejecutar después de verificar que todo funciona bien:

-- ALTER TABLE cuarteles 
-- DROP COLUMN IF EXISTS provincia,
-- DROP COLUMN IF EXISTS departamento;

-- =====================================================

-- COMANDOS DE EMERGENCIA - ROLLBACK
-- Si algo sale mal, usar estos comandos:

-- Para eliminar los campos agregados a fincas:
-- ALTER TABLE fincas DROP COLUMN IF EXISTS provincia, DROP COLUMN IF EXISTS departamento;

-- =====================================================

-- VERIFICAR POLÍTICAS DE SEGURIDAD EXISTENTES
-- Ver qué políticas tiene la tabla fincas:

SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'fincas';

-- =====================================================
