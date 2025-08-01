-- =====================================================
-- REPARAR TRIGGER Y SINCRONIZAR USUARIOS
-- =====================================================
-- Ejecutar en: Dashboard Supabase → SQL Editor

-- 1. RECREAR la función del trigger (con mejor manejo de errores)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.usuarios (
    id,
    email,
    nombre,
    nombre_pila,
    apellido,
    rol,
    perfil_completo,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre', ''),
    COALESCE(NEW.raw_user_meta_data->>'nombre_pila', ''),
    COALESCE(NEW.raw_user_meta_data->>'apellido', ''),
    'operador', -- rol por defecto
    false, -- perfil incompleto por defecto
    NOW(),
    NOW()
  );
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log del error para debugging
  RAISE LOG 'Error en handle_new_user: %', SQLERRM;
  RETURN NEW; -- Continuar aunque falle la inserción
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. RECREAR el trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 3. SINCRONIZAR usuarios existentes (crear registros faltantes)
INSERT INTO public.usuarios (
  id,
  email,
  nombre,
  nombre_pila,
  apellido,
  rol,
  perfil_completo,
  created_at,
  updated_at
)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'nombre', '') as nombre,
  COALESCE(au.raw_user_meta_data->>'nombre_pila', '') as nombre_pila,
  COALESCE(au.raw_user_meta_data->>'apellido', '') as apellido,
  'operador' as rol,
  false as perfil_completo,
  au.created_at,
  NOW() as updated_at
FROM auth.users au
LEFT JOIN public.usuarios u ON au.id = u.id
WHERE u.id IS NULL; -- Solo los que no existen

-- 4. Verificar resultado
SELECT 
  'Usuarios sincronizados' as estado,
  COUNT(*) as total
FROM usuarios;

SELECT 
  'Usuarios en auth' as estado,
  COUNT(*) as total
FROM auth.users;
