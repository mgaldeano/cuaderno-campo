-- =====================================================
-- MODIFICACIONES BASE DE DATOS - NUEVO SISTEMA AUTH
-- =====================================================
-- Fecha: 2025-01-26
-- Propósito: Implementar nuevo sistema de autenticación simplificado
-- Cambios: Agregar campo perfil_completo, simplificar usuarios

-- 1. AGREGAR CAMPO PERFIL_COMPLETO A TABLA USUARIOS
-- Este campo indicará si el usuario completó el wizard inicial
ALTER TABLE usuarios 
ADD COLUMN IF NOT EXISTS perfil_completo BOOLEAN DEFAULT FALSE;

-- 2. COMENTAR CAMPO PERFIL_COMPLETO
COMMENT ON COLUMN usuarios.perfil_completo IS 'Indica si el usuario completó la configuración inicial del perfil';

-- 3. ACTUALIZAR USUARIOS EXISTENTES COMO PERFIL_COMPLETO = TRUE
-- Esto evita que usuarios existentes tengan que pasar por el wizard
UPDATE usuarios 
SET perfil_completo = TRUE 
WHERE perfil_completo IS NULL OR perfil_completo = FALSE;

-- 4. VERIFICAR ESTRUCTURA ACTUAL DE USUARIOS
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- 5. CREAR ÍNDICE EN PERFIL_COMPLETO PARA CONSULTAS RÁPIDAS
CREATE INDEX IF NOT EXISTS idx_usuarios_perfil_completo 
ON usuarios(perfil_completo);

-- 6. VERIFICAR TRIGGER DE AUTO-CREACIÓN DE USUARIOS
-- Consultar si existe el trigger que crea usuarios automáticamente
SELECT 
    trigger_name,
    event_manipulation,
    action_statement,
    action_timing
FROM information_schema.triggers 
WHERE event_object_table = 'usuarios';

-- 7. CREAR/ACTUALIZAR FUNCIÓN PARA AUTO-CREACIÓN DE USUARIOS
-- Esta función se ejecutará cuando se registre un usuario en auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insertar nuevo usuario con datos mínimos
  INSERT INTO public.usuarios (
    id,
    email,
    nombre_completo,
    nombre,
    rol,
    perfil_completo,
    activo,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    'productor', -- rol por defecto
    FALSE, -- requiere completar perfil
    TRUE,
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = NEW.email,
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. CREAR TRIGGER PARA AUTO-CREACIÓN
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 9. ACTUALIZAR POLÍTICA RLS PARA USUARIOS
-- Permitir que usuarios puedan actualizar su propio perfil_completo
DROP POLICY IF EXISTS "Users can update own profile" ON usuarios;

CREATE POLICY "Users can update own profile" ON usuarios
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 10. VERIFICAR POLÍTICAS RLS EXISTENTES
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
WHERE tablename = 'usuarios'
ORDER BY policyname;

-- 11. CREAR VISTA PARA USUARIOS CON PERFIL INCOMPLETO
CREATE OR REPLACE VIEW usuarios_pendientes_setup AS
SELECT 
    u.id,
    u.email,
    u.nombre_completo,
    u.created_at,
    EXTRACT(days FROM (NOW() - u.created_at)) as dias_desde_registro
FROM usuarios u
WHERE u.perfil_completo = FALSE
  AND u.activo = TRUE
ORDER BY u.created_at DESC;

-- 12. CONSULTA DE VERIFICACIÓN - USUARIOS POR ESTADO DE PERFIL
SELECT 
    perfil_completo,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as porcentaje
FROM usuarios 
WHERE activo = TRUE
GROUP BY perfil_completo
ORDER BY perfil_completo;

-- 13. CONSULTA DE VERIFICACIÓN - ÚLTIMOS USUARIOS REGISTRADOS
SELECT 
    email,
    nombre_completo,
    rol,
    perfil_completo,
    created_at,
    CASE 
        WHEN perfil_completo THEN 'Completo'
        ELSE 'Pendiente Setup'
    END as estado
FROM usuarios 
ORDER BY created_at DESC 
LIMIT 10;

-- 14. CREAR FUNCIÓN PARA COMPLETAR SETUP
CREATE OR REPLACE FUNCTION public.completar_setup_usuario(
    p_nombre_completo TEXT,
    p_rol TEXT,
    p_organizacion_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Obtener ID del usuario autenticado
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;
    
    -- Validar rol
    IF p_rol NOT IN ('productor', 'ingeniero', 'operador', 'administrador') THEN
        RAISE EXCEPTION 'Rol inválido: %', p_rol;
    END IF;
    
    -- Actualizar datos del usuario
    UPDATE usuarios SET
        nombre_completo = p_nombre_completo,
        nombre = p_nombre_completo,
        rol = p_rol,
        organizacion_id = p_organizacion_id,
        perfil_completo = TRUE,
        updated_at = NOW()
    WHERE id = v_user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 15. OTORGAR PERMISOS PARA LA FUNCIÓN
GRANT EXECUTE ON FUNCTION public.completar_setup_usuario TO authenticated;

-- 16. CREAR FUNCIÓN PARA VERIFICAR ESTADO DEL PERFIL
CREATE OR REPLACE FUNCTION public.verificar_perfil_usuario()
RETURNS TABLE (
    perfil_completo BOOLEAN,
    nombre_completo TEXT,
    rol TEXT,
    organizacion_nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.perfil_completo,
        u.nombre_completo,
        u.rol,
        o.nombre as organizacion_nombre
    FROM usuarios u
    LEFT JOIN organizaciones o ON u.organizacion_id = o.id
    WHERE u.id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 17. OTORGAR PERMISOS PARA LA FUNCIÓN DE VERIFICACIÓN
GRANT EXECUTE ON FUNCTION public.verificar_perfil_usuario TO authenticated;

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN FINAL
-- =====================================================

-- Verificar que la columna perfil_completo existe
SELECT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'usuarios' 
    AND column_name = 'perfil_completo'
) as columna_perfil_completo_existe;

-- Verificar trigger
SELECT EXISTS (
    SELECT 1 
    FROM information_schema.triggers 
    WHERE trigger_name = 'on_auth_user_created'
    AND event_object_table = 'usuarios'
) as trigger_existe;

-- Verificar función de setup
SELECT EXISTS (
    SELECT 1 
    FROM information_schema.routines 
    WHERE routine_name = 'completar_setup_usuario'
    AND routine_type = 'FUNCTION'
) as funcion_setup_existe;

-- Contar usuarios por estado
SELECT 
    CASE 
        WHEN perfil_completo THEN 'Perfil Completo'
        ELSE 'Pendiente Setup'
    END as estado,
    COUNT(*) as cantidad
FROM usuarios 
GROUP BY perfil_completo;
