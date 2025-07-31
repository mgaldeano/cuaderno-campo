# Resumen de Reportes - Cuaderno de Campo

Este archivo sirve como referencia y espacio de trabajo para definir, editar y documentar cómo deben ser los reportes del sistema. Aquí se detallan los campos, filtros, visualización y exportación para cada tipo de reporte.

---

## Generalidades
- Todos los reportes deben permitir filtrar por finca, cuartel, regador/operador, fecha desde/hasta.
- Los filtros deben ser multi-selección (checkboxes) y tener botones "todo/nada" compactos.
- La visualización debe ser en tabla, con columnas principales y exportación a Excel, PDF y CSV.
- El footer y la consola deben mostrar la versión actual.

---

## Reporte de Riegos
**Campos principales:**

**Filtros:**

**Exportación:**

---

## Reporte de Riegos por Regador
**Campos principales:**
- fecha
- Regador (Apellido, Nombre)
- Finca (nombre)
- Cuartel (nombre)
- horas_riego
- volumen_agua
- observaciones

**Filtros:**
- Regador (multi, mostrar "Apellido, Nombre")
- Fecha desde (predefinida 01/01/2000)
- Fecha hasta (predefinida fecha actual)

**Exportación:**
- Solo columnas principales
- Excel, PDF, CSV
---

## Reporte de Agroquímicos
**Campos principales:**
- fecha
- Finca
- Cuartel
- Operador
- producto
- dosis
- observaciones

**Filtros:**
- Finca
- Cuartel
- Operador
- Fecha desde/hasta

**Exportación:**
- Solo columnas principales
- Excel, PDF, CSV

---

## Reporte de Fertilizaciones
**Campos principales:**
- fecha
- Finca
- Cuartel
- Operador
- fertilizante
- dosis
- observaciones

**Filtros:**
- Finca
- Cuartel
- Operador
- Fecha desde/hasta

**Exportación:**
- Solo columnas principales
- Excel, PDF, CSV

---

## Reporte de Labores
**Campos principales:**
- fecha
- Finca
- Cuartel
- Operador
- labor
- maquinaria
- observaciones

**Filtros:**
- Finca
- Cuartel
- Operador
- Fecha desde/hasta

**Exportación:**
- Solo columnas principales
- Excel, PDF, CSV

---

## Notas y pendientes
- Adaptar los reportes a la estructura de la base de datos actual.
- Validar que los filtros y columnas sean consistentes en la interfaz y exportaciones.
- Documentar cambios y versiones en este archivo.

---

> Edita este archivo para agregar detalles, ejemplos, dudas o decisiones sobre los reportes.
