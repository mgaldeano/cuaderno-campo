// Versión: v0.4.8-dev | Última actualización: 26/07/2025
// --- Función para generar el reporte de riegos ---
async function generarReporteRiegos({ finca_id = [], cuartel_id = [], operador_id = [], desde, hasta }) {
  // Construir filtros dinámicos
  let query = supabase.from('riegos').select('id, finca_id, cuartel_id, operador_id, fecha, maquinaria, horas_riego, volumen_agua, observaciones, labor, objetivo, variedad, especie, created_at');
  if (finca_id && finca_id.length) query = query.in('finca_id', finca_id);
  if (cuartel_id && cuartel_id.length) query = query.in('cuartel_id', cuartel_id);
  if (operador_id && operador_id.length) query = query.in('operador_id', operador_id);
  if (desde) query = query.gte('fecha', desde);
  if (hasta) query = query.lte('fecha', hasta);
  const { data, error } = await query.order('fecha', { ascending: false });
  if (error) {
    console.error('Error consultando riegos:', error);
    return [];
  }
  // Enriquecer con nombres de finca, cuartel y operador si es posible
  // (Opcional: si tienes los datos en memoria, puedes mapearlos aquí)
  return data.map(r => ({
    ...r,
    Finca: window.fincasMap?.[r.finca_id] || r.finca_id || '',
    Cuartel: window.cuartelesMap?.[r.cuartel_id] || r.cuartel_id || '',
    Regador: window.operadoresMap?.[r.operador_id] || r.operador_id || '',
  }));
}
console.log('Versión reportes.js: v0.4.8-dev | Última actualización: 26/07/2025');
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
        fecha: r.fecha,
        Finca: r.Finca,
        Cuartel: r.Cuartel,
        Regador: r.Regador,
        horas_riego: r.horas_riego,
        volumen_agua: r.volumen_agua,
        observaciones: r.observaciones
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

