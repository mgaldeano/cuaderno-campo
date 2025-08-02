-- =====================================
-- MIGRACIÓN SEGURA: fertilizante_id bigint → uuid
-- MANEJO DE DEPENDENCIAS DE VISTAS
-- Fecha: 2025-08-02
-- =====================================

-- FASE 1: INVESTIGACIÓN Y BACKUP
-- ===============================

-- 1.1: Backup completo
CREATE TABLE fertilizaciones_backup_20250802 AS SELECT * FROM fertilizaciones;

-- 1.2: Identificar todas las dependencias
SELECT 
    schemaname,
    viewname as objeto_dependiente,
    'VIEW' as tipo_objeto
FROM pg_views 
WHERE definition ILIKE '%fertilizante_id%'
AND schemaname = 'public'

UNION ALL

SELECT 
    schemaname,
    tablename as objeto_dependiente,
    'TABLE' as tipo_objeto  
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename != 'fertilizaciones';

-- 1.3: Obtener definiciones exactas de las vistas
SELECT 
    'reporte_nutrientes' as vista,
    pg_get_viewdef('reporte_nutrientes'::regclass, true) as definicion
UNION ALL
SELECT 
    'auditoria_global_gap' as vista,
    pg_get_viewdef('auditoria_global_gap'::regclass, true) as definicion;

-- FASE 2: ESTRATEGIA ALTERNATIVA - AGREGAR NUEVA COLUMNA
-- =====================================================

BEGIN;

-- 2.1: Agregar nueva columna UUID sin eliminar la antigua
ALTER TABLE fertilizaciones 
ADD COLUMN fertilizante_uuid UUID;

-- 2.2: Crear relación con tabla fertilizantes
ALTER TABLE fertilizaciones 
ADD CONSTRAINT fk_fertilizaciones_fertilizante_uuid 
FOREIGN KEY (fertilizante_uuid) REFERENCES fertilizantes(id);

-- 2.3: CORRECCIÓN CRÍTICA - Permitir NULL en fertilizante_id
ALTER TABLE fertilizaciones 
ALTER COLUMN fertilizante_id DROP NOT NULL;

-- 2.4: Verificar estructura
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fertilizaciones' 
AND column_name LIKE '%fertilizante%'
ORDER BY column_name;

COMMIT;

-- FASE 3: MIGRACIÓN DE DATOS (SI NECESARIO)
-- =========================================

-- Si hay datos existentes, crear mapeo manual
-- UPDATE fertilizaciones 
-- SET fertilizante_uuid = [mapeo_correspondiente]
-- WHERE fertilizante_id IS NOT NULL;

-- FASE 4: ACTUALIZAR FRONTEND TEMPORALMENTE
-- =========================================
-- El frontend debe usar 'fertilizante_uuid' en lugar de 'fertilizante_id'
-- Esta es una solución temporal hasta poder migrar las vistas

-- FASE 5: PLAN FUTURO - MIGRACIÓN COMPLETA
-- ========================================
-- 1. Actualizar todas las vistas para usar fertilizante_uuid
-- 2. Eliminar fertilizante_id usando CASCADE
-- 3. Renombrar fertilizante_uuid a fertilizante_id
-- 4. Actualizar frontend para volver a usar fertilizante_id
