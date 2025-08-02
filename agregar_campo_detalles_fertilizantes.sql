-- Script para agregar campo de detalles técnicos a la tabla fertilizantes
-- Ejecutar en Supabase SQL Editor

-- Agregar columna de detalles técnicos
ALTER TABLE fertilizantes 
ADD COLUMN IF NOT EXISTS detalles_tecnicos TEXT;

-- Agregar comentario a la columna
COMMENT ON COLUMN fertilizantes.detalles_tecnicos IS 'Detalles técnicos, aspectos importantes, compatibilidades, recomendaciones de uso, etc.';

-- Verificar la estructura actualizada
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'fertilizantes' 
ORDER BY ordinal_position;

-- Ejemplo de actualización con datos de ejemplo
UPDATE fertilizantes 
SET detalles_tecnicos = CASE 
    WHEN producto ILIKE '%urea%' THEN 'Aplicar preferentemente en horas frescas. Evitar aplicación foliar en días calurosos. Compatible con la mayoría de pesticidas.'
    WHEN producto ILIKE '%fosfato%' THEN 'Excelente para aplicación de arranque. No mezclar con productos alcalinos. Ideal para fertirrigación.'
    WHEN producto ILIKE '%potasio%' THEN 'Mejora resistencia al estrés hídrico. Aplicar durante desarrollo de frutos. Compatible con aplicaciones foliares.'
    WHEN tipo = 'organico' THEN 'Mejora estructura del suelo. Aplicación recomendada en otoño/invierno. Potencia la actividad microbiana.'
    WHEN tipo = 'bioestimulante' THEN 'Aplicar en momentos de estrés de la planta. Respetar intervalos de seguridad. Usar agua de calidad.'
    WHEN tipo = 'hidroponico' THEN 'Solubilidad completa garantizada. Ideal para sistemas de riego automatizado. pH estable en solución.'
    ELSE 'Seguir recomendaciones del fabricante. Almacenar en lugar seco y fresco.'
END
WHERE detalles_tecnicos IS NULL AND producto IS NOT NULL;

-- Mostrar algunos ejemplos
SELECT producto, tipo, detalles_tecnicos
FROM fertilizantes 
WHERE detalles_tecnicos IS NOT NULL
LIMIT 5;
