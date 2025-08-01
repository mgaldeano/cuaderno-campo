// =====================================================
// DEBUG EN TIEMPO REAL - LOGIN-NUEVO.HTML
// =====================================================
// Ejecutar en CONSOLA cuando estés en login-nuevo.html

console.log('=== DEBUG LOGIN REDIRECT ===');

// Override la función checkIfNeedsSetup para debug
window.originalCheckIfNeedsSetup = window.checkIfNeedsSetup;

window.checkIfNeedsSetup = async function(userId) {
  console.log('🔍 Verificando setup para usuario:', userId);
  
  try {
    const { data, error } = await supabase
      .from('usuarios')
      .select('perfil_completo, nombre_pila, nombre, apellido, rol')
      .eq('id', userId)
      .single();
    
    console.log('📊 Datos del usuario:', data);
    console.log('❌ Error (si hay):', error);
    
    if (error || !data) {
      console.log('❌ No hay datos, necesita setup');
      return true;
    }
    
    const needsSetup = !data.perfil_completo || !data.nombre_pila;
    console.log('🎯 Necesita setup?', needsSetup);
    console.log('   - perfil_completo:', data.perfil_completo);
    console.log('   - nombre_pila:', data.nombre_pila);
    console.log('   - Lógica: !perfil_completo || !nombre_pila =', needsSetup);
    
    return needsSetup;
  } catch (error) {
    console.log('💥 Error en checkIfNeedsSetup:', error);
    return true;
  }
};

console.log('✅ Debug activado. Ahora haz login y mira la consola.');
console.log('La función checkIfNeedsSetup mostrará información detallada.');
