# Esquema de Base de Datos Actualizado

**Fecha:** 1 de agosto de 2025  
**Estado:** ✅ Validado y funcional - **Incluye nueva tabla labores_suelo**

## Resumen de Tablas

El sistema cuenta con **16 tablas principales** y **1 vista** para gestionar la información agrícola:

| Tabla | Registros Tipo | Descripción |
|-------|----------------|-------------|
| `aplicadores_operarios` | Personas | Operarios y regadores de las fincas |
| `cuarteles` | Ubicaciones | Subdivisiones de las fincas con especies/variedades |
| `cuartel_variedades` | Relaciones | Tabla de unión cuartel-variedad |
| `cuarteles_completos` | Vista | Vista combinada de cuarteles con información completa |
| `especies` | Catálogos | Tipos de cultivos (ej: Vid, Olivo) |
| `fertilizantes` | Catálogos | Productos de fertilización con composición química |
| `fincas` | Ubicaciones | Propiedades agrícolas principales |
| `fitosanitarios` | Catálogos | Productos para control de plagas y enfermedades |
| `labores_suelo` | Actividades | **NUEVO** - Registro de labores y actividades agrícolas |
| `metodos_de_aplicacion` | Catálogos | Formas de aplicar productos (pulverización, riego, etc.) |
| `operario_finca` | Relaciones | Asignación de operarios a fincas |
| `organizaciones` | Entidades | Empresas o cooperativas que agrupan usuarios |
| `riegos` | Actividades | Registro de riegos realizados |
| `tareas` | Actividades | Tareas generales de campo |
| `tipos_tarea` | Catálogos | Clasificación de tipos de tareas |
| `usuarios` | Personas | Usuarios del sistema con roles |
| `variedades` | Catálogos | Variedades específicas de cada especie |
| `visitas` | Actividades | Visitas técnicas e informes |

---

## Detalle de Columnas por Tabla

### 🧑‍🌾 `aplicadores_operarios`
Operarios y regadores que trabajan en las fincas.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | uuid | NO | Identificador único |
| `nombre` | text | NO | Nombre del operario |
| `apellido` | text | YES | Apellido del operario |
| `cuit` | text | YES | CUIT/DNI |
| `telefono` | text | YES | Número de contacto |
| `direccion` | text | YES | Dirección personal |
| `rol` | text | YES | Función (regador, tractorista, etc.) |
| `finca_id` | bigint | YES | Finca principal de trabajo |
| `usuario_id` | uuid | YES | Usuario asociado en el sistema |
| `created_at` | timestamp | YES | Fecha de creación |

### 🏡 `fincas`
Propiedades agrícolas principales.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | bigint | NO | Identificador único |
| `nombre_finca` | text | NO | Nombre de la finca |
| `usuario_id` | uuid | YES | Propietario/usuario responsable |
| `direccion` | text | YES | Ubicación física |
| `superficie` | numeric | YES | Hectáreas totales |
| `provincia` | text | YES | Provincia de ubicación |
| `departamento` | text | YES | Departamento de ubicación |
| `created_at` | timestamp | YES | Fecha de creación |

### � `labores_suelo` ⭐ **NUEVA**
Registro de labores y actividades agrícolas realizadas en las fincas.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | uuid | NO | Identificador único |
| `fecha` | timestamp with time zone | NO | Fecha y hora de la labor |
| `finca_id` | bigint | NO | Finca donde se realizó |
| `cuartel_id` | bigint | NO | Cuartel específico |
| `tipo_labor` | text | NO | Tipo de actividad (arado, poda, cosecha, etc.) |
| `objetivo` | text | NO | Propósito de la labor |
| `tiempo_horas` | numeric(6,2) | YES | Tiempo invertido en horas (default: 0) |
| `operador_id` | uuid | NO | Operario que ejecutó la labor |
| `maquinaria` | text | YES | Maquinaria/herramientas utilizadas (default: 'ninguna') |
| `superficie_hectareas` | numeric(10,2) | YES | Superficie trabajada en hectáreas |
| `costo` | numeric(10,2) | YES | Costo total de la labor |
| `resultado` | text | YES | Efectividad: excelente/bueno/regular/malo |
| `observaciones` | text | YES | Notas y comentarios adicionales |
| `usuario_id` | uuid | NO | Usuario que registró la labor |
| `created_at` | timestamp with time zone | YES | Fecha de creación del registro |
| `updated_at` | timestamp with time zone | YES | Fecha de última modificación |

**Categorías de Labores:**
- **Suelo**: Arado, rastreo, subsolado, cultivada, aporque, desorillada
- **Cultivo**: Injertos
- **Mantenimiento**: Poda, desmalezado, limpieza general, mantenimiento de riego
- **Cosecha**: Recolección

**Características especiales:**
- ✅ RLS habilitado (usuarios ven solo sus labores)
- ✅ Campos dinámicos (maquinaria y tareas personalizables)
- ✅ Objetivos reutilizables
- ✅ Trigger automático para `updated_at`
- ✅ Índices optimizados para consultas por fecha, finca, tipo

