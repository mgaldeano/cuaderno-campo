### Pendiente: Menú desplegable de Gestión (header)
- Solucionar definitivamente el stacking y el parpadeo del menú desplegable sobre las tarjetas del dashboard en index.html.
- El menú debe quedar siempre por encima de las tarjetas, sin parpadear ni perder el foco, y correctamente alineado.
- Revisar posibles conflictos de stacking context, z-index y eventos de Bootstrap.
## Pendientes próximos pasos (25/07/2025)

1. Asegurar que el help funcione correctamente en todas las páginas (botón flotante y modal).
2. Idear la lógica de reportes: definir tipos, filtros y estructura de consultas.
   - Incluir reporte especial para normas BPA (Buenas Prácticas Agrícolas): mostrar registros, tareas y controles relevantes para auditoría y certificación.
3. Crear los reportes: implementar consultas, filtros y visualización.
   - Agregar opción en la UI para generar el reporte BPA, con filtros y formato adecuado para inspección/auditoría.
4. Agregar gestión de tractores e implementos.
5. Agregar mantenimiento de tractores e implementos.
6. Desarrollar la lógica y el código para tractores e implementos (incluyendo base de datos, formularios y reportes).

# Cambios recientes (26/07/2025)
- Nuevo reporte "Riegos por regador" con filtros específicos (regador y fechas).
- Filtros dinámicos y selector de tipo de reporte siempre visible y funcional.
- Exportación validada para los informes "Riegos realizados" y "Riegos por regador" (Excel, CSV, PDF).
- Mejoras en la experiencia de usuario y robustez de la UI de reportes.

* Mejorar experiencia móvil y responsive: revisar tablas, formularios y botones para una visualización y uso óptimos en celulares. Tener en cuenta si se hacen otros cambios visuales o de flujo.

# Tarea de revisión de ortografía y gramática
- Revisar que todos los formularios, combos y textos de la aplicación respeten ortografía y gramática.
- Asegurar que la primera letra de cada campo, label y opción esté en mayúscula (ejemplo: debe decir "Nombre" en lugar de "nombre").

## 1. Roles y permisos
- [x] Crear el rol **ingeniero** en la tabla de usuarios. (Listo)
- [ ] Permitir que solo el ingeniero pueda generar órdenes de trabajo.

## 2. Órdenes de trabajo
- [ ] Crear tabla `ordenes_de_aplicacion` para registrar órdenes de trabajo (agroquímicos, fertilizantes, etc.).
- [ ] Relacionar cada orden con productos, métodos de aplicación, plagas, maquinaria y operarios.
- [ ] Permitir que los operarios registren la ejecución de las órdenes.

## 3. Tablas auxiliares
- [x] Crear tabla `agroquimicos` (nombre comercial, principio activo, lote, tiempo de carencia, etc.). (Listo: implementada como fitosanitarios con ABM)
- [x] Crear tabla `fertilizantes` (nombre comercial, tipo, composición, concentración, etc.). (Listo: implementada con ABM)
- [x] Crear tabla `metodos_de_aplicacion`.
- [x] Crear tabla `aplicadores_operarios` relacionada a cada productor. (Listo: implementada como 'operadores' con ABM y relación a usuario)

## 4. Tareas específicas
- [x] Registrar **Riego** (ya existe, revisado y actualizado).
- [ ] Registrar **Labores de Suelo** (nueva tabla o sección).
    - Finca, cuartel, variedad, especie, labores realizadas, objetivo, operador responsable, fecha, maquinaria utilizada.
- [ ] Registrar **Aplicación de Agroquímicos** (vinculada a orden de aplicación).
- [ ] Registrar **Fertilización** (vinculada a orden de aplicación).

## 5. UI y flujo de usuario
- [x] Crear página de selección de tipo de tarea (ej: `tareas.html` o `seleccionar-tarea.html`).
- [ ] Cada tipo de tarea debe tener su propio formulario y lógica.
- [ ] Actualizar el menú/header para que "Tareas" apunte a la nueva página de selección.

## 6. Permisos y validaciones
- [ ] Validar que solo el ingeniero pueda crear órdenes.
- [ ] Validar que solo los operarios asignados puedan registrar la ejecución.

## 7. Mejoras generales
- [ ] Permitir agregar nuevos tipos de tareas en el futuro de forma sencilla.
- [ ] Mejorar la experiencia de usuario en la selección y carga de tareas.

