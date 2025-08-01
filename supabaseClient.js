// supabaseClient.js
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const SUPABASE_URL = "https://djvdjulfeuqohpnatdmt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqdmRqdWxmZXVxb2hwbmF0ZG10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNTYyMTEsImV4cCI6MjA2NzkzMjIxMX0.aD_klISxuwoGxMYtPq6XPARva8D32YkKFu7s_Ffq0fw" // ← usá tu key real aquí

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// =====================================================
// FUNCIONES HELPER PARA NUEVO SISTEMA DE AUTENTICACIÓN
// =====================================================

/**
 * Verifica si el usuario actual tiene el perfil completo
 * @returns {Promise<{perfilCompleto: boolean, datos: object}>}
 */
export async function verificarPerfilUsuario() {
  try {
    const { data, error } = await supabase.rpc('verificar_perfil_usuario');
    
    if (error) {
      console.error('Error verificando perfil:', error);
      return { perfilCompleto: false, datos: null };
    }
    
    const perfil = data?.[0];
    return {
      perfilCompleto: perfil?.perfil_completo || false,
      datos: perfil || null
    };
  } catch (error) {
    console.error('Error en verificarPerfilUsuario:', error);
    return { perfilCompleto: false, datos: null };
  }
}

/**
 * Completa la configuración inicial del usuario
 * @param {string} nombreCompleto - Nombre completo del usuario
 * @param {string} rol - Rol del usuario (productor, ingeniero, operador)
 * @param {string|null} organizacionId - ID de la organización (opcional)
 * @returns {Promise<boolean>}
 */
export async function completarSetupUsuario(nombreCompleto, rol, organizacionId = null) {
  try {
    const { data, error } = await supabase.rpc('completar_setup_usuario', {
      p_nombre_completo: nombreCompleto,
      p_rol: rol,
      p_organizacion_id: organizacionId
    });
    
    if (error) {
      console.error('Error completando setup:', error);
      throw error;
    }
    
    return true;
  } catch (error) {
    console.error('Error en completarSetupUsuario:', error);
    throw error;
  }
}

/**
 * Obtiene el usuario actual con sus datos completos
 * @returns {Promise<{user: object, perfil: object}>}
 */
export async function obtenerUsuarioActual() {
  try {
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return { user: null, perfil: null };
    }
    
    const { data: perfil, error: perfilError } = await supabase
      .from('usuarios')
      .select(`
        *,
        organizaciones (
          id,
          nombre,
          tipo
        )
      `)
      .eq('id', user.id)
      .single();
    
    if (perfilError) {
      console.error('Error obteniendo perfil:', perfilError);
    }
    
    return { user, perfil: perfil || null };
  } catch (error) {
    console.error('Error en obtenerUsuarioActual:', error);
    return { user: null, perfil: null };
  }
}

/**
 * Middleware de autenticación que redirige según el estado del perfil
 * @param {string} redirectLogin - URL para redireccionar si no está autenticado
 * @param {string} redirectSetup - URL para redireccionar si el perfil está incompleto
 * @returns {Promise<{user: object, perfil: object}>}
 */
export async function requireAuth(redirectLogin = 'login-nuevo.html', redirectSetup = 'setup-wizard.html') {
  try {
    const { user, perfil } = await obtenerUsuarioActual();
    
    // No está autenticado
    if (!user) {
      window.location.href = redirectLogin;
      return { user: null, perfil: null };
    }
    
    // Perfil incompleto
    if (!perfil?.perfil_completo) {
      window.location.href = redirectSetup;
      return { user, perfil };
    }
    
    return { user, perfil };
  } catch (error) {
    console.error('Error en requireAuth:', error);
    window.location.href = redirectLogin;
    return { user: null, perfil: null };
  }
}

/**
 * Maneja el sign out del usuario
 * @param {string} redirectUrl - URL para redireccionar después del logout
 */
export async function signOut(redirectUrl = 'login-nuevo.html') {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) {
      console.error('Error en sign out:', error);
    }
    window.location.href = redirectUrl;
  } catch (error) {
    console.error('Error en signOut:', error);
  }
}

/**
 * Registra un nuevo usuario con email y password
 * @param {string} email - Email del usuario
 * @param {string} password - Contraseña del usuario
 * @returns {Promise<{success: boolean, user: object, message: string}>}
 */
export async function registrarUsuario(email, password) {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: `${window.location.origin}/setup-wizard.html`
      }
    });
    
    if (error) {
      return {
        success: false,
        user: null,
        message: getAuthErrorMessage(error)
      };
    }
    
    return {
      success: true,
      user: data.user,
      message: data.user?.email_confirmed_at ? 
        'Registro exitoso' : 
        'Verifica tu email para completar el registro'
    };
  } catch (error) {
    console.error('Error en registrarUsuario:', error);
    return {
      success: false,
      user: null,
      message: 'Error inesperado durante el registro'
    };
  }
}

/**
 * Inicia sesión con email y password
 * @param {string} email - Email del usuario
 * @param {string} password - Contraseña del usuario
 * @returns {Promise<{success: boolean, user: object, message: string}>}
 */
export async function iniciarSesion(email, password) {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });
    
    if (error) {
      return {
        success: false,
        user: null,
        message: getAuthErrorMessage(error)
      };
    }
    
    return {
      success: true,
      user: data.user,
      message: 'Inicio de sesión exitoso'
    };
  } catch (error) {
    console.error('Error en iniciarSesion:', error);
    return {
      success: false,
      user: null,
      message: 'Error inesperado durante el inicio de sesión'
    };
  }
}

/**
 * Convierte códigos de error de Supabase a mensajes amigables
 * @param {object} error - Error de Supabase
 * @returns {string} - Mensaje de error amigable
 */
function getAuthErrorMessage(error) {
  const errorMessages = {
    'Invalid login credentials': 'Email o contraseña incorrectos',
    'Email not confirmed': 'Debes confirmar tu email antes de iniciar sesión',
    'User already registered': 'Ya existe una cuenta con este email',
    'Password should be at least 6 characters': 'La contraseña debe tener al menos 6 caracteres',
    'Invalid email': 'El email no es válido',
    'Signup is disabled': 'El registro está deshabilitado temporalmente'
  };
  
  return errorMessages[error.message] || error.message || 'Error de autenticación';
}
