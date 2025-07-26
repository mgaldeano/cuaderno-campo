// Versión: v0.4.4-dev | Última actualización: 26/07/2025
console.log('Versión reportes.js: v0.4.4-dev | Última actualización: 26/07/2025');
// NOTA: Algunos reportes (labores, agroquímicos, fertilizaciones) requieren revisión y adaptación cuando las tablas estén completas o cambie su estructura. Actualizar las funciones correspondientes.

// Exportar Excel (.xlsx) usando SheetJS si está disponible
document.getElementById('exportar-excel').addEventListener('click', () => {
  if (!ultimoReporte || ultimoReporte.length === 0) {
    alert('No hay datos para exportar');
    return;
  }
  if (window.XLSX) {
    const ws = window.XLSX.utils.json_to_sheet(ultimoReporte);
    const wb = window.XLSX.utils.book_new();
    window.XLSX.utils.book_append_sheet(wb, ws, 'Reporte');
    window.XLSX.writeFile(wb, `reporte_${ultimoTipo}_${new Date().toISOString().slice(0,10)}.xlsx`);
  } else {
    alert('SheetJS (XLSX) no está disponible. Puedes instalarlo o usar la exportación CSV.');
  }
});
import { supabase } from "./supabaseClient.js";

// Validar login
const { data: { user } } = await supabase.auth.getUser();
if (!user) {
  window.location.href = "login.html";
  throw new Error("No autorizado");
}

// Cargar header
await fetch('header.html')
  .then(res => res.text())
  .then(html => {
    document.getElementById('header-container').innerHTML = html;
  });
function waitForLogoutBtn() {
  return new Promise(resolve => {
    const check = () => {
      if (document.getElementById('logoutBtn')) {
        resolve();
      } else {
        setTimeout(check, 30);
      }
    };
    check();
  });
}
await waitForLogoutBtn();
await import('./header.js');

// Elementos
const filtrosForm = document.getElementById('reportes-filtros');
const tipoReporte = document.getElementById('tipo-reporte');
const fincaSelect = document.getElementById('finca-reporte');
const cuartelSelect = document.getElementById('cuartel-reporte');
const operadorSelect = document.getElementById('operador-reporte');
const fechaDesde = document.getElementById('fecha-desde');
const fechaHasta = document.getElementById('fecha-hasta');
const resultadoDiv = document.getElementById('reportes-resultado');

// Obtener rol del usuario actual
let rolUsuario = "operador";
let usuarioId = user.id;
let organizacionId = null;
let productorId = null;
try {
  const { data: usuario } = await supabase.from('usuarios').select('rol, organizacion_id, id').eq('id', usuarioId).single();
  if (usuario?.rol) rolUsuario = usuario.rol;
  if (usuario?.organizacion_id) organizacionId = usuario.organizacion_id;
  if (rolUsuario === "productor") productorId = usuarioId;
} catch {}

// Mostrar/ocultar filtros según rol
document.getElementById('filtros-productor').style.display = (rolUsuario === "productor" || rolUsuario === "ingeniero") ? "block" : "none";
document.getElementById('filtros-operador').style.display = (rolUsuario === "operador") ? "block" : "none";

