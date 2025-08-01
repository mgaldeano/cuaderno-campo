-- =====================================================
-- DESHABILITAR CONFIRMACIÓN DE EMAIL 
-- =====================================================
-- Para desarrollo - no usar en producción

-- ⚠️ IMPORTANTE: Ejecutar en Dashboard Supabase → Authentication → Settings

-- 1. Ve a: Authentication → Settings → Email Templates
-- 2. Busca: "Enable email confirmations" 
-- 3. DESACTÍVALO (toggle OFF)

-- O ejecuta esta configuración si tienes acceso:

-- ALTER SYSTEM SET supabase_auth.enable_signup = true;
-- ALTER SYSTEM SET supabase_auth.enable_email_confirmations = false;

-- 📝 NOTA: Esto permite que los usuarios se registren SIN confirmar email
-- Solo para desarrollo/testing. En producción deberías usar emails reales.

-- Después de cambiar esta configuración:
-- 1. Borra el usuario que acabas de crear (si se creó)
-- 2. Intenta registrarte nuevamente 
-- 3. Debería funcionar sin pedir confirmación de email
