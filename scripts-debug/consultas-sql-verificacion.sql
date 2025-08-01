-- 🔍 CONSULTAS SQL COMPLETAS PARA VERIFICACIÓN DE BD
-- Cuaderno de Campo - Estructura y Datos
-- Ejecutar en: Supabase Dashboard → SQL Editor

-- ==============================================
-- 1. VERIFICAR TODAS LAS TABLAS EXISTENTES
-- ==============================================
SELECT 
    schemaname,
    tablename,
    tableowner,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- ==============================================
-- 2. VERIFICAR ESTRUCTURA COMPLETA DE TABLAS
-- ==============================================

-- Estructura de usuarios (tabla crítica)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name = 'usuarios'
ORDER BY ordinal_position;

-- Estructura de todas las tablas principales
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
    AND table_name IN ('usuarios', 'organizaciones', 'fincas', 'cuarteles', 'riegos', 'tareas', 'visitas')
ORDER BY table_name, ordinal_position;

-- ==============================================
-- 3. VERIFICAR POLÍTICAS RLS ACTIVAS
-- ==============================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd,
    roles,
    SUBSTRING(qual, 1, 100) as condicion_corta,
    SUBSTRING(with_check, 1, 100) as verificacion_corta
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, cmd;

-- ==============================================
-- 4. CONTAR REGISTROS EN TODAS LAS TABLAS
-- ==============================================
SELECT 
    'usuarios' as tabla, COUNT(*) as registros FROM usuarios
UNION ALL
SELECT 
    'organizaciones' as tabla, COUNT(*) as registros FROM organizaciones
UNION ALL
SELECT 
    'fincas' as tabla, COUNT(*) as registros FROM fincas
UNION ALL
SELECT 
    'cuarteles' as tabla, COUNT(*) as registros FROM cuarteles
UNION ALL
SELECT 
    'especies' as tabla, COUNT(*) as registros FROM especies
UNION ALL
SELECT 
    'variedades' as tabla, COUNT(*) as registros FROM variedades
UNION ALL
SELECT 
    'riegos' as tabla, COUNT(*) as registros FROM riegos
UNION ALL
SELECT 
    'tareas' as tabla, COUNT(*) as registros FROM tareas
UNION ALL
SELECT 
    'visitas' as tabla, COUNT(*) as registros FROM visitas
UNION ALL
SELECT 
    'aplicadores_operarios' as tabla, COUNT(*) as registros FROM aplicadores_operarios
UNION ALL
SELECT 
    'fertilizantes' as tabla, COUNT(*) as registros FROM fertilizantes
UNION ALL
SELECT 
    'fitosanitarios' as tabla, COUNT(*) as registros FROM fitosanitarios
UNION ALL
SELECT 
    'metodos_de_aplicacion' as tabla, COUNT(*) as registros FROM metodos_de_aplicacion
UNION ALL
SELECT 
    'tipos_tarea' as tabla, COUNT(*) as registros FROM tipos_tarea
UNION ALL
SELECT 
    'cuartel_variedades' as tabla, COUNT(*) as registros FROM cuartel_variedades
UNION ALL
SELECT 
    'operario_finca' as tabla, COUNT(*) as registros FROM operario_finca
ORDER BY tabla;

-- ==============================================
-- 5. ANÁLISIS DE USUARIOS POR ROL
-- ==============================================
SELECT 
    rol,
    COUNT(*) as cantidad_usuarios,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM usuarios), 2) as porcentaje
FROM usuarios 
WHERE rol IS NOT NULL
GROUP BY rol
ORDER BY cantidad_usuarios DESC;

-- ==============================================
-- 6. VERIFICAR ESTRUCTURA DE USUARIOS (MIGRACIÓN)
-- ==============================================
-- Ver si la migración de usuarios se completó correctamente
SELECT 
    COUNT(*) as total_usuarios,
    COUNT(nombre) as con_nombre,
    COUNT(nombre_pila) as con_nombre_pila,
    COUNT(apellido) as con_apellido,
    COUNT(email) as con_email,
    COUNT(rol) as con_rol,
    COUNT(organizacion_id) as con_organizacion
