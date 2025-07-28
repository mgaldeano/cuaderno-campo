import { supabase } from "./supabaseClient.js";

console.log("Cuaderno de Campo - Header v1.0.0 cargado");

supabase.auth.getUser().then(({ data: { user } }) => {
  console.log("Usuario logueado:", user);
  if (user) {
    mostrarHeaderInfo(user);
  } else {
    console.log("No hay usuario logueado");
  }
});

async function mostrarHeaderInfo(user) {
  console.log("Ejecutando mostrarHeaderInfo");
  const { data: usuario, error: errorUsuario } = await supabase
    .from("usuarios")
    .select("nombre, organizacion_id")
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
  }

  // Usar logo local en desarrollo para evitar bloqueos de navegador
  if (!logoUrl || logoUrl.trim() === "" || location.hostname === "127.0.0.1" || location.hostname === "localhost") {
    logoUrl = "logo.png";
  }

  // Actualizar saludo en navbar
  const navbarUser = document.getElementById("navbar-user");
  let rol = "usuario";
  if (usuario) rol = usuario.rol ?? rol;
  if (navbarUser) {
    navbarUser.innerHTML = `Bienvenido, <i>${nombre}</i> (${rol})`;
  }

  // Menús por rol (igual que index.html)
  if (rol === "ingeniero" || rol === "superadmin") {
    const navInforme = document.getElementById("nav-informe-visita");
    if (navInforme) navInforme.classList.remove("d-none");
    const gestionMenu = document.getElementById("gestion-dropdown-menu");
    if (gestionMenu) {
      gestionMenu.innerHTML += `<a class='dropdown-item' href='fitosanitarios.html'>Gestionar Fitosanitarios</a>`;
      gestionMenu.innerHTML += `<a class='dropdown-item' href='fertilizantes.html'>Gestionar Fertilizantes</a>`;
      gestionMenu.innerHTML += `<a class='dropdown-item' href='metodos_de_aplicacion.html'>Métodos de Aplicación</a>`;
      gestionMenu.innerHTML += `<a class='dropdown-item' href='variedades.html'>Gestionar Variedades</a>`;
      gestionMenu.innerHTML += `<a class='dropdown-item' href='especies.html'>Gestionar Especies</a>`;
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