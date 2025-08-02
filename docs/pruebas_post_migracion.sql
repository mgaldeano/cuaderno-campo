-- =====================================
-- PRUEBAS POST-MIGRACIÓN
-- Fecha: 2025-08-02
-- Estado: fertilizante_uuid disponible
-- =====================================

-- ✅ 1. VERIFICAR ESTRUCTURA ACTUAL
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'fertilizaciones' 
AND column_name LIKE '%fertilizante%'
ORDER BY column_name;

-- ✅ 2. VERIFICAR CONSTRAINTS
SELECT 
    tc.constraint_name, 
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'fertilizaciones' 
AND kcu.column_name LIKE '%fertilizante%';

-- ✅ 3. VERIFICAR QUE LAS VISTAS SIGUEN FUNCIONANDO
SELECT 
    'reporte_nutrientes' as vista,
    COUNT(*) as registros
FROM reporte_nutrientes
UNION ALL
SELECT 
    'auditoria_global_gap' as vista,
    COUNT(*) as registros  
FROM auditoria_global_gap;

-- ✅ 4. PROBAR INSERCIÓN CON NUEVA COLUMNA
-- (Comentado para seguridad, descomentar para probar)
/*
INSERT INTO fertilizaciones (
    usuario_id,
    finca_id,
    cuartel_id,
    fertilizante_uuid,  -- Nueva columna UUID
    fecha,
    dosis,
    unidad_dosis,
    metodo_aplicacion
) VALUES (
    'cf16dae7-2a3f-4fb5-9a39-7faf7a56fd61', -- Usuario
    36,                                      -- Finca
    27,                                      -- Cuartel  
    '2e20519a-5c8f-4a59-b455-65a2363fa750', -- Fertilizante UUID
    '2025-08-02',                           -- Fecha
    50.0,                                   -- Dosis
    'kg/ha',                                -- Unidad
    'Manual'                                -- Método
);
*/

-- ✅ 5. VERIFICAR RELACIÓN CON FERTILIZANTES
SELECT 
    f.fecha,
    f.dosis,
    f.unidad_dosis,
    fert.producto as fertilizante_nombre,
    fert.formula
FROM fertilizaciones f
LEFT JOIN fertilizantes fert ON f.fertilizante_uuid = fert.id
WHERE f.fertilizante_uuid IS NOT NULL
ORDER BY f.fecha DESC
LIMIT 5;

-- ✅ 6. ESTADÍSTICAS ACTUALES
SELECT 
    COUNT(*) as total_fertilizaciones,
    COUNT(fertilizante_id) as con_fertilizante_id_bigint,
    COUNT(fertilizante_uuid) as con_fertilizante_uuid,
    COUNT(CASE WHEN fertilizante_id IS NOT NULL AND fertilizante_uuid IS NOT NULL THEN 1 END) as con_ambos
FROM fertilizaciones;
