// =====================================================
// TEST LOGOUT SIMPLE - EJECUTAR EN CONSOLA
// =====================================================

// Test simple y directo
console.log('=== TEST LOGOUT SIMPLE ===');

// 1. Verificar botón
const btn = document.getElementById('logoutBtn');
console.log('Botón:', btn);

// 2. Test manual directo
window.logoutTest = async function() {
  console.log('🚪 Iniciando logout...');
  try {
    const result = await supabase.auth.signOut();
    console.log('Resultado:', result);
    console.log('✅ Logout exitoso, redirigiendo...');
    window.location.href = 'login-nuevo.html';
  } catch (error) {
    console.error('❌ Error:', error);
  }
};

// 3. Test de click en botón
window.clickTest = function() {
  const btn = document.getElementById('logoutBtn');
  if (btn) {
    console.log('🖱️ Simulando click en botón...');
    btn.click();
  } else {
    console.log('❌ Botón no encontrado');
  }
};

console.log('Comandos disponibles:');
console.log('- logoutTest() - Test directo de logout');
console.log('- clickTest() - Simular click en botón');