// Cargar opciones de finca, cuartel y operador según rol
async function cargarFiltros() {
  // Fincas
  let fincas = [];
  console.log('Rol usuario:', rolUsuario);
  console.log('organizacionId:', organizacionId);
  console.log('productorId:', productorId);
  if (rolUsuario === "superadmin") {
    // Superadmin: todas las fincas
    const { data } = await supabase.from('fincas').select('id, nombre_finca, usuario_id');
    fincas = data ?? [];
  } else if (rolUsuario === "ingeniero" && organizacionId) {
    // Ingeniero: todas las fincas de su organización
    const { data } = await supabase.from('fincas').select('id, nombre_finca, usuario_id').eq('usuario_id', organizacionId);
    fincas = data ?? [];
  } else if (rolUsuario === "productor") {
    // Productor: solo sus fincas
    const { data } = await supabase.from('fincas').select('id, nombre_finca, usuario_id').eq('usuario_id', productorId);
    fincas = data ?? [];
  }
  console.log('Fincas cargadas:', fincas);
  fincaSelect.innerHTML = '<option value="">Todas</option>' +
    (fincas.map(f => `<option value="${f.id}">${f.nombre_finca}</option>`).join(''));

  // Cuarteles
  let cuarteles = [];
  if (fincas.length > 0) {
    const { data } = await supabase.from('cuarteles').select('id, nombre, finca_id');
    cuarteles = (data ?? []).filter(c => fincas.some(f => f.id === c.finca_id));
  }
  cuartelSelect.innerHTML = '<option value="">Todos</option>' +
    (cuarteles.map(c => `<option value="${c.id}">${c.nombre}</option>`).join(''));

  // Operadores
  let operadores = [];
  if (rolUsuario === "superadmin" && fincas.length > 0) {
    // Superadmin: todos los operarios de todas las fincas
    const fincaIds = fincas.map(f => f.id);
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre, finca_id').in('finca_id', fincaIds);
    operadores = data ?? [];
  } else if (rolUsuario === "ingeniero" && fincas.length > 0) {
    // Ingeniero: todos los operarios de las fincas de su organización
    const fincaIds = fincas.map(f => f.id);
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre, finca_id').in('finca_id', fincaIds);
    operadores = data ?? [];
  } else if (rolUsuario === "productor") {
    // Productor: operarios propios
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre, usuario_id').eq('usuario_id', productorId);
    operadores = data ?? [];
  } else if (rolUsuario === "operador") {
    // Operador: solo sí mismo
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre').eq('id', usuarioId);
    operadores = data ?? [];
  }
  operadorSelect.innerHTML = '<option value="">Todos</option>' +
    (operadores.map(o => `<option value="${o.id}">${o.nombre}</option>`).join(''));
}
await cargarFiltros();

let ultimoReporte = [];
let ultimoTipo = '';
let ultimoVisual = '';

filtrosForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  resultadoDiv.innerHTML = '<p>Generando reporte...</p>';
  const tipo = tipoReporte.value;
  const finca = fincaSelect.value;
  const cuartel = cuartelSelect.value;
  const operador = operadorSelect.value;
  const desde = fechaDesde.value;
  const hasta = fechaHasta.value;

  // Restricciones por rol
  let filtrosRol = {};
  if (rolUsuario === "operador") {
    filtrosRol.operador_id = usuarioId;
  } else if (rolUsuario === "productor") {
    if (finca) filtrosRol.finca_id = finca;
    if (cuartel) filtrosRol.cuartel_id = cuartel;
  } else if (rolUsuario === "ingeniero") {
    if (finca) filtrosRol.finca_id = finca;
    if (cuartel) filtrosRol.cuartel_id = cuartel;
    // Ingeniero puede ver todos los cuarteles de su organización
  }

  // Selección de consulta según tipo de reporte
  if (tipo === 'bpa') {
    ultimoTipo = tipo;
    ultimoReporte = await generarReporteBPA({ ...filtrosRol, operador, desde, hasta });
    return;
  }
  if (tipo === 'riegos') {
    ultimoTipo = tipo;
    ultimoReporte = await generarReporteRiegos({ ...filtrosRol, operador, desde, hasta });
    return;
  }
  if (tipo === 'agroquimicos') {
    ultimoTipo = tipo;
    ultimoReporte = await generarReporteAgroquimicos({ ...filtrosRol, operador, desde, hasta });
    return;
  }
  if (tipo === 'fertilizaciones') {
    ultimoTipo = tipo;
    ultimoReporte = await generarReporteFertilizaciones({ ...filtrosRol, operador, desde, hasta });
    return;
  }
  if (tipo === 'labores') {
    ultimoTipo = tipo;
    ultimoReporte = await generarReporteLabores({ ...filtrosRol, operador, desde, hasta });
    return;
  }
  resultadoDiv.innerHTML = '<p>Tipo de reporte no implementado aún.</p>';
});

