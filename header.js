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
  headerInfo.innerHTML = `
    <img src="${logoUrl}" alt="Logo" style="height:24px; margin-right:8px; border-radius:4px;">
    <span>${nombre}${organizacion ? " • " + organizacion : ""}</span>
  `;
}