# NOTA IMPORTANTE SOBRE REPORTES
- Los reportes de Labores, Aplicaciones de Agroquímicos y Fertilizaciones requieren revisión y adaptación cuando las tablas correspondientes estén completas o cambie su estructura. Actualizar las funciones de consulta y visualización en reportes.js según los nuevos campos y relaciones.

---


---

---

# Modelo recomendado de ABM para reutilización
- Botones de acción compactos y alineados horizontalmente con flexbox (`display:flex; gap:12px; justify-content:center; align-items:center;`).
- Botones con ancho limitado (`min-width: 48px; max-width: 64px;`), padding reducido y texto claro.
- Labels y opciones con ortografía y gramática correctas, primera letra en mayúscula.
- Edición inline clara y funcional, con campos visibles y ocultos según estado.
- Espaciado visual adecuado para mejor experiencia de usuario.
- Estructura HTML y CSS fácil de adaptar a otros ABM del sistema.

- Evaluar la implementación de protección avanzada contra bots y abuso (Captcha) en Supabase Auth cuando el proyecto lo requiera.
- Por ahora, se prioriza facilidad de acceso y pruebas sobre máxima seguridad.



## Modelo y lógica de VISITAS (informes de ingeniero)

### Esquema SQL sugerido
```sql
CREATE TABLE visitas (
  id SERIAL PRIMARY KEY,
  fecha TIMESTAMP NOT NULL DEFAULT NOW(),
  texto TEXT NOT NULL,
  id_productor UUID NOT NULL REFERENCES usuarios(id),
  id_finca BIGINT REFERENCES fincas(id),
  id_cuartel BIGINT REFERENCES cuarteles(id),
  id_ingeniero UUID NOT NULL REFERENCES usuarios(id),
  adjuntos JSONB, -- array de URLs o metadatos de archivos
  enviado_mail BOOLEAN DEFAULT FALSE
);
```

#### Seguridad y RLS
- Solo el ingeniero puede crear, editar y borrar informes de visita.
- El productor puede consultar los informes asociados a su usuario, finca o cuartel.
- Los adjuntos deben validarse y almacenarse en bucket seguro (ej: Supabase Storage).

### Lógica de mails
- Al crear un informe, se envía mail inmediato al productor (si tiene mail registrado).
- Alternativamente, se puede enviar un resumen semanal con todos los informes nuevos.
- El mail incluye el texto, fecha, ingeniero, entidad asociada y links a adjuntos.

### Carga de informe
- Formulario para ingeniero: seleccionar productor, finca/s, cuartel/es, escribir texto, adjuntar archivos.
- Validar que al menos una entidad esté seleccionada.
- Guardar en la tabla y disparar lógica de mail.

### Consultas de informes de visitas
- El productor puede ver todos los informes asociados a su usuario, fincas y cuarteles.
- Al consultar una finca, mostrar informes de esa finca y del productor.
- Al consultar un cuartel, mostrar informes de ese cuartel, de la finca y del productor (herencia).
- Filtros por fecha, ingeniero, entidad, etc.

# Creación de fincas y cuarteles por ingeniero
- El ingeniero podrá crear fincas y cuarteles para un productor (el productor no podrá cargarlos por sí mismo).
- Se mantiene la estructura de relaciones: fincas asociadas a cada productor y cuarteles asociados a cada finca.
- Esto permite que el ingeniero gestione la estructura productiva y evite errores de carga por parte del productor.
El ingeniero puede crear un informe de visita y asociarlo a un productor, a una o varias fincas, o a uno o varios cuarteles.
Si selecciona productor, el informe será texto general para el productor.
Si selecciona finca/s, el informe será para esas finca/s.
Si selecciona cuarteles, el informe será para esos cuarteles.
El productor podrá ver estos informes como reporte o de otra forma.
Al ver un reporte de una entidad menor (por ejemplo, finca o cuartel), se deben mostrar también los informes que fueron aplicados a una entidad mayor o superior (herencia de informes).
Ejemplo: Si se consulta el reporte de un cuartel, se deben traer los informes aplicados al cuartel, a la finca correspondiente y al productor asociado.
Requiere definir la estructura de la tabla de informes, lógica de asociación y consulta jerárquica.


**Este archivo debe mantenerse actualizado a medida que se avanza en el desarrollo.**