// Exportar CSV
document.getElementById('exportar-csv').addEventListener('click', () => {
  if (!ultimoReporte || ultimoReporte.length === 0) {
    alert('No hay datos para exportar');
    return;
  }
  const keys = Object.keys(ultimoReporte[0]);
  const csv = [keys.join(',')].concat(ultimoReporte.map(r => keys.map(k => JSON.stringify(r[k] ?? '')).join(','))).join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `reporte_${ultimoTipo}_${new Date().toISOString().slice(0,10)}.csv`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
});

// Exportar PDF (simple, tabla)
document.getElementById('exportar-pdf').addEventListener('click', async () => {
  if (!ultimoReporte || ultimoReporte.length === 0) {
    alert('No hay datos para exportar');
    return;
  }
  // Intentar usar jsPDF si está disponible
  if (window.jspdf) {
    const doc = new window.jspdf.jsPDF();
    let y = 10;
    doc.text(`Reporte: ${ultimoTipo} (${new Date().toLocaleDateString()})`, 10, y);
    y += 10;
    const keys = Object.keys(ultimoReporte[0]);
    doc.text(keys.join(' | '), 10, y);
    y += 10;
    ultimoReporte.forEach(r => {
      doc.text(keys.map(k => String(r[k] ?? '')).join(' | '), 10, y);
      y += 8;
    });
    doc.save(`reporte_${ultimoTipo}_${new Date().toISOString().slice(0,10)}.pdf`);
  } else {
    alert('jsPDF no está disponible. Puedes instalarlo o usar la exportación CSV.');
  }
});

// Visualización personalizada (ejemplo: tabla avanzada, gráfico)
function mostrarVisualizacion(tipo, datos) {
  const visualDiv = document.getElementById('reportes-visualizacion');
  visualDiv.innerHTML = '';
  if (!datos || datos.length === 0) return;
  // Ejemplo: mostrar gráfico de barras de cantidad de registros por fecha
  if (tipo === 'riegos') {
    // Agrupar por fecha
    const agrupado = {};
    datos.forEach(r => {
      agrupado[r.fecha] = (agrupado[r.fecha] || 0) + 1;
    });
    // Renderizar gráfico simple (SVG)
    const fechas = Object.keys(agrupado);
    const max = Math.max(...Object.values(agrupado));
    let svg = `<svg width="100%" height="120" viewBox="0 0 ${fechas.length*40} 120">`;
    fechas.forEach((f, i) => {
      const h = 100 * agrupado[f] / max;
      svg += `<rect x="${i*40+10}" y="${110-h}" width="20" height="${h}" fill="#4a90e2" />`;
      svg += `<text x="${i*40+20}" y="115" font-size="10" text-anchor="middle">${f.slice(5)}</text>`;
      svg += `<text x="${i*40+20}" y="${110-h-5}" font-size="10" text-anchor="middle">${agrupado[f]}</text>`;
    });
    svg += '</svg>';
    visualDiv.innerHTML = `<h4>Visualización: Cantidad de riegos por fecha</h4>${svg}`;
  }
  // Puedes agregar más visualizaciones personalizadas aquí...
}

