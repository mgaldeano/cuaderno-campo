-- Script para verificar y corregir políticas RLS para labores_suelo
-- Ejecutar en Supabase SQL Editor

-- 1. Verificar qué políticas existen actualmente
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('labores_suelo', 'aplicadores_operarios', 'cuarteles', 'fincas')
ORDER BY tablename, policyname;

-- 2. Verificar la estructura de las relaciones
SELECT 
    t.table_name,
    c.column_name,
    c.data_type,
    tc.constraint_type,
    kcu.table_name as foreign_table,
    kcu.column_name as foreign_column
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON t.table_name = c.table_name
LEFT JOIN information_schema.table_constraints tc ON t.table_name = tc.table_name AND tc.constraint_type = 'FOREIGN KEY'
LEFT JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
WHERE t.table_name IN ('labores_suelo', 'aplicadores_operarios', 'cuarteles', 'fincas')
ORDER BY t.table_name, c.ordinal_position;

-- 3. Corregir políticas RLS para labores_suelo
-- Primero eliminar las políticas existentes si hay conflictos
DROP POLICY IF EXISTS "Usuarios pueden ver labores de su organización" ON labores_suelo;
DROP POLICY IF EXISTS "Usuarios pueden insertar labores" ON labores_suelo;
DROP POLICY IF EXISTS "Usuarios pueden actualizar sus labores" ON labores_suelo;
DROP POLICY IF EXISTS "Usuarios pueden eliminar sus labores" ON labores_suelo;

-- Recrear políticas mejoradas
CREATE POLICY "labores_select_policy" ON labores_suelo
    FOR SELECT USING (usuario_id = auth.uid());

CREATE POLICY "labores_insert_policy" ON labores_suelo
    FOR INSERT WITH CHECK (usuario_id = auth.uid());

CREATE POLICY "labores_update_policy" ON labores_suelo
    FOR UPDATE USING (usuario_id = auth.uid()) 
    WITH CHECK (usuario_id = auth.uid());

CREATE POLICY "labores_delete_policy" ON labores_suelo
    FOR DELETE USING (usuario_id = auth.uid());

-- 4. Verificar/corregir políticas para aplicadores_operarios
-- Asegurar que los usuarios puedan leer operadores asociados a sus fincas/labores
DO $$
BEGIN
    -- Verificar si existe la política de SELECT para aplicadores_operarios
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'aplicadores_operarios' 
        AND policyname = 'operadores_select_policy'
    ) THEN
        CREATE POLICY "operadores_select_policy" ON aplicadores_operarios
            FOR SELECT USING (
                usuario_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM labores_suelo ls 
                    WHERE ls.operador_id = aplicadores_operarios.id 
                    AND ls.usuario_id = auth.uid()
                )
            );
    END IF;
END
$$;

-- 5. Verificar/corregir políticas para cuarteles con relación a fincas
DO $$
BEGIN
    -- Política para cuarteles que permite acceso a través de fincas del usuario
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'cuarteles' 
        AND policyname = 'cuarteles_through_fincas_policy'
    ) THEN
        CREATE POLICY "cuarteles_through_fincas_policy" ON cuarteles
            FOR SELECT USING (
                EXISTS (
                    SELECT 1 FROM fincas f 
                    WHERE f.id = cuarteles.finca_id 
                    AND f.usuario_id = auth.uid()
                )
            );
    END IF;
END
$$;

-- 6. Verificar políticas para fincas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'fincas' 
        AND policyname = 'fincas_select_policy'
    ) THEN
        CREATE POLICY "fincas_select_policy" ON fincas
            FOR SELECT USING (usuario_id = auth.uid());
    END IF;
END
$$;

-- 7. Crear función helper para debugging RLS
CREATE OR REPLACE FUNCTION debug_user_permissions(user_id uuid DEFAULT auth.uid())
RETURNS TABLE (
    table_name text,
    can_select boolean,
    can_insert boolean,
    can_update boolean,
    can_delete boolean,
    record_count bigint
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'fincas'::text,
        (SELECT COUNT(*) > 0 FROM fincas WHERE usuario_id = user_id),
        true,
        true,
        true,
        (SELECT COUNT(*) FROM fincas WHERE usuario_id = user_id)
    UNION ALL
    SELECT 
        'aplicadores_operarios'::text,
        (SELECT COUNT(*) > 0 FROM aplicadores_operarios WHERE usuario_id = user_id),
        true,
        true,
        true,
        (SELECT COUNT(*) FROM aplicadores_operarios WHERE usuario_id = user_id)
    UNION ALL
    SELECT 
        'cuarteles'::text,
        (SELECT COUNT(*) > 0 FROM cuarteles c 
         JOIN fincas f ON c.finca_id = f.id 
         WHERE f.usuario_id = user_id),
        true,
        true,
        true,
        (SELECT COUNT(*) FROM cuarteles c 
         JOIN fincas f ON c.finca_id = f.id 
         WHERE f.usuario_id = user_id)
    UNION ALL
    SELECT 
        'labores_suelo'::text,
        (SELECT COUNT(*) > 0 FROM labores_suelo WHERE usuario_id = user_id),
        true,
        true,
        true,
        (SELECT COUNT(*) FROM labores_suelo WHERE usuario_id = user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Ejecutar debug (opcional)
-- SELECT * FROM debug_user_permissions();

-- 9. Verificar políticas finales
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive,
    cmd,
    CASE 
        WHEN qual IS NOT NULL THEN substring(qual, 1, 100) || '...'
        ELSE 'NO RESTRICTION'
    END as policy_condition
FROM pg_policies 
WHERE tablename IN ('labores_suelo', 'aplicadores_operarios', 'cuarteles', 'fincas')
ORDER BY tablename, cmd, policyname;