window.addEventListener('DOMContentLoaded', async () => {
  // --- Reporte de Riegos por Regador ---
  async function generarReporteRiegosPorRegador({ regador_id = [], desde, hasta }) {
    let query = supabase.from('riegos').select('id, fecha, operador_id, finca_id, cuartel_id, horas_riego, volumen_agua, observaciones');
    if (regador_id && regador_id.length) query = query.in('operador_id', regador_id);
    if (desde) query = query.gte('fecha', desde);
    if (hasta) query = query.lte('fecha', hasta);
    const { data, error } = await query.order('fecha', { ascending: false });
    if (error) {
      console.error('Error consultando riegos por regador:', error);
      return [];
    }
    return data.map(r => ({
      ...r,
      Finca: window.fincasMap?.[r.finca_id] || r.finca_id || '',
      Cuartel: window.cuartelesMap?.[r.cuartel_id] || r.cuartel_id || '',
      Regador: window.operadoresMap?.[r.operador_id] || r.operador_id || '',
    }));
  }

  // Renderizar filtros y tabla para el nuevo reporte
  window.renderRiegosPorRegadorUI = function renderRiegosPorRegadorUI() {
    const filtrosForm = document.getElementById('reportes-filtros');
    const resultadoDiv = document.getElementById('reportes-resultado');
    // Limpiar filtros
    filtrosForm.innerHTML = `
      <fieldset>
        <legend>Riegos por regador</legend>
        <label>Tipo de reporte
          <select id="tipo-reporte" required>
            <option value="riegos">Riegos realizados</option>
            <option value="riegos-regador" selected>Riegos por regador</option>
            <option value="agroquimicos">Aplicaciones de agroquímicos</option>
            <option value="fertilizaciones">Fertilizaciones</option>
            <option value="labores">Labores de suelo</option>
            <option value="bpa">Normas BPA (auditoría)</option>
          </select>
        </label>
        <label>Regador
          <div id="regador-reporte"></div>
        </label>
        <label>Desde
          <input type="date" id="fecha-desde" value="2000-01-01" />
        </label>
        <label>Hasta
          <input type="date" id="fecha-hasta" />
        </label>
        <button id="ver-informe-regador" type="button">Ver informe</button>
      </fieldset>
    `;
    // Preseleccionar fecha actual en 'Hasta'
    const fechaHastaInput = document.getElementById('fecha-hasta');
    if (fechaHastaInput) {
      const hoy = new Date();
      const yyyy = hoy.getFullYear();
      const mm = String(hoy.getMonth() + 1).padStart(2, '0');
      const dd = String(hoy.getDate()).padStart(2, '0');
      fechaHastaInput.value = `${yyyy}-${mm}-${dd}`;
    }
    // Poblar regadores
        // Poblar regadores solo con apellido y nombre
        const regadorSelect = document.getElementById('regador-reporte');
        const regadores = Object.entries(window.operadoresMap || {}).map(([id, nombre]) => ({ id, nombre }));
        regadorSelect.innerHTML = regadores.length > 0
          ? regadores.map(o => `<label style="display:inline-block; margin:2px;"><input type="checkbox" name="regador" value="${o.id}"> <span style="font-size:0.95em;">${o.nombre}</span></label>`).join('')
          : '<span style="color:#888;">No hay regadores disponibles.</span>';
    // Listener botón
    document.getElementById('ver-informe-regador').addEventListener('click', async () => {
      const regadorIds = Array.from(document.querySelectorAll('input[name="regador"]:checked')).map(cb => cb.value);
      const desde = document.getElementById('fecha-desde').value;
      const hasta = document.getElementById('fecha-hasta').value;
      const datos = await generarReporteRiegosPorRegador({ regador_id: regadorIds, desde, hasta });
      if (!datos || datos.length === 0) {
        resultadoDiv.innerHTML = '<p>No hay registros de riegos para los filtros seleccionados.</p>';
        return;
      }
      // Generar tabla
      const tabla = document.createElement('table');
      tabla.innerHTML = `
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Regador</th>
            <th>Finca</th>
            <th>Cuartel</th>
            <th>Horas riego</th>
            <th>Volumen agua</th>
            <th>Observaciones</th>
          </tr>
        </thead>
        <tbody>
          ${datos.map(r => `
            <tr>
              <td>${r.fecha ?? '-'}</td>
              <td>${r.Regador ?? '-'}</td>
              <td>${r.Finca ?? '-'}</td>
              <td>${r.Cuartel ?? '-'}</td>
              <td>${r.horas_riego ?? '-'}</td>
              <td>${r.volumen_agua ?? '-'}</td>
              <td>${r.observaciones ?? ''}</td>
            </tr>
          `).join('')}
        </tbody>
      `;
      resultadoDiv.innerHTML = '';
      resultadoDiv.appendChild(tabla);
    });
  }

  // Ejemplo: para probar, puedes llamar renderRiegosPorRegadorUI() desde la consola
  // Preseleccionar fecha actual en el campo 'Hasta'
  const fechaHastaInput = document.getElementById('fecha-hasta');
  if (fechaHastaInput) {
    const hoy = new Date();
    const yyyy = hoy.getFullYear();
    const mm = String(hoy.getMonth() + 1).padStart(2, '0');
    const dd = String(hoy.getDate()).padStart(2, '0');
    fechaHastaInput.value = `${yyyy}-${mm}-${dd}`;
  }
  // --- Cargar mapas de nombres ---
  async function cargarMapas() {
    // Fincas
    const { data: fincasData } = await supabase.from('fincas').select('id, nombre_finca');
    window.fincasMap = {};
    (fincasData ?? []).forEach(f => { window.fincasMap[f.id] = f.nombre_finca; });
    // Cuarteles
    const { data: cuartelesData } = await supabase.from('cuarteles').select('id, nombre');
    window.cuartelesMap = {};
    (cuartelesData ?? []).forEach(c => { window.cuartelesMap[c.id] = c.nombre; });
    // Regadores
    const { data: regadoresData } = await supabase.from('aplicadores_operarios').select('id, apellido, nombre');
    window.operadoresMap = {};
    (regadoresData ?? []).forEach(o => { window.operadoresMap[o.id] = `${o.apellido ? o.apellido + ', ' : ''}${o.nombre}`; });
  }
  // Cargar mapas antes de mostrar filtros y reportes
  await cargarMapas();
  // Elementos
  const filtrosForm = document.getElementById('reportes-filtros');
  const tipoReporte = document.getElementById('tipo-reporte');
  const fincaSelect = document.getElementById('finca-reporte');
  const cuartelSelect = document.getElementById('cuartel-reporte');
  // const regadorSelect = document.getElementById('regador-reporte');
  const fechaDesde = document.getElementById('fecha-desde');
  const fechaHasta = document.getElementById('fecha-hasta');
  const resultadoDiv = document.getElementById('reportes-resultado');

  // Agregar botón 'Ver informe' debajo de los filtros si no existe
  let verInformeBtn = document.getElementById('ver-informe');
  if (!verInformeBtn) {
    verInformeBtn = document.createElement('button');
    verInformeBtn.id = 'ver-informe';
    verInformeBtn.type = 'button';
    verInformeBtn.textContent = 'Ver informe';
    verInformeBtn.style.margin = '1em 0';
    filtrosForm.appendChild(verInformeBtn);
  }

  // Botones seleccionar todo/nada para finca, cuartel y regador
  function setCheckboxes(container, checked) {
    Array.from(container.querySelectorAll('input[type="checkbox"]')).forEach(cb => {
      cb.checked = checked;
    });
  }

  const fincaTodoBtn = document.getElementById('finca-todo');
  if (fincaTodoBtn) fincaTodoBtn.addEventListener('click', () => setCheckboxes(fincaSelect, true));

  const fincaNadaBtn = document.getElementById('finca-nada');
  if (fincaNadaBtn) fincaNadaBtn.addEventListener('click', () => setCheckboxes(fincaSelect, false));

  const cuartelTodoBtn = document.getElementById('cuartel-todo');
  if (cuartelTodoBtn) cuartelTodoBtn.addEventListener('click', () => setCheckboxes(cuartelSelect, true));

  const cuartelNadaBtn = document.getElementById('cuartel-nada');
  if (cuartelNadaBtn) cuartelNadaBtn.addEventListener('click', () => setCheckboxes(cuartelSelect, false));

  const regadorTodoBtn = document.getElementById('regador-todo');
  if (regadorTodoBtn) regadorTodoBtn.addEventListener('click', () => setCheckboxes(regadorSelect, true));

  const regadorNadaBtn = document.getElementById('regador-nada');
  if (regadorNadaBtn) regadorNadaBtn.addEventListener('click', () => setCheckboxes(regadorSelect, false));

  // Validar login
  const { data: { user } } = await supabase.auth.getUser();
  // await waitForLogoutBtn(); // El logout se maneja en header.js
  await import('./header.js');

  // Ya existen los divs en el HTML, solo los llenamos

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
    // --- Fincas ---
    console.log('Rol usuario:', rolUsuario);
    console.log('organizacionId:', organizacionId);
    console.log('productorId:', productorId);
    const { data: fincasData } = await supabase.from('fincas').select('id, nombre_finca, usuario_id');
    const fincas = fincasData ?? [];
    console.log('Fincas cargadas:', fincas);
    // Verificar que el div existe
    if (!fincaSelect) {
      alert('Error: No se encontró el contenedor de fincas (id="finca-reporte") en el HTML.');
      return;
    }
    fincaSelect.style.display = 'block';
    fincaSelect.style.visibility = 'visible';
    fincaSelect.style.background = '';
    fincaSelect.style.border = '';
    if (fincas.length === 0) {
      fincaSelect.innerHTML = '<span style="color:#c00;">No hay fincas disponibles.</span>';
    } else {
      const htmlFincas = fincas.map(f => `<label style="display:block; margin:2px 0;"><input type="checkbox" name="finca" value="${f.id}"> ${f.nombre_finca}</label>`).join('');
      console.log('HTML generado para fincas:', htmlFincas);
      fincaSelect.innerHTML = htmlFincas;
    }

    // --- Cuarteles ---
    const { data: cuartelesData } = await supabase.from('cuarteles').select('id, nombre, finca_id');
    const cuarteles = cuartelesData ?? [];
    cuartelSelect.innerHTML = '';

    // Guardar cuarteles en dataset para filtrado dinámico
    cuartelSelect.dataset.allCuarteles = JSON.stringify(cuarteles);

    // Listener para filtrar cuarteles dinámicamente al seleccionar finca
    fincaSelect.addEventListener('change', async () => {
      const fincasSeleccionadas = Array.from(fincaSelect.querySelectorAll('input[name="finca"]:checked')).map(cb => cb.value);
      // Filtrar cuarteles
      const cuartelesFiltrados = cuarteles.filter(c => fincasSeleccionadas.includes(String(c.finca_id)));
      cuartelSelect.innerHTML = cuartelesFiltrados.length > 0
        ? cuartelesFiltrados.map(c => `<label style="display:inline-block; margin:2px;"><input type="checkbox" name="cuartel" value="${c.id}"> <span style="font-size:0.95em;">${c.nombre}</span></label>`).join('')
        : '<span style="color:#888;">Selecciona una finca para ver cuarteles.</span>';
    });

    // Inicial: mostrar cuarteles solo si hay fincas seleccionadas
    fincaSelect.dispatchEvent(new Event('change'));
  }
  // Acción del botón 'Ver informe'
  verInformeBtn.addEventListener('click', async () => {
    // Obtener filtros seleccionados
    const fincaIds = Array.from(fincaSelect.querySelectorAll('input[name="finca"]:checked')).map(cb => cb.value);
    const cuartelIds = Array.from(cuartelSelect.querySelectorAll('input[name="cuartel"]:checked')).map(cb => cb.value);
    const desde = fechaDesde.value;
    const hasta = fechaHasta.value;
    // Generar reporte (sin filtro de regador)
    const datos = await generarReporteRiegos({ finca_id: fincaIds, cuartel_id: cuartelIds, desde, hasta });
    if (!datos || datos.length === 0) {
      resultadoDiv.innerHTML = '<p>No hay registros de riegos para los filtros seleccionados.</p>';
      return;
    }
    // Generar tabla HTML
    const tabla = document.createElement('table');
    tabla.innerHTML = `
      <thead>
        <tr>
          <th>Fecha</th>
          <th>Finca</th>
          <th>Cuartel</th>
          <th>Regador</th>
          <th>Horas riego</th>
          <th>Volumen agua</th>
          <th>Observaciones</th>
        </tr>
      </thead>
      <tbody>
        ${datos.map(r => `
          <tr>
            <td>${r.fecha ?? '-'}</td>
            <td>${r.Finca ?? '-'}</td>
            <td>${r.Cuartel ?? '-'}</td>
            <td>${r.Regador ?? '-'}</td>
            <td>${r.horas_riego ?? '-'}</td>
            <td>${r.volumen_agua ?? '-'}</td>
            <td>${r.observaciones ?? ''}</td>
          </tr>
        `).join('')}
      </tbody>
    `;
    resultadoDiv.innerHTML = '';
    resultadoDiv.appendChild(tabla);
  });
  // Ejecutar la carga de filtros al iniciar
  await cargarFiltros();
});
// ...existing code...


