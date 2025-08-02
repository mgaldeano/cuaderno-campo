# Futuras tareas agregadas (01/08/2025):
## ✅ COMPLETADO: Sistema de Labores Agrícolas
- **Implementación completa** del módulo `labores-suelo.html` con funcionalidades avanzadas:
  - ✅ Tabla `labores_suelo` creada en Supabase con RLS habilitado
  - ✅ Sistema dinámico de categorías: Suelo, Cultivo, Mantenimiento, Cosecha
  - ✅ Campos personalizables: tareas, maquinaria y objetivos reutilizables
  - ✅ Campos opcionales: tiempo (horas), superficie, costo, resultado
  - ✅ Interfaz completa con Bootstrap 5 y validación en tiempo real
  - ✅ CRUD completo con listado, filtros y acciones de gestión
  - ✅ Documentación actualizada en esquema de BD
- **Archivos creados/modificados**:
  - `labores-suelo.html` - Interfaz principal (23k+ líneas)
  - `scripts-debug/crear_tabla_labores_suelo.sql` - Script de creación de tabla
  - `archivos de trabajo/ESQUEMA_BD_ACTUALIZADO.md` - Documentación actualizada
- **Funcionalidades destacadas**:
  - Objetivos reutilizables con dropdown inteligente
  - Maquinaria y tareas dinámicas expandibles por usuario
  - Seguimiento de costos y efectividad de labores
  - Integración completa con fincas, cuarteles y operadores

# Futuras tareas agregadas (31/07/2025):
- Limpieza de políticas RLS: eliminación de reglas redundantes en tablas fincas y cuarteles
- Corrección de carga de fincas y cuarteles para roles admin, superadmin e ingeniero
- Refactor de funciones cargarFincas y cargarCuarteles para mayor claridad y robustez
### Pendiente: Menú desplegable de Gestión (header)
- Solucionar definitivamente el stacking y el parpadeo del menú desplegable sobre las tarjetas del dashboard en index.html.
- El menú debe quedar siempre por encima de las tarjetas, sin parpadear ni perder el foco, y correctamente alineado.
- Revisar posibles conflictos de stacking context, z-index y eventos de Bootstrap.

### Pendiente: Agregar campo apellido a tabla usuarios
- **Problema identificado**: La tabla `usuarios` actualmente solo tiene el campo `nombre`, pero para reportes profesionales y identificación completa se necesita también `apellido`.
- **Tareas**:
  - [ ] Agregar columna `apellido` a la tabla `usuarios` en Supabase
  - [ ] Actualizar formularios de registro/edición de usuarios para incluir apellido
  - [ ] Modificar usuarios.html para mostrar y editar apellido
  - [ ] Actualizar reportes PDF para mostrar "Apellido, Nombre" cuando esté disponible
  - [ ] Actualizar header.js y otras partes que muestren nombre del usuario
- **Prioridad**: Media - mejora la presentación profesional en reportes y documentos
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

## PRÓXIMOS REPORTES A IMPLEMENTAR

### Sistema de Reportes Completo
Todos los reportes seguirán el mismo estilo y estructura que el sistema actual de reportes de riegos, con filtros de fecha desde/hasta y interfaz completamente en español.

#### Reportes de Agroquímicos
- **Aplicaciones de agroquímicos por finca**: Mostrar todas las aplicaciones de fitosanitarios agrupadas por finca, con detalles de producto, dosis, método de aplicación, operador, fecha, cuartel, objetivo y observaciones.
- **Aplicaciones de agroquímicos por productor**: Reporte consolidado de todas las aplicaciones realizadas para un productor específico, agrupando por finca.

#### Reportes de Fertilizaciones  
- **Fertilizaciones por finca**: Aplicaciones de fertilizantes organizadas por finca, incluyendo producto, dosis, método, operador, fecha, cuartel y observaciones.
- **Fertilizaciones por productor**: Vista consolidada de todas las fertilizaciones del productor.

#### Reportes de Labores de Suelo
- **Labores de suelo por finca**: Actividades de preparación, cultivo y mantenimiento del suelo por finca.
- **Labores de suelo por productor**: Consolidado de labores para el productor.

#### Informes Especiales
- **Informes personalizados**: Reportes específicos que se definirán según necesidades particulares (BPA, auditorías, etc.).

**Características comunes de todos los reportes:**
- Interfaz en español
- Filtros de fecha desde/hasta
- Selección múltiple cuando aplique
- Agrupación por finca con encabezados individuales
- Exportación a CSV/Excel
- Estilo consistente con el sistema actual de reportes de riegos

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


---

## [31/07/2025] Permisos de operadores por cuartel: implementación completa (backend y UI)

### 1. SQL y backend

- Se creó la tabla `operador_cuartel` para gestionar permisos de operadores sobre cada cuartel:

```sql
CREATE TABLE operador_cuartel (
  operador_id uuid NOT NULL REFERENCES usuarios(id),
  cuartel_id bigint NOT NULL REFERENCES cuarteles(id),
  permiso text NOT NULL, -- 'lectura', 'registro', 'admin', etc.
  estado text NOT NULL,  -- 'activo', 'pendiente', 'revocado', etc.
  created_at timestamp with time zone DEFAULT now(),
  PRIMARY KEY (operador_id, cuartel_id)
);
```

- Supabase expone la tabla como endpoint RESTful para alta, baja y modificación de permisos.

#### Ejemplos de uso desde Supabase JS:

```js
// Listar permisos de un cuartel
await supabase.from('operador_cuartel').select('*').eq('cuartel_id', cuartelId);
// Asignar permiso
await supabase.from('operador_cuartel').insert([{ operador_id, cuartel_id, permiso: 'registro', estado: 'activo' }]);
// Modificar permiso
await supabase.from('operador_cuartel').update({ permiso: 'lectura' }).eq('operador_id', operadorId).eq('cuartel_id', cuartelId);
// Revocar permiso
await supabase.from('operador_cuartel').delete().eq('operador_id', operadorId).eq('cuartel_id', cuartelId);
```

### 2. UI e integración en cuarteles.html

- Se agregó un botón "Permisos de operadores" en cada cuartel.
- Al hacer clic, se abre un panel/modal donde el productor puede:
  - Ver los operadores con acceso a ese cuartel y sus permisos.
  - Agregar un operador por email y asignar tipo de permiso.
  - Revocar permisos existentes.
- Todo conectado al backend Supabase usando la tabla `operador_cuartel`.
- El flujo y la lógica están documentados en estructura_bd_actualizada_2025.csv y el código fuente.

#### Pendiente (mejoras futuras):
- Permitir edición de tipo de permiso sin revocar.
- Mejorar la búsqueda y autocompletado de emails de operadores.
- Validaciones adicionales de RLS para máxima seguridad.

---


**Este archivo debe mantenerse actualizado a medida que se avanza en el desarrollo.**