FROM usuarios;

-- Muestra de usuarios con estructura nueva
SELECT 
    id,
    nombre,        -- debe ser username (email)
    nombre_pila,   -- nombre real
    apellido,      -- apellido real
    email,
    rol,
    organizacion_id,
    created_at
FROM usuarios 
ORDER BY created_at DESC
LIMIT 10;

-- ==============================================
-- 7. VERIFICAR INTEGRIDAD DE RELACIONES
-- ==============================================

-- Fincas huérfanas (sin usuario)
SELECT 
    'Fincas sin usuario' as tipo_problema,
    COUNT(*) as cantidad
FROM fincas 
WHERE usuario_id IS NULL;

-- Cuarteles huérfanos (sin finca)
SELECT 
    'Cuarteles sin finca' as tipo_problema,
    COUNT(*) as cantidad
FROM cuarteles 
WHERE finca_id IS NULL;

-- Riegos sin operador
SELECT 
    'Riegos sin operador' as tipo_problema,
    COUNT(*) as cantidad
FROM riegos 
WHERE operador_id IS NULL;

-- Usuarios sin organización
SELECT 
    'Usuarios sin organización' as tipo_problema,
    COUNT(*) as cantidad
FROM usuarios 
WHERE organizacion_id IS NULL;

-- ==============================================
-- 8. ANÁLISIS DEL CAMPO OBJETIVO EN RIEGOS
-- ==============================================
SELECT 
    COUNT(*) as total_riegos,
    COUNT(objetivo) as riegos_con_objetivo,
    COUNT(*) - COUNT(objetivo) as riegos_sin_objetivo,
    ROUND(COUNT(objetivo) * 100.0 / COUNT(*), 2) as porcentaje_completado
FROM riegos;

-- Objetivos más comunes
SELECT 
    objetivo,
    COUNT(*) as frecuencia
FROM riegos 
WHERE objetivo IS NOT NULL 
    AND objetivo != ''
GROUP BY objetivo
ORDER BY frecuencia DESC
LIMIT 10;

-- ==============================================
-- 9. VERIFICAR RELACIONES FOREIGN KEY
-- ==============================================
SELECT 
    tc.table_name as tabla_origen, 
    kcu.column_name as columna_origen, 
    ccu.table_name as tabla_destino,
    ccu.column_name as columna_destino,
    tc.constraint_name as nombre_constraint
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- ==============================================
-- 10. ANÁLISIS DE DATOS POR FINCA
-- ==============================================
SELECT 
    f.id as finca_id,
    f.nombre_finca,
    u.nombre as usuario,
    u.rol as rol_usuario,
    COUNT(DISTINCT c.id) as cantidad_cuarteles,
    COUNT(DISTINCT r.id) as cantidad_riegos,
    COUNT(DISTINCT t.id) as cantidad_tareas
FROM fincas f
LEFT JOIN usuarios u ON f.usuario_id = u.id
LEFT JOIN cuarteles c ON f.id = c.finca_id
LEFT JOIN riegos r ON f.id = r.finca_id
LEFT JOIN tareas t ON c.id = t.cuartel_id
GROUP BY f.id, f.nombre_finca, u.nombre, u.rol
ORDER BY cantidad_riegos DESC;

-- ==============================================
-- 11. VERIFICAR FUNCIONES Y TRIGGERS
-- ==============================================
SELECT 
    routine_name as nombre_funcion,
    routine_type as tipo,
    data_type as tipo_retorno,
    routine_definition as definicion
FROM information_schema.routines 
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Verificar triggers
SELECT 
    trigger_name as nombre_trigger,
    event_manipulation as evento,
    event_object_table as tabla,
    action_statement as accion
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table;

