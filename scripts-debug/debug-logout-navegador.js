// =====================================================
// DEBUG LOGOUT - EJECUTAR EN CONSOLA DEL NAVEGADOR
// =====================================================

// 1. Verificar si header.js se cargó correctamente
console.log('=== DEBUG LOGOUT ===');

// 2. Verificar si el botón existe
const logoutBtn = document.getElementById('logoutBtn');
console.log('Botón logout encontrado:', logoutBtn);

// 3. Verificar eventos en el botón
if (logoutBtn) {
  console.log('Listeners en el botón:', getEventListeners(logoutBtn));
}

// 4. Verificar si supabase está disponible
console.log('Supabase disponible:', typeof supabase);

// 5. Test manual de logout
window.testLogout = async function() {
  try {
    console.log('Intentando logout...');
    const { error } = await supabase.auth.signOut();
    if (error) {
      console.error('Error en logout:', error);
    } else {
      console.log('✅ Logout exitoso');
      window.location.href = 'login-nuevo.html';
    }
  } catch (err) {
    console.error('Error inesperado:', err);
  }
};

console.log('Para probar logout manualmente, ejecuta: testLogout()');
