-- =====================================================
-- ARREGLAR WIZARD - SIN UPDATED_AT
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. ACTUALIZAR el usuario actual para marcar perfil como completo
UPDATE usuarios 
SET perfil_completo = true
WHERE email = 'martingaldeano@hotmail.com';

-- 2. Verificar que se actualizó correctamente
SELECT 
    'Usuario actualizado' as resultado,
    email,
    perfil_completo,
    created_at
FROM usuarios 
WHERE email = 'martingaldeano@hotmail.com';

-- 3. CORREGIR la función completar_setup_usuario (sin updated_at)
CREATE OR REPLACE FUNCTION completar_setup_usuario(
  p_nombre_pila text,
  p_apellido text,
  p_rol text,
  p_organizacion_id uuid DEFAULT NULL
)
RETURNS json AS $$
DECLARE
  usuario_id uuid;
  resultado json;
BEGIN
  -- Obtener ID del usuario autenticado
  usuario_id := auth.uid();
  
  IF usuario_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Usuario no autenticado');
  END IF;

  -- Actualizar datos del usuario (sin updated_at)
  UPDATE usuarios 
  SET 
    nombre_pila = p_nombre_pila,
    apellido = p_apellido,
    nombre = p_nombre_pila || ' ' || p_apellido,
    rol = p_rol,
    organizacion_id = p_organizacion_id,
    perfil_completo = true  -- ← ESTO ES CLAVE
  WHERE id = usuario_id;

  -- Verificar que se actualizó
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Usuario no encontrado');
  END IF;

  -- Construir respuesta exitosa
  SELECT json_build_object(
    'success', true,
    'usuario', json_build_object(
      'nombre_pila', nombre_pila,
      'apellido', apellido,
      'nombre', nombre,
      'rol', rol,
      'organizacion_id', organizacion_id,
      'perfil_completo', perfil_completo
    )
  ) INTO resultado
  FROM usuarios 
  WHERE id = usuario_id;

  RETURN resultado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Test final - verificar función
SELECT verificar_perfil_usuario() as perfil_estado_final;
