-- 🔍 VERIFICAR POLÍTICAS RLS EN TABLA METODOS_DE_APLICACION
-- Ejecutar estos comandos en la consola SQL de Supabase

-- 1. Verificar si RLS está habilitado en la tabla metodos_de_aplicacion
SELECT schemaname, tablename, rowsecurity, forcerowsecurity 
FROM pg_tables 
WHERE tablename = 'metodos_de_aplicacion';

-- 2. Ver todas las políticas existentes para metodos_de_aplicacion
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
WHERE tablename = 'metodos_de_aplicacion';

-- 3. Ver estructura de la tabla metodos_de_aplicacion
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'metodos_de_aplicacion' 
ORDER BY ordinal_position;

-- 4. Ver ejemplos de datos existentes en la tabla
SELECT id, nombre, descripcion 
FROM metodos_de_aplicacion 
LIMIT 5;

-- 🛠️ CREAR POLÍTICAS RLS PARA METODOS_DE_APLICACION (SI NO EXISTEN)

-- Habilitar RLS en la tabla (si no está habilitado)
ALTER TABLE metodos_de_aplicacion ENABLE ROW LEVEL SECURITY;

-- Crear políticas para metodos_de_aplicacion con sintaxis correcta
CREATE POLICY "Permitir SELECT a usuarios autenticados" ON metodos_de_aplicacion
    FOR SELECT 
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "Permitir INSERT a usuarios autenticados" ON metodos_de_aplicacion
    FOR INSERT 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Permitir UPDATE a usuarios autenticados" ON metodos_de_aplicacion
    FOR UPDATE 
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Permitir DELETE a usuarios autenticados" ON metodos_de_aplicacion
    FOR DELETE 
    USING (auth.uid() IS NOT NULL);

-- 🧪 TEST DIRECTO DE OPERACIONES
-- Probar insertar manualmente para ver si hay errores:
INSERT INTO metodos_de_aplicacion (nombre, descripcion) 
VALUES ('Test Método', 'Descripción de prueba');

-- Probar actualizar manualmente:
UPDATE metodos_de_aplicacion 
SET descripcion = 'Descripción actualizada' 
WHERE nombre = 'Test Método';

-- Limpiar test:
DELETE FROM metodos_de_aplicacion WHERE nombre = 'Test Método';

-- 🔍 VERIFICAR DESPUÉS DE LOS CAMBIOS
-- Ver todas las políticas creadas
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'metodos_de_aplicacion';
