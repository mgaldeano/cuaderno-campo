-- =====================================================
-- IMPLEMENTAR NUEVO SISTEMA DE AUTENTICACIÓN
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor
-- Fecha: 2025-08-01

-- 1. AGREGAR CAMPO PERFIL_COMPLETO A TABLA USUARIOS
ALTER TABLE usuarios 
ADD COLUMN IF NOT EXISTS perfil_completo BOOLEAN DEFAULT FALSE;

-- 2. CREAR FUNCIÓN PARA AUTO-CREACIÓN DE USUARIOS
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

-- 3. CREAR TRIGGER PARA AUTO-CREACIÓN
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. ACTUALIZAR POLÍTICA RLS PARA USUARIOS
DROP POLICY IF EXISTS "Users can update own profile" ON usuarios;

CREATE POLICY "Users can update own profile" ON usuarios
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 5. CREAR FUNCIÓN PARA COMPLETAR SETUP
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

-- 6. OTORGAR PERMISOS PARA LA FUNCIÓN
GRANT EXECUTE ON FUNCTION public.completar_setup_usuario TO authenticated;

-- 7. CREAR FUNCIÓN PARA VERIFICAR ESTADO DEL PERFIL
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

-- 8. OTORGAR PERMISOS PARA LA FUNCIÓN DE VERIFICACIÓN
GRANT EXECUTE ON FUNCTION public.verificar_perfil_usuario TO authenticated;

-- 9. VERIFICACIONES FINALES
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

-- Verificar funciones
SELECT 
    routine_name,
    'Función creada exitosamente' as estado
FROM information_schema.routines 
WHERE routine_name IN ('completar_setup_usuario', 'verificar_perfil_usuario')
AND routine_type = 'FUNCTION';

-- Confirmar implementación
SELECT 
    NOW() as fecha_implementacion,
    'Nuevo sistema de autenticación implementado exitosamente' as resultado;