### �🗺️ `cuarteles`
Subdivisiones de las fincas donde se cultivan especies específicas.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | bigint | NO | Identificador único |
| `nombre` | text | NO | Nombre del cuartel |
| `finca_id` | bigint | YES | Finca a la que pertenece |
| `superficie` | numeric | YES | Hectáreas del cuartel |
| `nro_viñedo` | text | YES | Número de viñedo (si aplica) |
| `provincia` | text | YES | Provincia |
| `departamento` | text | YES | Departamento |
| `especie` | text | YES | Especie cultivada (texto libre) |
| `variedad` | text | YES | Variedad cultivada (texto libre) |
| `especie_id` | uuid | YES | Referencia a tabla especies |
| `created_at` | timestamp | YES | Fecha de creación |

### 💧 `riegos`
Registro de todas las actividades de riego realizadas.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | bigint | NO | Identificador único |
| `finca_id` | bigint | YES | Finca donde se realizó |
| `cuartel_id` | bigint | YES | Cuartel específico |
| `operador_id` | uuid | YES | Operario que realizó el riego |
| `fecha` | date | YES | Fecha del riego |
| `variedad` | text | YES | Variedad regada |
| `especie` | text | YES | Especie regada |
| `labor` | text | YES | Tipo de labor realizada |
| `labores` | text | YES | Descripción de labores |
| `objetivo` | text | YES | **⭐ Objetivo del riego** |
| `maquinaria` | text | YES | Equipo utilizado |
| `horas_riego` | numeric | YES | Duración en horas |
| `volumen_agua` | numeric | YES | Litros o m³ utilizados |
| `observaciones` | text | YES | Notas adicionales |
| `created_at` | timestamp | YES | Fecha de creación |

### 👥 `usuarios`
Usuarios del sistema con diferentes roles de acceso.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | uuid | NO | Identificador único |
| `nombre` | text | YES | Nombre completo |
| `email` | text | YES | Correo electrónico |
| `cuit` | text | YES | CUIT/DNI |
| `telefono` | text | YES | Teléfono de contacto |
| `rol` | text | YES | **Rol:** `productor`, `ingeniero`, `operador` |
| `organizacion_id` | uuid | YES | Organización a la que pertenece |
| `created_at` | timestamp | YES | Fecha de creación |

### 🌱 `especies`
Catálogo de especies que se pueden cultivar.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | uuid | NO | Identificador único |
| `nombre` | text | NO | Nombre de la especie (Vid, Olivo, etc.) |

### 🍇 `variedades`
Variedades específicas de cada especie.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | uuid | NO | Identificador único |
| `nombre` | text | NO | Nombre de la variedad |
| `color` | text | YES | Color de la fruta/producto |
| `tipo_destino` | text | YES | Destino (mesa, vino, etc.) |
| `especie_id` | uuid | YES | Especie a la que pertenece |

### 🏢 `organizaciones`
Empresas, cooperativas o entidades que agrupan usuarios.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | uuid | NO | Identificador único |
| `nombre` | text | NO | Nombre de la organización |
| `logo_url` | text | YES | URL del logotipo |
| `color_base` | text | YES | Color corporativo |

### 🧪 `fertilizantes`
Catálogo de productos de fertilización con composición química.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | uuid | NO | Identificador único |
| `producto` | text | YES | Nombre comercial |
| `formula` | text | YES | Fórmula química |
| `n` | numeric | YES | % Nitrógeno |
| `p` | numeric | YES | % Fósforo |
| `k` | numeric | YES | % Potasio |
| `ca` | numeric | YES | % Calcio |
| `mg` | numeric | YES | % Magnesio |
| `s` | numeric | YES | % Azufre |
| `fe` | numeric | YES | % Hierro |
| `mn` | numeric | YES | % Manganeso |
| `zn` | numeric | YES | % Zinc |
| `cu` | numeric | YES | % Cobre |
| `bo` | numeric | YES | % Boro |
| `mo` | numeric | YES | % Molibdeno |
| `cl` | numeric | YES | % Cloro |
| `ph` | text | YES | pH del producto |
| `otro` | text | YES | Otros componentes |

### 🐛 `fitosanitarios`
Productos para control de plagas y enfermedades.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | bigint | NO | Identificador único |
| `nombre_comercial` | text | NO | Nombre comercial del producto |
| `principio_activo` | text | YES | Ingrediente activo |
| `formulacion` | text | YES | Tipo de formulación |
| `plaga_o_enfermedad` | text | YES | Para qué se usa |
| `accion` | text | YES | Modo de acción |
| `tc_tiempo_carencia` | text | YES | Tiempo de carencia |
| `ct` | text | YES | Clasificación toxicológica |
| `dosis_marbete` | text | YES | Dosis según marbete |
| `unidad_marbete` | text | YES | Unidad de medida |
| `lmr_senasa` | text | YES | Límite máximo residuo SENASA |
| `lmr_eu` | text | YES | Límite máximo residuo UE |
| `uso` | text | YES | Instrucciones de uso |
| `dosis_frecuente_100l` | text | YES | Dosis por 100L |
| `registro_para` | text | YES | Cultivos registrados |

