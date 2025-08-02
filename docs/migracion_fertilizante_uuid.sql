-- =====================================
-- MIGRACIÓN COMPLEJA: fertilizante_id bigint → uuid
-- Fecha: 2025-08-02
-- Proyecto: Cuaderno de Campo
-- NOTA: Maneja dependencias de vistas
-- =====================================

-- 🔍 PASO 1: Identificar dependencias
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views 
WHERE definition LIKE '%fertilizante_id%'
AND schemaname = 'public';

-- 🛡️ PASO 2: Backup de seguridad
CREATE TABLE fertilizaciones_backup_20250802 AS SELECT * FROM fertilizaciones;

-- � PASO 3: Obtener definiciones de vistas dependientes
\d+ reporte_nutrientes
\d+ auditoria_global_gap

-- 🔧 PASO 4: Migración con manejo de dependencias
BEGIN;

-- Guardar definiciones de vistas para recrearlas
-- NOTA: Ejecutar estos SELECTs y guardar los resultados antes de continuar
SELECT pg_get_viewdef('reporte_nutrientes'::regclass, true) as reporte_nutrientes_def;
SELECT pg_get_viewdef('auditoria_global_gap'::regclass, true) as auditoria_global_gap_def;

-- Eliminar vistas dependientes temporalmente
DROP VIEW IF EXISTS reporte_nutrientes CASCADE;
DROP VIEW IF EXISTS auditoria_global_gap CASCADE;

-- Eliminar restricciones existentes
ALTER TABLE fertilizaciones 
DROP CONSTRAINT IF EXISTS fertilizaciones_fertilizante_id_fkey;

-- Renombrar columna existente en lugar de eliminar
ALTER TABLE fertilizaciones 
RENAME COLUMN fertilizante_id TO fertilizante_id_old;

-- Agregar nueva columna UUID
ALTER TABLE fertilizaciones 
ADD COLUMN fertilizante_id UUID REFERENCES fertilizantes(id);

-- CONFIRMAR ANTES DE CONTINUAR
COMMIT;

-- 🔄 PASO 5: Recrear vistas (EJECUTAR DESPUÉS DE VERIFICAR)
-- NOTA: Estas definiciones deberán ser actualizadas manualmente
-- CREATE VIEW reporte_nutrientes AS [definición actualizada];
-- CREATE VIEW auditoria_global_gap AS [definición actualizada];

-- ✅ PASO 6: Verificar resultado
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fertilizaciones' 
AND column_name LIKE '%fertilizante_id%';
