## Pendientes próximos pasos (25/07/2025)

1. Asegurar que el help funcione correctamente en todas las páginas (botón flotante y modal).
2. Idear la lógica de reportes: definir tipos, filtros y estructura de consultas.
   - Incluir reporte especial para normas BPA (Buenas Prácticas Agrícolas): mostrar registros, tareas y controles relevantes para auditoría y certificación.
3. Crear los reportes: implementar consultas, filtros y visualización.
   - Agregar opción en la UI para generar el reporte BPA, con filtros y formato adecuado para inspección/auditoría.
4. Agregar gestión de tractores e implementos.
5. Agregar mantenimiento de tractores e implementos.
6. Desarrollar la lógica y el código para tractores e implementos (incluyendo base de datos, formularios y reportes).
# Cambios recientes (25/07/2025)
- Ayuda contextual de riego: texto externo mejorado y verificado, con logs de versión para depuración.
- Ancho de columna 'Regador' ampliado y propagación inmediata al hacer click o change.
- Fix robusto para el cierre del modal de ayuda (delegación de eventos).

* Mejorar experiencia móvil y responsive: revisar tablas, formularios y botones para una visualización y uso óptimos en celulares. Tener en cuenta si se hacen otros cambios visuales o de flujo.
# Futuras tareas y mejoras - Cuaderno de Campo

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

**Este archivo debe mantenerse actualizado a medida que se avanza en el desarrollo.**