// Reporte especial BPA
async function generarReporteBPA({ finca, cuartel, operador, desde, hasta }) {
  // Ejemplo: mostrar riegos, aplicaciones y fertilizaciones con formato especial
  let filtros = {};
  if (finca) filtros.finca_id = finca;
  if (cuartel) filtros.cuartel_id = cuartel;
  if (operador) filtros.operador_id = operador;
  // Fechas
  let fechaFiltro = {};
  if (desde) fechaFiltro.gte = desde;
  if (hasta) fechaFiltro.lte = hasta;

  // Consulta riegos
  let query = supabase.from('riegos').select('*');
  if (Object.keys(filtros).length) {
    Object.entries(filtros).forEach(([k, v]) => { query = query.eq(k, v); });
  }
  if (fechaFiltro.gte) query = query.gte('fecha', fechaFiltro.gte);
  if (fechaFiltro.lte) query = query.lte('fecha', fechaFiltro.lte);
  const { data: riegos } = await query;

  // Consulta aplicaciones agroquímicos
  let queryAgro = supabase.from('aplicaciones_agroquimicos').select('*');
  if (Object.keys(filtros).length) {
    Object.entries(filtros).forEach(([k, v]) => { queryAgro = queryAgro.eq(k, v); });
  }
  if (fechaFiltro.gte) queryAgro = queryAgro.gte('fecha', fechaFiltro.gte);
  if (fechaFiltro.lte) queryAgro = queryAgro.lte('fecha', fechaFiltro.lte);
  const { data: aplicaciones } = await queryAgro;

  // Consulta fertilizaciones
  let queryFert = supabase.from('fertilizaciones').select('*');
  if (Object.keys(filtros).length) {
    Object.entries(filtros).forEach(([k, v]) => { queryFert = queryFert.eq(k, v); });
  }
  if (fechaFiltro.gte) queryFert = queryFert.gte('fecha', fechaFiltro.gte);
  if (fechaFiltro.lte) queryFert = queryFert.lte('fecha', fechaFiltro.lte);
  const { data: fertilizaciones } = await queryFert;

  // Renderizar resultado BPA
  resultadoDiv.innerHTML = `<h3>Reporte BPA</h3>
    <h4>Riegos</h4>
    <pre>${JSON.stringify(riegos, null, 2)}</pre>
    <h4>Aplicaciones de Agroquímicos</h4>
    <pre>${JSON.stringify(aplicaciones, null, 2)}</pre>
    <h4>Fertilizaciones</h4>
    <pre>${JSON.stringify(fertilizaciones, null, 2)}</pre>`;
}

// Ejemplo de reporte de riegos
async function generarReporteRiegos({ finca, cuartel, operador, desde, hasta }) {
  let query = supabase.from('riegos').select('*');
  if (finca) query = query.eq('finca_id', finca);
  if (cuartel) query = query.eq('cuartel_id', cuartel);
  if (operador) query = query.eq('operador_id', operador);
  if (desde) query = query.gte('fecha', desde);
  if (hasta) query = query.lte('fecha', hasta);
  const { data: riegos } = await query;
  // Obtener nombres de finca, cuartel y operador
  const fincaIds = [...new Set(riegos.map(r => r.finca_id))];
  const cuartelIds = [...new Set(riegos.map(r => r.cuartel_id))];
  const operadorIds = [...new Set(riegos.map(r => r.operador_id))];
  const { data: fincas } = await supabase.from('fincas').select('id, nombre_finca').in('id', fincaIds);
  const { data: cuarteles } = await supabase.from('cuarteles').select('id, nombre').in('id', cuartelIds);
  const { data: operadores } = await supabase.from('aplicadores_operarios').select('id, nombre').in('id', operadorIds);
  // Renderizar tabla con nombres
  if (!riegos || riegos.length === 0) {
    resultadoDiv.innerHTML = '<p>No hay registros de riego para los filtros seleccionados.</p>';
    return;
  }
  let html = `<table><thead><tr><th>Fecha</th><th>Finca</th><th>Cuartel</th><th>Operador</th><th>Volumen</th></tr></thead><tbody>`;
  riegos.forEach(r => {
    const fincaNombre = fincas?.find(f => f.id === r.finca_id)?.nombre_finca || r.finca_id;
    const cuartelNombre = cuarteles?.find(c => c.id === r.cuartel_id)?.nombre || r.cuartel_id;
    const operadorNombre = operadores?.find(o => o.id === r.operador_id)?.nombre || r.operador_id;
    html += `<tr><td>${r.fecha}</td><td>${fincaNombre}</td><td>${cuartelNombre}</td><td>${operadorNombre}</td><td>${r.volumen_agua}</td></tr>`;
  });
  html += '</tbody></table>';
  resultadoDiv.innerHTML = html;
  return riegos;
}