### 🚿 `metodos_de_aplicacion`
Formas de aplicar productos fitosanitarios o fertilizantes.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | integer | NO | Identificador único |
| `nombre` | text | NO | Nombre del método |
| `descripcion` | text | YES | Descripción detallada |

### 📋 `tareas`
Registro de tareas generales realizadas en los cuarteles.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | bigint | NO | Identificador único |
| `fecha` | date | YES | Fecha de la tarea |
| `cuartel_id` | bigint | YES | Cuartel donde se realizó |
| `tipo_tarea_id` | integer | YES | Tipo de tarea |
| `tipo_tarea_old` | text | YES | Campo legacy |
| `duracion` | integer | YES | Duración en minutos |
| `cant_agua` | integer | YES | Cantidad de agua (si aplica) |
| `obs` | text | YES | Observaciones |
| `created_at` | timestamp | YES | Fecha de creación |

### 📝 `tipos_tarea`
Clasificación de los tipos de tareas que se pueden realizar.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | integer | NO | Identificador único |
| `nombre` | text | NO | Nombre del tipo de tarea |
| `requiere_duracion` | boolean | YES | Si requiere duración |
| `requiere_agua` | boolean | YES | Si requiere cantidad de agua |
| `requiere_obs` | boolean | YES | Si requiere observaciones |

### 🔗 `cuartel_variedades`
Tabla de unión entre cuarteles y variedades (relación N:M).

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `cuartel_id` | bigint | NO | ID del cuartel |
| `variedad_id` | uuid | NO | ID de la variedad |

### 🤝 `operario_finca`
Asignación de operarios a fincas específicas.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `operario_id` | uuid | NO | ID del operario |
| `finca_id` | bigint | NO | ID de la finca |
| `estado` | text | NO | Estado de la asignación |

### 🏥 `visitas`
Registro de visitas técnicas e informes.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | integer | NO | Identificador único |
| `fecha` | timestamp | NO | Fecha y hora de la visita |
| `texto` | text | NO | Contenido del informe |
| `id_productor` | uuid | NO | Productor visitado |
| `id_finca` | bigint | YES | Finca visitada |
| `id_cuartel` | bigint | YES | Cuartel específico |
| `id_ingeniero` | uuid | NO | Ingeniero que realizó la visita |
| `adjuntos` | jsonb | YES | Archivos adjuntos |
| `enviado_mail` | boolean | YES | Si se envió por email |

### 👁️ `cuarteles_completos` (Vista)
Vista que combina información de cuarteles con datos relacionados.

| Columna | Tipo | Nullable | Descripción |
|---------|------|----------|-------------|
| `id` | bigint | YES | ID del cuartel |
| `nombre` | text | YES | Nombre del cuartel |
| `superficie` | numeric | YES | Superficie en hectáreas |
| `nro_viñedo` | text | YES | Número de viñedo |
| `especie_texto` | text | YES | Especie (texto libre) |
| `especie_nombre` | text | YES | Especie (desde catálogo) |
| `especie_id` | uuid | YES | ID de la especie |
| `nombre_finca` | text | YES | Nombre de la finca |
| `finca_id` | bigint | YES | ID de la finca |
| `created_at` | timestamp | YES | Fecha de creación |

---

## 🔑 Relaciones Principales

```
usuarios (1) ←→ (N) fincas
fincas (1) ←→ (N) cuarteles  
cuarteles (N) ←→ (M) variedades [via cuartel_variedades]
especies (1) ←→ (N) variedades
organizaciones (1) ←→ (N) usuarios
aplicadores_operarios (N) ←→ (M) fincas [via operario_finca]

riegos → fincas (N:1)
riegos → cuarteles (N:1)  
riegos → aplicadores_operarios (N:1)
tareas → cuarteles (N:1)
tareas → tipos_tarea (N:1)
visitas → usuarios (N:1) [productor]
visitas → usuarios (N:1) [ingeniero]
visitas → fincas (N:1)
visitas → cuarteles (N:1)
```

---

## ⚠️ Notas Importantes

### Campos Críticos para Reportes
- **`riegos.objetivo`**: ✅ Disponible - Se muestra en reportes
- **`aplicadores_operarios.apellido`**: ✅ Disponible - Formato "Apellido, Nombre"
- **`fincas.nombre_finca`**: ✅ Usar este campo (NO `nombre`)

### Campos Duales en `riegos`
- `labor` y `labores`: Ambos disponibles, usar según contexto
- `variedad` y `especie`: Texto libre vs referencias a catálogos

### Consideraciones de Desarrollo
- Usar `cuarteles_completos` para reportes complejos
- `operario_finca` maneja asignaciones múltiples
- `visitas.adjuntos` en formato JSONB para flexibilidad

---

**✅ Esquema validado el 30/07/2025**  
**🔄 Última sincronización: Funcional en reportes**
