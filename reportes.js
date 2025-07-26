// Versión: v0.4.6-dev | Última actualización: 26/07/2025
console.log('Versión reportes.js: v0.4.6-dev | Última actualización: 26/07/2025');
// NOTA: Algunos reportes (labores, agroquímicos, fertilizaciones) requieren revisión y adaptación cuando las tablas estén completas o cambie su estructura. Actualizar las funciones correspondientes.

// Exportar Excel (.xlsx) usando SheetJS si está disponible
document.getElementById('exportar-excel').addEventListener('click', () => {
  if (!ultimoReporte || ultimoReporte.length === 0) {
    alert('No hay datos para exportar');
    return;
  }
  if (window.XLSX) {
    let datos = ultimoReporte;
    if (ultimoTipo === 'riegos') {
      datos = ultimoReporte.map(r => ({
        id: r.id,
        finca_id: r.finca_id,
        cuartel_id: r.cuartel_id,
        Finca: r.Finca,
        Cuartel: r.Cuartel,
        variedad: r.variedad,
        especie: r.especie,
        labores: r.labores,
        operador_id: r.operador_id,
        Regador: r.Regador,
        fecha: r.fecha,
        maquinaria: r.maquinaria,
        horas_riego: r.horas_riego,
        volumen_agua: r.volumen_agua,
        observaciones: r.observaciones,
        created_at: r.created_at,
        labor: r.labor,
        objetivo: r.objetivo
      }));
    }
    const ws = window.XLSX.utils.json_to_sheet(datos);
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

// Si el contenedor de fincas es un <select>, lo reemplazamos por un <div> para los checkboxes
if (fincaSelect && fincaSelect.tagName === 'SELECT') {
  const fincaDiv = document.createElement('div');
  fincaDiv.id = 'finca-reporte';
  fincaSelect.parentNode.replaceChild(fincaDiv, fincaSelect);
}
// Si el contenedor de cuarteles es un <select>, lo reemplazamos por un <div> para los checkboxes
if (cuartelSelect && cuartelSelect.tagName === 'SELECT') {
  const cuartelDiv = document.createElement('div');
  cuartelDiv.id = 'cuartel-reporte';
  cuartelSelect.parentNode.replaceChild(cuartelSelect, cuartelSelect);
}

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
    const { data } = await supabase.from('fincas').select('id, nombre_finca, usuario_id');
    fincas = data ?? [];
  } else if (rolUsuario === "ingeniero" && organizacionId) {
    const { data } = await supabase.from('fincas').select('id, nombre_finca, usuario_id').eq('usuario_id', organizacionId);
    fincas = data ?? [];
  } else if (rolUsuario === "productor") {
    const { data } = await supabase.from('fincas').select('id, nombre_finca, usuario_id').eq('usuario_id', productorId);
    fincas = data ?? [];
  }
  console.log('Fincas cargadas:', fincas);
  // Renderizar checkboxes de fincas
  fincaSelect.innerHTML = fincas.map(f => `<label><input type="checkbox" name="finca" value="${f.id}"> ${f.nombre_finca}</label>`).join('');

  // Cuarteles
  let cuarteles = [];
  // Se cargan todos, pero se filtran por fincas seleccionadas al cambiar selección
  const { data } = await supabase.from('cuarteles').select('id, nombre, finca_id');
  cuarteles = data ?? [];
  cuartelSelect.innerHTML = '';
  // Se renderizan checkboxes, pero se actualizan según fincas seleccionadas
  cuartelSelect.dataset.allCuarteles = JSON.stringify(cuarteles);

  // Operadores (igual que antes)
  let operadores = [];
  if (rolUsuario === "superadmin" && fincas.length > 0) {
    const fincaIds = fincas.map(f => f.id);
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre, finca_id').in('finca_id', fincaIds);
    operadores = data ?? [];
  } else if (rolUsuario === "ingeniero" && fincas.length > 0) {
    const fincaIds = fincas.map(f => f.id);
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre, finca_id').in('finca_id', fincaIds);
    operadores = data ?? [];
  } else if (rolUsuario === "productor") {
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre, usuario_id').eq('usuario_id', productorId);
    operadores = data ?? [];
  } else if (rolUsuario === "operador") {
    const { data } = await supabase.from('aplicadores_operarios').select('id, nombre').eq('id', usuarioId);
    operadores = data ?? [];
  }
  operadorSelect.innerHTML = '<option value="">Todos</option>' +
    (operadores.map(o => `<option value="${o.id}">${o.nombre}</option>`).join(''));
}
await cargarFiltros();

// Actualizar cuarteles según fincas seleccionadas
fincaSelect.addEventListener('change', () => {
  const cuarteles = JSON.parse(cuartelSelect.dataset.allCuarteles || '[]');
  const fincasSeleccionadas = Array.from(fincaSelect.querySelectorAll('input[name="finca"]:checked')).map(cb => cb.value);
  const cuartelesFiltrados = cuarteles.filter(c => fincasSeleccionadas.includes(String(c.finca_id)));
  cuartelSelect.innerHTML = cuartelesFiltrados.map(c => `<label><input type="checkbox" name="cuartel" value="${c.id}"> ${c.nombre}</label>`).join('');
});

// Proponer fecha actual en fecha hasta
if (fechaHasta) {
  fechaHasta.value = new Date().toISOString().slice(0,10);
}

// Agregar botón para ver reporte en pantalla
const verReporteBtn = document.createElement('button');
verReporteBtn.type = 'button';
verReporteBtn.textContent = 'Ver reporte';
verReporteBtn.className = 'btn btn-primary';
verReporteBtn.style.marginRight = '1em';
filtrosForm.appendChild(verReporteBtn);

let ultimoReporte = [];
let ultimoTipo = '';
let ultimoVisual = '';

verReporteBtn.addEventListener('click', async () => {
  resultadoDiv.innerHTML = '<p>Generando reporte...</p>';
  const tipo = tipoReporte.value;
  // Obtener fincas y cuarteles seleccionados
  const fincasSeleccionadas = Array.from(fincaSelect.querySelectorAll('input[name="finca"]:checked')).map(cb => cb.value);
  const cuartelesSeleccionados = Array.from(cuartelSelect.querySelectorAll('input[name="cuartel"]:checked')).map(cb => cb.value);
  const operador = operadorSelect.value;
  const desde = fechaDesde.value;
  const hasta = fechaHasta.value;

  // Restricciones por rol
  let filtrosRol = {};
  if (rolUsuario === "operador") {
    filtrosRol.operador_id = usuarioId;
  } else if (rolUsuario === "productor") {
    if (fincasSeleccionadas.length) filtrosRol.finca_id = fincasSeleccionadas;
    if (cuartelesSeleccionados.length) filtrosRol.cuartel_id = cuartelesSeleccionados;
  } else if (rolUsuario === "ingeniero" || rolUsuario === "superadmin") {
    if (fincasSeleccionadas.length) filtrosRol.finca_id = fincasSeleccionadas;
    if (cuartelesSeleccionados.length) filtrosRol.cuartel_id = cuartelesSeleccionados;
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
    // Encabezado personalizado para PDF
    let productor = '';
    let organizacion = '';
    let logoUrl = '';
    try {
      productor = window.productorNombre || '';
      organizacion = window.organizacionNombre || '';
      // Intento obtener el logo desde el DOM si existe
      const logoImg = document.querySelector('#header-container img');
      if (logoImg && logoImg.src) logoUrl = logoImg.src;
    } catch {}
    if (logoUrl) {
      // Cargar imagen y dibujar en PDF (solo si es base64 o accesible)
      try {
        const img = new Image();
        img.src = logoUrl;
        img.onload = function() {
          doc.addImage(img, 'PNG', 10, y, 20, 20);
        };
      } catch {}
      y += 22;
    }
    doc.setFontSize(12);
    doc.text(`Productor: ${productor}`, 35, y);
    y += 8;
    doc.text(`Organización: ${organizacion}`, 35, y);
    y += 10;
    doc.text(`Reporte: ${ultimoTipo} (${new Date().toLocaleDateString()})`, 10, y);
    y += 10;
    let datos = ultimoReporte;
    if (ultimoTipo === 'riegos') {
      datos = ultimoReporte.map(r => ({
        id: r.id,
        finca_id: r.finca_id,
        cuartel_id: r.cuartel_id,
        Finca: r.Finca,
        Cuartel: r.Cuartel,
        variedad: r.variedad,
        especie: r.especie,
        labores: r.labores,
        operador_id: r.operador_id,
        Regador: r.Regador,
        fecha: r.fecha,
        maquinaria: r.maquinaria,
        horas_riego: r.horas_riego,
        volumen_agua: r.volumen_agua,
        observaciones: r.observaciones,
        created_at: r.created_at,
        labor: r.labor,
        objetivo: r.objetivo
      }));
    }
    const keys = Object.keys(datos[0]);
    doc.text(keys.join(' | '), 10, y);
    y += 10;
    datos.forEach(r => {
      doc.text(keys.map(k => String(r[k] ?? '')).join(' | '), 10, y);
      y += 8;
      if (y > 270) {
        doc.addPage();
        y = 10;
      }
    });
    doc.save(`reporte_${ultimoTipo}_${new Date().toISOString().slice(0,10)}.pdf`);
  } else {
    alert('jsPDF no está disponible. Por favor, instala la biblioteca jsPDF para exportar a PDF.');
  }
});

function actualizarFooterVersion() {
  const footer = document.getElementById('footer-version');
  if (footer) {
    footer.textContent = 'Versión: v0.4.6-dev | Última actualización: 26/07/2025';
  }
}
