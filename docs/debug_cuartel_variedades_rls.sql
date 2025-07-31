-- 🔍 VERIFICAR POLÍTICAS RLS EN TABLA CUARTEL_VARIEDADES
-- Ejecutar estos comandos en la consola SQL de Supabase

-- 1. Verificar si RLS está habilitado en la tabla cuartel_variedades
SELECT schemaname, tablename, rowsecurity, forcerowsecurity 
FROM pg_tables 
WHERE tablename = 'cuartel_variedades';

-- 2. Ver todas las políticas existentes para cuartel_variedades
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'cuartel_variedades';

-- 3. Ver estructura de la tabla cuartel_variedades
\d cuartel_variedades

-- 4. Verificar tipos de datos específicos
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'cuartel_variedades' 
ORDER BY ordinal_position;

-- 5. Ver ejemplos de datos existentes en la tabla
SELECT cuartel_id, variedad_id, pg_typeof(cuartel_id) as tipo_cuartel, pg_typeof(variedad_id) as tipo_variedad
FROM cuartel_variedades 
LIMIT 5;

-- 🛠️ SOLUCIONES POSIBLES SI HAY PROBLEMAS

-- 🛠️ CREAR POLÍTICAS RLS PARA CUARTEL_VARIEDADES (SINTAXIS CORREGIDA)

-- Habilitar RLS en la tabla (si no está habilitado)
ALTER TABLE cuartel_variedades ENABLE ROW LEVEL SECURITY;

-- Crear políticas para cuartel_variedades con sintaxis correcta
CREATE POLICY "Permitir SELECT a usuarios autenticados" ON cuartel_variedades
    FOR SELECT 
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Permitir INSERT a usuarios autenticados" ON cuartel_variedades
    FOR INSERT 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Permitir UPDATE a usuarios autenticados" ON cuartel_variedades
    FOR UPDATE 
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Permitir DELETE a usuarios autenticados" ON cuartel_variedades
    FOR DELETE 
    USING (auth.uid() IS NOT NULL);

-- Opción 2: Verificar que los tipos sean correctos (si la tabla tiene problemas de esquema)
-- Si cuartel_id debe ser INTEGER en lugar de UUID:
-- ALTER TABLE cuartel_variedades ALTER COLUMN cuartel_id TYPE INTEGER;

-- Opción 3: Test directo de inserción
-- Probar insertar manualmente para ver el error exacto:
INSERT INTO cuartel_variedades (cuartel_id, variedad_id) 
VALUES (17, 71338);

-- 🔍 VERIFICAR DESPUÉS DE LOS CAMBIOS
-- Ver si se insertó correctamente
SELECT * FROM cuartel_variedades WHERE cuartel_id = 17;
