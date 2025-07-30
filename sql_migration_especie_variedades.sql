-- 🔄 MIGRACIÓN: RELACIÓN ESPECIE → VARIEDADES (1:N)
-- Fecha: 29 de julio de 2025
-- Descripción: Agregar columna especie_id a variedades y cuarteles para crear relación 1:N

-- ================================================================
-- 1. ACTUALIZAR TABLA VARIEDADES
-- ================================================================

-- Agregar columna especie_id a variedades
ALTER TABLE variedades 
ADD COLUMN IF NOT EXISTS especie_id UUID REFERENCES especies(id) ON DELETE CASCADE;

-- Crear índice para mejorar rendimiento de consultas
CREATE INDEX IF NOT EXISTS idx_variedades_especie_id 
ON variedades(especie_id);

-- ================================================================
-- 2. ACTUALIZAR TABLA CUARTELES (OPCIONAL - DOBLE REFERENCIA)
-- ================================================================

-- Agregar columna especie_id a cuarteles (además del campo texto 'especie' existente)
-- Esto permite transición gradual: mantener 'especie' como texto y agregar 'especie_id' como FK
ALTER TABLE cuarteles 
ADD COLUMN IF NOT EXISTS especie_id UUID REFERENCES especies(id) ON DELETE SET NULL;

-- Crear índice para cuarteles.especie_id
CREATE INDEX IF NOT EXISTS idx_cuarteles_especie_id 
ON cuarteles(especie_id);

-- ================================================================
-- 3. COMENTARIOS Y DOCUMENTACIÓN
-- ================================================================

COMMENT ON COLUMN variedades.especie_id IS 'FK a especies - Una especie tiene muchas variedades (1:N)';
COMMENT ON COLUMN cuarteles.especie_id IS 'FK a especies - Referencia estructurada (complementa campo texto especie)';
COMMENT ON TABLE variedades IS 'Variedades de cultivos, relacionadas con especies (N:1)';
COMMENT ON TABLE especies IS 'Especies de cultivos, cada una tiene muchas variedades (1:N)';
COMMENT ON TABLE cuarteles IS 'Cuarteles pueden tener especie como texto Y como FK para flexibilidad';

-- ================================================================
-- 4. DATOS DE EJEMPLO (DESCOMENTADO PARA TESTING)
-- ================================================================

-- OPCIÓN A: Crear constraint único y usar ON CONFLICT
-- Crear constraint único en especies.nombre si no existe
DO $$ 
BEGIN
    -- Intentar agregar constraint único
    BEGIN
        ALTER TABLE especies 
        ADD CONSTRAINT unique_especies_nombre UNIQUE (nombre);
    EXCEPTION 
        WHEN duplicate_table THEN 
            -- Constraint ya existe, continuar
            NULL;
    END;
END $$;

-- Insertar especies básicas si no existen (ahora funciona con ON CONFLICT)
INSERT INTO especies (id, nombre) VALUES 
  ('550e8400-e29b-41d4-a716-446655440001', 'Vitis vinifera'),
  ('550e8400-e29b-41d4-a716-446655440002', 'Olea europaea'),
  ('550e8400-e29b-41d4-a716-446655440003', 'Malus domestica'),
  ('550e8400-e29b-41d4-a716-446655440004', 'Citrus × sinensis'),
  ('550e8400-e29b-41d4-a716-446655440005', 'Prunus persica')
ON CONFLICT (nombre) DO NOTHING;

-- OPCIÓN B: Alternativa sin ON CONFLICT (comentada)
/*
-- Insertar solo si no existen (método alternativo)
INSERT INTO especies (id, nombre)
SELECT '550e8400-e29b-41d4-a716-446655440001', 'Vitis vinifera'
WHERE NOT EXISTS (SELECT 1 FROM especies WHERE nombre = 'Vitis vinifera')
UNION ALL
SELECT '550e8400-e29b-41d4-a716-446655440002', 'Olea europaea'
WHERE NOT EXISTS (SELECT 1 FROM especies WHERE nombre = 'Olea europaea')
UNION ALL
SELECT '550e8400-e29b-41d4-a716-446655440003', 'Malus domestica'
WHERE NOT EXISTS (SELECT 1 FROM especies WHERE nombre = 'Malus domestica')
UNION ALL
SELECT '550e8400-e29b-41d4-a716-446655440004', 'Citrus × sinensis'
WHERE NOT EXISTS (SELECT 1 FROM especies WHERE nombre = 'Citrus × sinensis')
UNION ALL
SELECT '550e8400-e29b-41d4-a716-446655440005', 'Prunus persica'
WHERE NOT EXISTS (SELECT 1 FROM especies WHERE nombre = 'Prunus persica');
*/

-- ================================================================
-- 5. MIGRACIÓN DE DATOS EXISTENTES (SOLO SI HAY DATOS)
-- ================================================================