// Reporte de aplicaciones de agroquímicos
async function generarReporteAgroquimicos({ finca, cuartel, operador, desde, hasta }) {
  let query = supabase.from('aplicaciones_agroquimicos').select('*');
  if (finca) query = query.eq('finca_id', finca);
  if (cuartel) query = query.eq('cuartel_id', cuartel);
  if (operador) query = query.eq('operador_id', operador);
  if (desde) query = query.gte('fecha', desde);
  if (hasta) query = query.lte('fecha', hasta);
  const { data: aplicaciones } = await query;
  // Obtener nombres de finca, cuartel y operador
  const fincaIds = [...new Set(aplicaciones.map(a => a.finca_id))];
  const cuartelIds = [...new Set(aplicaciones.map(a => a.cuartel_id))];
  const operadorIds = [...new Set(aplicaciones.map(a => a.operador_id))];
  const { data: fincas } = await supabase.from('fincas').select('id, nombre_finca').in('id', fincaIds);
  const { data: cuarteles } = await supabase.from('cuarteles').select('id, nombre').in('id', cuartelIds);
  const { data: operadores } = await supabase.from('aplicadores_operarios').select('id, nombre').in('id', operadorIds);
  if (!aplicaciones || aplicaciones.length === 0) {
    resultadoDiv.innerHTML = '<p>No hay registros de aplicaciones de agroquímicos para los filtros seleccionados.</p>';
    return [];
  }
  let html = `<table><thead><tr><th>Fecha</th><th>Finca</th><th>Cuartel</th><th>Operador</th><th>Producto</th><th>Dosis</th></tr></thead><tbody>`;
  aplicaciones.forEach(a => {
    const fincaNombre = fincas?.find(f => f.id === a.finca_id)?.nombre_finca || a.finca_id;
    const cuartelNombre = cuarteles?.find(c => c.id === a.cuartel_id)?.nombre || a.cuartel_id;
    const operadorNombre = operadores?.find(o => o.id === a.operador_id)?.nombre || a.operador_id;
    html += `<tr><td>${a.fecha}</td><td>${fincaNombre}</td><td>${cuartelNombre}</td><td>${operadorNombre}</td><td>${a.producto}</td><td>${a.dosis}</td></tr>`;
  });
  html += '</tbody></table>';
  resultadoDiv.innerHTML = html;
  return aplicaciones;
}

