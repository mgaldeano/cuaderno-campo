-- =====================================
-- CORRECCIÓN FINAL: Hacer fertilizante_id nullable
-- Fecha: 2025-08-02
-- Problema: fertilizante_id tiene constraint NOT NULL
-- =====================================

-- Permitir valores NULL en la columna original
ALTER TABLE fertilizaciones 
ALTER COLUMN fertilizante_id DROP NOT NULL;

-- Verificar cambio
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fertilizaciones' 
AND column_name LIKE '%fertilizante%'
ORDER BY column_name;
