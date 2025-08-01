-- =====================================================
-- CORRECCIÓN: FUNCIONES AUTH CON ESTRUCTURA REAL
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. CORREGIR FUNCIÓN PARA AUTO-CREACIÓN DE USUARIOS
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insertar nuevo usuario con datos mínimos usando estructura real
  INSERT INTO public.usuarios (
    id,
    email,
    nombre,
    nombre_pila,
    apellido,
    rol,
    perfil_completo,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'given_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'family_name', ''),
    'productor', -- rol por defecto
    FALSE, -- requiere completar perfil
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = NEW.email;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. CORREGIR FUNCIÓN PARA COMPLETAR SETUP
CREATE OR REPLACE FUNCTION public.completar_setup_usuario(
    p_nombre_completo TEXT,
    p_rol TEXT,
    p_organizacion_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_nombre_pila TEXT;
    v_apellido TEXT;
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
    
    -- Separar nombre completo en nombre_pila y apellido
    v_nombre_pila := split_part(p_nombre_completo, ' ', 1);
    v_apellido := CASE 
        WHEN position(' ' in p_nombre_completo) > 0 
        THEN substring(p_nombre_completo from position(' ' in p_nombre_completo) + 1)
        ELSE ''
    END;
    
    -- Actualizar datos del usuario con estructura real
    UPDATE usuarios SET
        nombre = p_nombre_completo,
        nombre_pila = v_nombre_pila,
        apellido = v_apellido,
        rol = p_rol,
        organizacion_id = p_organizacion_id,
        perfil_completo = TRUE
    WHERE id = v_user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. ELIMINAR Y RECREAR FUNCIÓN PARA VERIFICAR PERFIL
DROP FUNCTION IF EXISTS public.verificar_perfil_usuario();

CREATE OR REPLACE FUNCTION public.verificar_perfil_usuario()
RETURNS TABLE (
    perfil_completo BOOLEAN,
    nombre TEXT,
    rol TEXT,
    organizacion_nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.perfil_completo,
        u.nombre,
        u.rol,
        o.nombre as organizacion_nombre
    FROM usuarios u
    LEFT JOIN organizaciones o ON u.organizacion_id = o.id
    WHERE u.id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. OTORGAR PERMISOS
GRANT EXECUTE ON FUNCTION public.completar_setup_usuario TO authenticated;
GRANT EXECUTE ON FUNCTION public.verificar_perfil_usuario TO authenticated;

-- 5. VERIFICAR CORRECCIONES
SELECT 'Funciones corregidas exitosamente' as resultado,
       NOW() as fecha_correccion;