// Reporte de fertilizaciones
async function generarReporteFertilizaciones({ finca, cuartel, operador, desde, hasta }) {
  let query = supabase.from('fertilizaciones').select('*');
  if (finca) query = query.eq('finca_id', finca);
  if (cuartel) query = query.eq('cuartel_id', cuartel);
  if (operador) query = query.eq('operador_id', operador);
  if (desde) query = query.gte('fecha', desde);
  if (hasta) query = query.lte('fecha', hasta);
  const { data: fertilizaciones } = await query;
  // Obtener nombres de finca, cuartel y operador
  const fincaIds = [...new Set(fertilizaciones.map(f => f.finca_id))];
  const cuartelIds = [...new Set(fertilizaciones.map(f => f.cuartel_id))];
  const operadorIds = [...new Set(fertilizaciones.map(f => f.operador_id))];
  const { data: fincas } = await supabase.from('fincas').select('id, nombre_finca').in('id', fincaIds);
  const { data: cuarteles } = await supabase.from('cuarteles').select('id, nombre').in('id', cuartelIds);
  const { data: operadores } = await supabase.from('aplicadores_operarios').select('id, nombre').in('id', operadorIds);
  if (!fertilizaciones || fertilizaciones.length === 0) {
    resultadoDiv.innerHTML = '<p>No hay registros de fertilizaciones para los filtros seleccionados.</p>';
    return [];
  }
  let html = `<table><thead><tr><th>Fecha</th><th>Finca</th><th>Cuartel</th><th>Operador</th><th>Producto</th><th>Dosis</th></tr></thead><tbody>`;
  fertilizaciones.forEach(f => {
    const fincaNombre = fincas?.find(ff => ff.id === f.finca_id)?.nombre_finca || f.finca_id;
    const cuartelNombre = cuarteles?.find(cc => cc.id === f.cuartel_id)?.nombre || f.cuartel_id;
    const operadorNombre = operadores?.find(oo => oo.id === f.operador_id)?.nombre || f.operador_id;
    html += `<tr><td>${f.fecha}</td><td>${fincaNombre}</td><td>${cuartelNombre}</td><td>${operadorNombre}</td><td>${f.producto}</td><td>${f.dosis}</td></tr>`;
  });
  html += '</tbody></table>';
  resultadoDiv.innerHTML = html;
  return fertilizaciones;
}

// Reporte de labores de suelo
async function generarReporteLabores({ finca, cuartel, operador, desde, hasta }) {
  let query = supabase.from('labores').select('*');
  if (finca) query = query.eq('finca_id', finca);
  if (cuartel) query = query.eq('cuartel_id', cuartel);
  if (operador) query = query.eq('operador_id', operador);
  if (desde) query = query.gte('fecha', desde);
  if (hasta) query = query.lte('fecha', hasta);
  const { data: labores } = await query;
  // Obtener nombres de finca, cuartel y operador
  const fincaIds = [...new Set(labores.map(l => l.finca_id))];
  const cuartelIds = [...new Set(labores.map(l => l.cuartel_id))];
  const operadorIds = [...new Set(labores.map(l => l.operador_id))];
  const { data: fincas } = await supabase.from('fincas').select('id, nombre_finca').in('id', fincaIds);
  const { data: cuarteles } = await supabase.from('cuarteles').select('id, nombre').in('id', cuartelIds);
  const { data: operadores } = await supabase.from('aplicadores_operarios').select('id, nombre').in('id', operadorIds);
  if (!labores || labores.length === 0) {
    resultadoDiv.innerHTML = '<p>No hay registros de labores de suelo para los filtros seleccionados.</p>';
    return [];
  }
  let html = `<table><thead><tr><th>Fecha</th><th>Finca</th><th>Cuartel</th><th>Operador</th><th>Labores</th><th>Maquinaria</th></tr></thead><tbody>`;
  labores.forEach(l => {
    const fincaNombre = fincas?.find(f => f.id === l.finca_id)?.nombre_finca || l.finca_id;
    const cuartelNombre = cuarteles?.find(c => c.id === l.cuartel_id)?.nombre || l.cuartel_id;
    const operadorNombre = operadores?.find(o => o.id === l.operador_id)?.nombre || l.operador_id;
    html += `<tr><td>${l.fecha}</td><td>${fincaNombre}</td><td>${cuartelNombre}</td><td>${operadorNombre}</td><td>${l.labores_realizadas}</td><td>${l.maquinaria_utilizada}</td></tr>`;
  });
  html += '</tbody></table>';
  resultadoDiv.innerHTML = html;
  return labores;
}

// Mostrar versión en el footer
function actualizarFooterVersion() {
  const footer = document.getElementById('footer-version');
  if (footer) {
    footer.textContent = 'Versión: v0.4.4-dev | Última actualización: 26/07/2025';
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', actualizarFooterVersion);
} else {
  actualizarFooterVersion();
}
