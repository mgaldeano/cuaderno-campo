import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";
const supabase = createClient(
  "https://djvdjulfeuqohpnatdmt.supabase.co",
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqdmRqdWxmZXVxb2hwbmF0ZG10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNTYyMTEsImV4cCI6MjA2NzkzMjIxMX0.aD_klISxuwoGxMYtPq6XPARva8D32YkKFu7s_Ffq0fw"
);

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

  if (!logoUrl || logoUrl.trim() === "") {
    if (location.protocol === "https:") {
      logoUrl = "https://mgaldeano.github.io/cuaderno-campo/logo.png";
    } else {
      logoUrl = "http://galdeano.com.ar/cuaderno-campo/logo.png";
    }
  }

  const headerInfo = document.getElementById("header-info");
  // Tamaño de fuente general del header
  headerInfo.style.fontSize = "0.75em";
  // Color de texto principal
  headerInfo.style.color = "#444";
  // Fondo suave, similar al fondo de la página (PicoCSS)
  headerInfo.style.background = "#26313bff";
  // Bordes redondeados del rectángulo
  headerInfo.style.borderRadius = "6px";
  // Espaciado interno reducido
  headerInfo.style.padding = "2px 8px";
  // Mostrar elementos en línea y centrados verticalmente
  headerInfo.style.display = "inline-flex";
  headerInfo.style.alignItems = "center";
  // Espacio entre logo, organización y nombre
  headerInfo.style.gap = "12px";

  headerInfo.innerHTML = `
  <img src="${logoUrl}" alt="Logo" style="height:16px; margin-right:6px; border-radius:3px;"> <!-- Logo de la organización -->
  <span style="font-weight:500; font-size:0.85em; color:#666;">${organizacion}</span> <!-- Nombre de la organización -->
  <span style="margin-left:10px; font-size:0.8em; color:#888;">${nombre}</span> <!-- Nombre del usuario -->
`;
}

// Manejo universal de cierre de sesión
// Esto asegura que el botón funcione en todas las páginas que incluyan header.js
// y que solo se agregue un listener por carga

document.addEventListener('DOMContentLoaded', () => {
  const logoutBtn = document.getElementById('logoutBtn');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', async (e) => {
      e.preventDefault();
      try {
        await supabase.auth.signOut();
        window.location.href = 'login.html';
      } catch (err) {
        alert('Error al cerrar sesión');
      }
    });
  }
});