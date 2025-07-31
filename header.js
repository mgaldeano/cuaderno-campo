import { supabase } from "./supabaseClient.js";

console.log("Cuaderno de Campo - Header v1.0.0 cargado");

// Función principal que espera a que el DOM esté listo
function initializeHeader() {
  supabase.auth.getUser().then(({ data: { user } }) => {
    console.log("Usuario logueado:", user);
    if (user) {
      mostrarHeaderInfo(user);
    } else {
      console.log("No hay usuario logueado, mostrando info demo");
      mostrarInfoDemo();
    }
  }).catch(error => {
    console.warn("Error obteniendo usuario, mostrando info demo:", error);
    mostrarInfoDemo();
  });
}

// Función para mostrar información demo cuando no hay usuario
function mostrarInfoDemo() {
  const userName = document.getElementById("user-name");
  const navbarUser = document.getElementById("navbar-user");
  
  if (userName) {
    userName.textContent = "Usuario Demo";
    console.log("✅ Mostrando usuario demo");
  }
  
  if (navbarUser) {
    // Agregar indicador de modo demo
    const existingRole = navbarUser.querySelector('.user-role');
    if (!existingRole) {
      const roleSpan = document.createElement('span');
      roleSpan.className = 'user-role';
      roleSpan.style.cssText = 'color:#ff6b35; font-size:0.85em; margin-left:0.5em; font-weight:normal;';
      roleSpan.textContent = '(modo demo)';
      navbarUser.appendChild(roleSpan);
    }
  }
}

// Si el DOM ya está listo, inicializar inmediatamente
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeHeader);
} else {
  // Si el script se carga después de DOMContentLoaded, ejecutar inmediatamente
  setTimeout(initializeHeader, 100);
}

async function mostrarHeaderInfo(user) {
  console.log("Ejecutando mostrarHeaderInfo");
  const { data: usuario, error: errorUsuario } = await supabase
    .from("usuarios")
    .select("nombre, organizacion_id, rol")
    .eq("id", user.id)
    .single();
  console.log("usuario:", usuario);

  if (errorUsuario) {
    console.log("Error usuario:", errorUsuario);
    return;
  }

  let nombre = usuario?.nombre ?? "Usuario";
  let organizacion = "";
  let logoUrl = "";
  let rol = usuario?.rol ?? "usuario";

  if (usuario?.organizacion_id) {
    const { data: org, error: errorOrg } = await supabase
      .from("organizaciones")
      .select("nombre, logo_url")
      .eq("id", usuario.organizacion_id)
      .single();
    console.log("organizacion:", org);
    if (errorOrg) {
      console.log("Error organizacion:", errorOrg);
    }
    organizacion = org?.nombre ?? "";
    logoUrl = org?.logo_url ?? "";
    // Actualizar nombre de la organización en el header
    const orgNombre = document.getElementById("org-nombre");
    if (orgNombre) orgNombre.textContent = organizacion;
    // Actualizar logo de la organización en el header
    const orgLogo = document.getElementById("org-logo");
    if (orgLogo && logoUrl) orgLogo.src = logoUrl;
  }

  // Usar logo local en desarrollo para evitar bloqueos de navegador
  if (!logoUrl || logoUrl.trim() === "" || location.hostname === "127.0.0.1" || location.hostname === "localhost") {
    logoUrl = "logo.png";
    const orgLogo = document.getElementById("org-logo");
    if (orgLogo) orgLogo.src = logoUrl;
  }

  // Actualizar saludo en navbar
  const navbarUser = document.getElementById("navbar-user");
  const userName = document.getElementById("user-name");
  
  console.log("Elementos encontrados:", { navbarUser, userName });
  console.log("Datos del usuario:", { nombre, rol });
  
  if (navbarUser && userName) {
    userName.textContent = nombre;
    console.log("✅ Nombre actualizado a:", nombre);
    
    // Agregar rol después del nombre si no existe ya
    const existingRole = navbarUser.querySelector('.user-role');
    if (!existingRole) {
      const roleSpan = document.createElement('span');
      roleSpan.className = 'user-role';
      roleSpan.style.cssText = 'color:#888; font-size:0.85em; margin-left:0.5em; font-weight:normal;';
      roleSpan.textContent = `(${rol})`;
      navbarUser.appendChild(roleSpan);
      console.log("✅ Rol agregado:", rol);
    } else {
      existingRole.textContent = `(${rol})`;
      console.log("✅ Rol actualizado:", rol);
    }
  } else {
    console.warn("❌ No se encontraron elementos del header:", { navbarUser, userName });
  }

  // Menús por rol (igual que index.html)
  if (rol === "ingeniero" || rol === "superadmin") {
    const navInforme = document.getElementById("nav-informe-visita");
    if (navInforme) navInforme.classList.remove("d-none");
    const gestionMenu = document.getElementById("gestion-dropdown-menu");
    if (gestionMenu) {
      // Agregar divider y opciones de gestión avanzada solo si no existen ya
      if (!gestionMenu.querySelector('.dropdown-item[href="fitosanitarios.html"]')) {
        gestionMenu.innerHTML += `<div class="dropdown-divider"></div>`;
        gestionMenu.innerHTML += `<a class='dropdown-item' href='fitosanitarios.html'>Gestionar Fitosanitarios</a>`;
        gestionMenu.innerHTML += `<a class='dropdown-item' href='fertilizantes.html'>Gestionar Fertilizantes</a>`;
        gestionMenu.innerHTML += `<a class='dropdown-item' href='metodos_de_aplicacion.html'>Métodos de Aplicación</a>`;
        gestionMenu.innerHTML += `<a class='dropdown-item' href='variedades.html'>Gestionar Variedades</a>`;
        gestionMenu.innerHTML += `<a class='dropdown-item' href='especies.html'>Gestionar Especies</a>`;
      }
    }
  }
}

// Manejo universal de cierre de sesión
// Esto asegura que el botón funcione en todas las páginas que incluyan header.js
// y que solo se agregue un listener por carga

function setLogoutListener() {
  const logoutBtn = document.getElementById('logoutBtn');
  if (logoutBtn) {
    // Eliminar listeners previos si existen
    logoutBtn.replaceWith(logoutBtn.cloneNode(true));
    const newLogoutBtn = document.getElementById('logoutBtn');
    newLogoutBtn.addEventListener('click', async (e) => {
      e.preventDefault();
      try {
        await supabase.auth.signOut();
      } catch (err) {
        // Ignorar error, siempre redirigir
      } finally {
        window.location.href = 'login.html';
      }
    });
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', setLogoutListener);
} else {
  setLogoutListener();
}