-- ==============================================
-- 12. ANÁLISIS DE ACTIVIDAD RECIENTE
-- ==============================================

-- Riegos recientes
SELECT 
    r.fecha,
    f.nombre_finca,
    c.nombre as cuartel,
    r.especie,
    r.variedad,
    r.objetivo,
    r.horas_riego,
    r.volumen_agua,
    u.nombre as operador
FROM riegos r
LEFT JOIN fincas f ON r.finca_id = f.id
LEFT JOIN cuarteles c ON r.cuartel_id = c.id
LEFT JOIN usuarios u ON r.operador_id = u.id
WHERE r.fecha >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY r.fecha DESC
LIMIT 20;

-- Tareas recientes
SELECT 
    t.fecha,
    f.nombre_finca,
    c.nombre as cuartel,
    tt.nombre as tipo_tarea,
    t.duracion,
    t.obs
FROM tareas t
LEFT JOIN cuarteles c ON t.cuartel_id = c.id
LEFT JOIN fincas f ON c.finca_id = f.id
LEFT JOIN tipos_tarea tt ON t.tipo_tarea_id = tt.id
WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY t.fecha DESC
LIMIT 20;

-- ==============================================
-- 13. VERIFICAR ORGANIZACIONES Y SUS USUARIOS
-- ==============================================
SELECT 
    o.nombre as organizacion,
    COUNT(u.id) as cantidad_usuarios,
    STRING_AGG(DISTINCT u.rol, ', ') as roles_presentes
FROM organizaciones o
LEFT JOIN usuarios u ON o.id = u.organizacion_id
GROUP BY o.id, o.nombre
ORDER BY cantidad_usuarios DESC;

-- ==============================================
-- 14. ANÁLISIS DE ESPECIES Y VARIEDADES
-- ==============================================
SELECT 
    e.nombre as especie,
    COUNT(v.id) as cantidad_variedades,
    COUNT(DISTINCT c.id) as cuarteles_con_esta_especie
FROM especies e
LEFT JOIN variedades v ON e.id = v.especie_id
LEFT JOIN cuarteles c ON e.id = c.especie_id
GROUP BY e.id, e.nombre
ORDER BY cantidad_variedades DESC;

-- ==============================================
-- 15. VERIFICAR ESTADO GENERAL DEL SISTEMA
-- ==============================================
SELECT 
    'Total usuarios' as metrica, COUNT(*)::text as valor FROM usuarios
UNION ALL
SELECT 
    'Total fincas' as metrica, COUNT(*)::text as valor FROM fincas
UNION ALL
SELECT 
    'Total cuarteles' as metrica, COUNT(*)::text as valor FROM cuarteles
UNION ALL
SELECT 
    'Total riegos' as metrica, COUNT(*)::text as valor FROM riegos
UNION ALL
SELECT 
    'Riegos último mes' as metrica, COUNT(*)::text as valor 
    FROM riegos WHERE fecha >= CURRENT_DATE - INTERVAL '30 days'
UNION ALL
SELECT 
    'Usuarios activos' as metrica, COUNT(DISTINCT operador_id)::text as valor 
    FROM riegos WHERE fecha >= CURRENT_DATE - INTERVAL '30 days'
UNION ALL
SELECT 
    'Fincas con actividad' as metrica, COUNT(DISTINCT finca_id)::text as valor 
    FROM riegos WHERE fecha >= CURRENT_DATE - INTERVAL '30 days';

-- ==============================================
-- INSTRUCCIONES DE USO:
-- ==============================================
-- 1. Copia las consultas que necesites
-- 2. Ve a Supabase Dashboard → SQL Editor
-- 3. Pega la consulta y ejecuta con Ctrl+Enter
-- 4. Los resultados te darán acceso completo a todos los datos
-- 5. Usa estas consultas para verificar la estructura y contenido de la BD
