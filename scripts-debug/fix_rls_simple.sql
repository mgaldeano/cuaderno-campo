-- Script simplificado para corregir RLS de labores_suelo
-- Copia y pega esto en Supabase SQL Editor

-- 1. VERIFICAR ESTADO ACTUAL
SELECT 'Verificando políticas existentes...' as status;

SELECT tablename, policyname, cmd, permissive
FROM pg_policies 
WHERE tablename IN ('labores_suelo', 'aplicadores_operarios') 
ORDER BY tablename;

-- 2. CORREGIR POLÍTICAS DE aplicadores_operarios
-- El problema principal: los operadores deben ser accesibles para consultas JOIN

-- Verificar si existe política restrictiva en aplicadores_operarios
DO $$
BEGIN
    -- Eliminar políticas existentes problemáticas (incluyendo la que acabamos de crear)
    DROP POLICY IF EXISTS "Users can view aplicadores_operarios in their organization" ON aplicadores_operarios;
    DROP POLICY IF EXISTS "aplicadores_operarios are viewable by users in the same organization" ON aplicadores_operarios;
    DROP POLICY IF EXISTS "aplicadores_read_policy" ON aplicadores_operarios;
    DROP POLICY IF EXISTS "aplicadores_read_access" ON aplicadores_operarios;
    
    -- Crear política simple y funcional
    CREATE POLICY "aplicadores_read_access" ON aplicadores_operarios
        FOR SELECT USING (
            usuario_id = auth.uid()
        );
        
    RAISE NOTICE 'Política de aplicadores_operarios actualizada';
END
$$;

-- 3. VERIFICAR/CORREGIR POLÍTICAS DE labores_suelo
DO $$
BEGIN
    -- Eliminar todas las políticas existentes de labores_suelo
    DROP POLICY IF EXISTS "Usuarios pueden ver labores de su organización" ON labores_suelo;
    DROP POLICY IF EXISTS "labores_select_policy" ON labores_suelo;
    DROP POLICY IF EXISTS "labores_read_simple" ON labores_suelo;
    DROP POLICY IF EXISTS "labores_insert_simple" ON labores_suelo;
    DROP POLICY IF EXISTS "labores_update_simple" ON labores_suelo;
    DROP POLICY IF EXISTS "labores_delete_simple" ON labores_suelo;
    
    -- Crear políticas simples y funcionales
    CREATE POLICY "labores_read_simple" ON labores_suelo
        FOR SELECT USING (usuario_id = auth.uid());
        
    CREATE POLICY "labores_insert_simple" ON labores_suelo
        FOR INSERT WITH CHECK (usuario_id = auth.uid());
    
    CREATE POLICY "labores_update_simple" ON labores_suelo
        FOR UPDATE USING (usuario_id = auth.uid());
    
    CREATE POLICY "labores_delete_simple" ON labores_suelo
        FOR DELETE USING (usuario_id = auth.uid());
    
    RAISE NOTICE 'Políticas de labores_suelo actualizadas';
END
$$;

-- 4. VERIFICAR RESULTADO
SELECT 'Verificando políticas después de corrección...' as status;

SELECT 
    tablename, 
    policyname, 
    cmd,
    CASE 
        WHEN char_length(qual) > 60 THEN substring(qual, 1, 60) || '...'
        ELSE qual
    END as condition_preview
FROM pg_policies 
WHERE tablename IN ('labores_suelo', 'aplicadores_operarios')
ORDER BY tablename, cmd;

-- 5. TEST DE FUNCIONALIDAD (ejecutar como usuario autenticado)
-- Esto debería funcionar sin errores si las RLS están bien configuradas

/*
-- Descomenta para probar (ejecutar después como usuario normal):

SELECT 'Test: Contando aplicadores_operarios...' as test;
SELECT COUNT(*) as total_operadores FROM aplicadores_operarios;

SELECT 'Test: Contando labores_suelo...' as test;  
SELECT COUNT(*) as total_labores FROM labores_suelo;

SELECT 'Test: JOIN entre labores y operadores...' as test;
SELECT COUNT(*) as total_con_join 
FROM labores_suelo ls
LEFT JOIN aplicadores_operarios ao ON ls.operador_id = ao.id;

*/

SELECT 'Corrección de RLS completada. Prueba las consultas anteriores como usuario autenticado.' as resultado;
