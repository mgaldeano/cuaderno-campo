-- Script para actualizar tabla fertilizaciones existente
-- Agregar nuevas columnas enfocadas en cantidades reales

-- 1. AGREGAR COLUMNAS DE DOSIS DE REFERENCIA
ALTER TABLE fertilizaciones 
ADD COLUMN IF NOT EXISTS dosis_referencia DECIMAL(10,2);

ALTER TABLE fertilizaciones 
ADD COLUMN IF NOT EXISTS unidad_dosis_referencia VARCHAR(20) DEFAULT 'kg/ha';

-- 2. AGREGAR COLUMNAS DE CANTIDADES REALES (PRINCIPALES)
ALTER TABLE fertilizaciones 
ADD COLUMN IF NOT EXISTS cantidad_aplicada DECIMAL(10,2);

ALTER TABLE fertilizaciones 
ADD COLUMN IF NOT EXISTS unidad_cantidad VARCHAR(20) DEFAULT 'kg';

ALTER TABLE fertilizaciones 
ADD COLUMN IF NOT EXISTS superficie_cuartel DECIMAL(10,2);

ALTER TABLE fertilizaciones 
ADD COLUMN IF NOT EXISTS dosis_real_calculada DECIMAL(10,2);

-- 3. AGREGAR COLUMNA SISTEMA_APLICACION SI NO EXISTE
ALTER TABLE fertilizaciones 
ADD COLUMN IF NOT EXISTS sistema_aplicacion VARCHAR(30);

-- 4. HACER cantidad_aplicada NOT NULL después de agregar datos
-- (Primero necesitamos agregar la columna, luego la haremos obligatoria)

-- 5. ACTUALIZAR COMENTARIOS DE COLUMNAS
COMMENT ON COLUMN fertilizaciones.dosis_referencia IS 'Dosis recomendada por fabricante (referencia orientativa)';
COMMENT ON COLUMN fertilizaciones.cantidad_aplicada IS 'Cantidad real aplicada en el cuartel (campo principal para inventario)';
COMMENT ON COLUMN fertilizaciones.unidad_cantidad IS 'Unidad de la cantidad real aplicada (kg, l, gr, ml)';
COMMENT ON COLUMN fertilizaciones.superficie_cuartel IS 'Superficie específica del cuartel tratado';
COMMENT ON COLUMN fertilizaciones.dosis_real_calculada IS 'Dosis real por hectárea = cantidad_aplicada / superficie_cuartel';
COMMENT ON COLUMN fertilizaciones.sistema_aplicacion IS 'Tipo de fertilización (inorganico, organico, foliares, etc.)';

-- 6. CREAR ÍNDICES ADICIONALES PARA OPTIMIZAR CONSULTAS
CREATE INDEX IF NOT EXISTS idx_fertilizaciones_cantidad ON fertilizaciones(cantidad_aplicada);
CREATE INDEX IF NOT EXISTS idx_fertilizaciones_sistema ON fertilizaciones(sistema_aplicacion);

-- 7. VERIFICAR ESTRUCTURA ACTUALIZADA
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'fertilizaciones' 
ORDER BY ordinal_position;