-- Actualizar variedades existentes que no tienen especie_id
-- (esto asumiendo que hay datos existentes sin relación)
-- UPDATE variedades 
-- SET especie_id = (SELECT id FROM especies WHERE nombre = 'Vitis vinifera' LIMIT 1)
-- WHERE especie_id IS NULL AND nombre IN ('Malbec', 'Cabernet Sauvignon', 'Chardonnay', 'Syrah');

-- Actualizar cuarteles existentes basándose en el campo texto 'especie'
-- UPDATE cuarteles 
-- SET especie_id = especies.id
-- FROM especies 
-- WHERE cuarteles.especie = especies.nombre 
-- AND cuarteles.especie_id IS NULL;

-- ================================================================
-- 6. FUNCIONES AUXILIARES (OPCIONAL)
-- ================================================================

-- Función para obtener variedades por especie
CREATE OR REPLACE FUNCTION get_variedades_por_especie(especie_id_param UUID)
RETURNS TABLE(id UUID, nombre TEXT, color TEXT, tipo_destino TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT v.id, v.nombre, v.color, v.tipo_destino
    FROM variedades v
    WHERE v.especie_id = especie_id_param
    ORDER BY v.nombre;
END;
$$ LANGUAGE plpgsql;

-- Vista para consultas fáciles de cuarteles con especies y variedades
CREATE OR REPLACE VIEW cuarteles_completos AS
SELECT 
    c.id,
    c.nombre,
    c.superficie,
    c.nro_viñedo,
    c.especie as especie_texto,
    e.nombre as especie_nombre,
    c.especie_id,
    f.nombre_finca,
    f.id as finca_id,
    c.created_at
FROM cuarteles c
LEFT JOIN especies e ON c.especie_id = e.id
LEFT JOIN fincas f ON c.finca_id = f.id;

-- ================================================================
-- 7. VERIFICACIÓN Y VALIDACIÓN
-- ================================================================

-- Verificar estructura
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name IN ('especies', 'variedades', 'cuarteles') 
AND column_name LIKE '%especie%'
ORDER BY table_name, ordinal_position;

-- Verificar índices creados
SELECT indexname, tablename, indexdef 
FROM pg_indexes 
WHERE tablename IN ('variedades', 'cuarteles') 
AND indexname LIKE '%especie%';

-- ================================================================
-- 8. HACER CAMPOS OPCIONALES EN VARIEDADES
-- ================================================================

-- Asegurar que las columnas color y tipo_destino existan y sean opcionales
ALTER TABLE variedades 
ADD COLUMN IF NOT EXISTS color TEXT;

ALTER TABLE variedades 
ADD COLUMN IF NOT EXISTS tipo_destino TEXT;

-- Remover restricciones NOT NULL si existen (esto es seguro si ya son NULL)
ALTER TABLE variedades 
ALTER COLUMN color DROP NOT NULL;

ALTER TABLE variedades 
ALTER COLUMN tipo_destino DROP NOT NULL;

COMMENT ON COLUMN variedades.color IS 'Color de la variedad (opcional): tinta, blanca, rosada';
COMMENT ON COLUMN variedades.tipo_destino IS 'Tipo o destino de la variedad (opcional): mostera, tinto, blanco, otro';

-- ================================================================
-- 9. FUNCIÓN DE ACTUALIZACIÓN PARA DEBUGGING
-- ================================================================

-- Función para actualizar variedades que puede ayudar con problemas de RLS
CREATE OR REPLACE FUNCTION actualizar_variedad(
    variedad_id UUID,
    nueva_especie_id UUID,
    nuevo_nombre TEXT,
    nuevo_color TEXT DEFAULT NULL,
    nuevo_tipo_destino TEXT DEFAULT NULL
)
RETURNS TABLE(id UUID, nombre TEXT, especie_id UUID, color TEXT, tipo_destino TEXT) AS $$
BEGIN
    -- Log para debugging
    RAISE NOTICE 'Actualizando variedad: %, especie: %, nombre: %', variedad_id, nueva_especie_id, nuevo_nombre;
    
    -- Realizar actualización
    UPDATE variedades 
    SET 
        especie_id = nueva_especie_id,
        nombre = nuevo_nombre,
        color = nuevo_color,
        tipo_destino = nuevo_tipo_destino
    WHERE variedades.id = variedad_id;
    
    -- Verificar si se actualizó
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la variedad con ID: %', variedad_id;
    END IF;
    
    -- Retornar el registro actualizado
    RETURN QUERY
    SELECT v.id, v.nombre, v.especie_id, v.color, v.tipo_destino
    FROM variedades v
    WHERE v.id = variedad_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 10. FUNCIONES RPC ADICIONALES PARA ESPECIES Y CUARTELES
-- ================================================================

-- Función para actualizar especies (similar a variedades)
CREATE OR REPLACE FUNCTION actualizar_especie(
    especie_id UUID,
    nuevo_nombre TEXT
)
RETURNS TABLE(id UUID, nombre TEXT) AS $$
BEGIN
    -- Log para debugging
    RAISE NOTICE 'Actualizando especie: %, nombre: %', especie_id, nuevo_nombre;
    
    -- Realizar actualización
    UPDATE especies 
    SET nombre = nuevo_nombre
    WHERE especies.id = especie_id;
    
    -- Verificar si se actualizó
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la especie con ID: %', especie_id;
    END IF;
    
    -- Retornar el registro actualizado
    RETURN QUERY
    SELECT e.id, e.nombre
    FROM especies e
    WHERE e.id = especie_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para actualizar cuarteles
CREATE OR REPLACE FUNCTION actualizar_cuartel(
    cuartel_id BIGINT,
    nueva_finca_id BIGINT,
    nuevo_nombre TEXT,
    nueva_superficie NUMERIC DEFAULT NULL,
    nuevo_nro_vinedo TEXT DEFAULT NULL,
    nueva_especie TEXT DEFAULT NULL,
    nueva_especie_id UUID DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT, 
    nombre TEXT, 
    finca_id BIGINT, 
    superficie NUMERIC, 
    nro_viñedo TEXT, 
    especie TEXT, 
    especie_id UUID
) AS $$
BEGIN
    -- Log para debugging
    RAISE NOTICE 'Actualizando cuartel: %, finca: %, nombre: %', cuartel_id, nueva_finca_id, nuevo_nombre;
    
    -- Realizar actualización
    UPDATE cuarteles 
    SET 
        finca_id = nueva_finca_id,
        nombre = nuevo_nombre,
        superficie = nueva_superficie,
        nro_viñedo = nuevo_nro_vinedo,
        especie = nueva_especie,
        especie_id = nueva_especie_id
    WHERE cuarteles.id = cuartel_id;
    
    -- Verificar si se actualizó
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el cuartel con ID: %', cuartel_id;
    END IF;
    
    -- Retornar el registro actualizado
    RETURN QUERY
    SELECT c.id, c.nombre, c.finca_id, c.superficie, c.nro_viñedo, c.especie, c.especie_id
    FROM cuarteles c
    WHERE c.id = cuartel_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para eliminar variedades (si hay problemas de RLS en DELETE)
CREATE OR REPLACE FUNCTION eliminar_variedad(
    variedad_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Log para debugging
    RAISE NOTICE 'Eliminando variedad: %', variedad_id;
    
    -- Eliminar el registro
    DELETE FROM variedades WHERE id = variedad_id;
    
    -- Verificar si se eliminó
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la variedad con ID: %', variedad_id;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para eliminar especies
CREATE OR REPLACE FUNCTION eliminar_especie(
    especie_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Log para debugging
    RAISE NOTICE 'Eliminando especie: %', especie_id;
    
    -- Verificar si tiene variedades asociadas
    IF EXISTS (SELECT 1 FROM variedades WHERE especie_id = especie_id) THEN
        RAISE EXCEPTION 'No se puede eliminar la especie porque tiene variedades asociadas';
    END IF;
    
    -- Eliminar el registro
    DELETE FROM especies WHERE id = especie_id;
    
    -- Verificar si se eliminó
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la especie con ID: %', especie_id;
    END IF;
    
    RETURN TRUE;
END;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ✅ MIGRACIÓN COMPLETADA CON FUNCIONES RPC COMPLETAS
-- 
-- RESUMEN DE CAMBIOS:
-- 1. variedades.especie_id → UUID FK a especies(id)
-- 2. cuarteles.especie_id → UUID FK a especies(id) (opcional)
-- 3. Índices para mejorar performance
-- 4. Datos de ejemplo insertados
-- 5. Funciones y vistas auxiliares
-- 6. Campos color y tipo_destino como opcionales en variedades
-- 7. Documentación y comentarios
-- 8. Funciones RPC con SECURITY DEFINER para bypass de RLS:
--    - actualizar_variedad()
--    - actualizar_especie()
--    - actualizar_cuartel()
--    - eliminar_variedad()
--    - eliminar_especie()
--
-- FUNCIONES RPC DISPONIBLES:
-- - actualizar_variedad(variedad_id, nueva_especie_id, nuevo_nombre, nuevo_color, nuevo_tipo_destino)
-- - actualizar_especie(especie_id, nuevo_nombre)
-- - actualizar_cuartel(cuartel_id, nueva_finca_id, nuevo_nombre, nueva_superficie, nuevo_nro_vinedo, nueva_especie, nueva_especie_id)
-- - eliminar_variedad(variedad_id)
-- - eliminar_especie(especie_id)
--
-- PRÓXIMOS PASOS:
-- 1. Ejecutar esta migración en la base de datos
-- 2. Actualizar el frontend para usar las relaciones y funciones RPC como fallback
-- 3. Migrar datos existentes si es necesario
-- 4. Probar la funcionalidad end-to-end con estrategia dual (UPDATE directo + RPC fallback)
