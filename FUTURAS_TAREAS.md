# Futuras tareas y mejoras - Cuaderno de Campo

## 1. Roles y permisos
- [ ] Crear el rol **ingeniero** en la tabla de usuarios.
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
- [ ] Crear página de selección de tipo de tarea (ej: `tareas.html` o `seleccionar-tarea.html`).
- [ ] Cada tipo de tarea debe tener su propio formulario y lógica.
- [ ] Actualizar el menú/header para que "Tareas" apunte a la nueva página de selección.

## 6. Permisos y validaciones
- [ ] Validar que solo el ingeniero pueda crear órdenes.
- [ ] Validar que solo los operarios asignados puedan registrar la ejecución.

## 7. Mejoras generales
- [ ] Permitir agregar nuevos tipos de tareas en el futuro de forma sencilla.
- [ ] Mejorar la experiencia de usuario en la selección y carga de tareas.

---

**Este archivo debe mantenerse actualizado a medida que se avanza en el desarrollo.**