// Exportar CSV
document.getElementById('exportar-csv').addEventListener('click', () => {
  if (!ultimoReporte || ultimoReporte.length === 0) {
    alert('No hay datos para exportar');
    return;
  }
  let datos = ultimoReporte;
  let columnas = Object.keys(datos[0]);
  if (ultimoTipo === 'riegos') {
    columnas = ['fecha', 'Finca', 'Cuartel', 'Regador', 'horas_riego', 'volumen_agua', 'observaciones'];
    datos = datos.map(r => ({
      fecha: r.fecha,
      Finca: r.Finca,
      Cuartel: r.Cuartel,
      Regador: r.Regador,
      horas_riego: r.horas_riego,
      volumen_agua: r.volumen_agua,
      observaciones: r.observaciones
    }));
  }
  const csv = [columnas.join(',')].concat(datos.map(r => columnas.map(k => JSON.stringify(r[k] ?? '')).join(','))).join('\n');
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
    doc.setFontSize(12);
    doc.text(`Reporte: ${ultimoTipo} (${new Date().toLocaleDateString()})`, 10, y);
    y += 10;
    let columnas = ['fecha', 'Finca', 'Cuartel', 'Regador', 'horas_riego', 'volumen_agua', 'observaciones'];
    doc.text(columnas.join(' | '), 10, y);
    y += 10;
    ultimoReporte.forEach(r => {
      doc.text(columnas.map(k => String(r[k] ?? '')).join(' | '), 10, y);
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

// Botones seleccionar todo/nada para finca, cuartel y regador

function actualizarFooterVersion() {
  window.setTimeout(() => {
    const footer = document.getElementById('footer-version');
    if (footer) {
      footer.textContent = 'Versión: v0.4.8-dev | Última actualización: 26/07/2025';
    }
  }, 300);
}
