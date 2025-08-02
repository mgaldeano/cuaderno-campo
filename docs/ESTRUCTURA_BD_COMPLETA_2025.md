# 📊 ESTRUCTURA COMPLETA DE BASE DE DATOS - CUADERNO DE CAMPO

**Fecha de actualización:** 2 de agosto de 2025  
**Estado:** ✅ Validado y funcional  
**Última revisión:** Tabla fertilizaciones agregada - Sistema completo

---

## 🏗️ RESUMEN ARQUITECTURAL

### Configuración Supabase
- **URL:** `https://djvdjulfeuqohpnatdmt.supabase.co`
- **Autenticación:** Habilitada con RLS (Row Level Security)
- **Roles:** `anon`, `authenticated`, `public`

### Tablas Principales: 16 + 1 Vista
- **Entidades:** usuarios, organizaciones, fincas, cuarteles, especies, variedades
- **Actividades:** riegos, tareas, visitas, fertilizaciones
- **Catálogos:** fertilizantes, fitosanitarios, metodos_de_aplicacion, tipos_tarea
- **Relaciones:** cuartel_variedades, operario_finca, aplicadores_operarios

---

## 📋 DETALLE COMPLETO DE TABLAS

### 👥 **usuarios** (Usuarios del sistema)
```sql
CREATE TABLE usuarios (
    id uuid PRIMARY KEY,
    nombre text,                    -- Username (=email)
    nombre_pila text,              -- Nombre real
    apellido text,                 -- Apellido real
    email text,                    -- Email único
    cuit text,
    telefono text,
    rol text,                      -- 'productor', 'ingeniero', 'operador', 'admin', 'superadmin'
    organizacion_id uuid REFERENCES organizaciones(id),
    created_at timestamp with time zone DEFAULT now()
);
```

**Políticas RLS activas:**
- ✅ `Public read usuarios` - Lectura pública
- ✅ `Usuarios pueden ver sus datos` - Ver propios datos
- ✅ `Usuarios pueden editar sus datos` - Editar propios datos
- ✅ `Admin y Superadmin pueden modificar usuarios`
- ✅ `Admins e ingenieros pueden ver todos los usuarios`

### 🏢 **organizaciones** (Empresas/Cooperativas)
```sql
CREATE TABLE organizaciones (
    id uuid PRIMARY KEY,
    nombre text NOT NULL,
    logo_url text,
    color_base text
);
```

**Políticas RLS activas:**
- ✅ `Public read organizaciones` - Lectura pública para registro

### 🏡 **fincas** (Propiedades agrícolas)
```sql
CREATE TABLE fincas (
    id bigint PRIMARY KEY,
    nombre_finca text NOT NULL,
    usuario_id uuid REFERENCES usuarios(id),
    direccion text,
    superficie numeric,
    provincia text,
    departamento text,
    created_at timestamp with time zone DEFAULT now()
);
```

**Políticas RLS activas:**
- ✅ `Solo dueño puede insertar fincas`
- ✅ `Solo dueño puede modificar sus fincas`
- ✅ `Solo dueño puede borrar sus fincas`
- ✅ `Ingeniero puede ver todas las fincas` (rol ingeniero/admin)

### 🗺️ **cuarteles** (Subdivisiones de fincas)
```sql
CREATE TABLE cuarteles (
    id bigint PRIMARY KEY,
    nombre text NOT NULL,
    finca_id bigint REFERENCES fincas(id),
    superficie numeric,
    nro_viñedo text,
    provincia text,
    departamento text,
    especie text,                  -- Texto libre
    variedad text,                 -- Texto libre
    especie_id uuid REFERENCES especies(id),
    created_at timestamp with time zone DEFAULT now()
);
```

**Políticas RLS activas:**
- ✅ `Solo dueño de la finca puede ver y modificar`
- ✅ `Admins e ingenieros pueden ver todos los cuarteles`
- ✅ `insert own cuartel`, `select own cuarteles`

### 🌱 **especies** (Catálogo de cultivos)
```sql
CREATE TABLE especies (
    id uuid PRIMARY KEY,
    nombre text NOT NULL           -- Vid, Olivo, etc.
);
```

**Políticas RLS activas:**
- ✅ `Solo lectura para usuarios autenticados`

### 🍇 **variedades** (Variedades por especie)
```sql
CREATE TABLE variedades (
    id uuid PRIMARY KEY,
    nombre text NOT NULL,
    color text,
    tipo_destino text,             -- mesa, vino, aceite, etc.
    especie_id uuid REFERENCES especies(id)
);
```

**Políticas RLS activas:**
- ✅ `Solo lectura para usuarios autenticados`

### 🔗 **cuartel_variedades** (Relación N:M)
```sql
CREATE TABLE cuartel_variedades (
    cuartel_id bigint REFERENCES cuarteles(id),
    variedad_id uuid REFERENCES variedades(id),
    PRIMARY KEY (cuartel_id, variedad_id)
);
```

**Políticas RLS activas:**
- ✅ `Solo dueño del cuartel puede ver`
- ✅ `Usuarios autenticados pueden insertar variedades por cuartel`

### 🧑‍🌾 **aplicadores_operarios** (Personal de campo)
```sql
CREATE TABLE aplicadores_operarios (
    id uuid PRIMARY KEY,
    nombre text NOT NULL,
    apellido text,
    cuit text,
    telefono text,
    direccion text,
    rol text,                      -- regador, tractorista, etc.
    finca_id bigint REFERENCES fincas(id),
    usuario_id uuid REFERENCES usuarios(id),
    created_at timestamp with time zone DEFAULT now()
);
```

**Políticas RLS activas:**
- ✅ `Solo dueño puede insertar aplicadores/operarios`
- ✅ `Solo dueño puede ver sus aplicadores/operarios`
- ✅ `Solo dueño puede modificar o borrar sus aplicadores/operarios`

### 🤝 **operario_finca** (Asignaciones N:M)
```sql
CREATE TABLE operario_finca (
    operario_id uuid REFERENCES usuarios(id),
    finca_id bigint REFERENCES fincas(id),
    estado text NOT NULL,          -- activo, pendiente, revocado
    PRIMARY KEY (operario_id, finca_id)
);
```

**Políticas RLS activas:**
- ✅ `Solo dueño puede ver`

### 💧 **riegos** (Registro de riegos)
```sql
CREATE TABLE riegos (
    id bigint PRIMARY KEY,
    finca_id bigint REFERENCES fincas(id),
    cuartel_id bigint REFERENCES cuarteles(id),
    operador_id uuid REFERENCES usuarios(id),
    fecha date,
    variedad text,
    especie text,
    labor text,
    labores text,
    objetivo text,                 -- ⭐ Campo importante para reportes
    maquinaria text,
    horas_riego numeric,
    volumen_agua numeric,
    observaciones text,
    created_at timestamp with time zone DEFAULT now()
);
```

**Políticas RLS activas:**
- ✅ `Solo dueño o su operario puede ver riegos`
- ✅ `Modificar solo mis riegos o los de mis fincas`
- ✅ `Borrar solo mis riegos o los de mis fincas`
- ✅ `Permitir insert a usuarios autenticados`

### 📋 **tareas** (Tareas generales)
```sql
CREATE TABLE tareas (
    id bigint PRIMARY KEY,
    fecha date,
    cuartel_id bigint REFERENCES cuarteles(id),
    tipo_tarea_id integer REFERENCES tipos_tarea(id),
    tipo_tarea_old text,           -- Campo legacy
    duracion integer,              -- minutos
    cant_agua integer,
    obs text,
    created_at timestamp with time zone DEFAULT now()
);
```

**Políticas RLS activas:**
- ✅ `insert own tarea`
- ✅ `select own tareas`

### 📝 **tipos_tarea** (Catálogo de tipos)
```sql
CREATE TABLE tipos_tarea (
    id integer PRIMARY KEY,
    nombre text NOT NULL,
    requiere_duracion boolean,
    requiere_agua boolean,
    requiere_obs boolean
);
```

**Políticas RLS activas:**
- ✅ `Solo lectura para usuarios autenticados`

### 🌱 **fertilizaciones** (Registro de fertilizaciones)
```sql
CREATE TABLE fertilizaciones (
    id bigint PRIMARY KEY,
    usuario_id uuid NOT NULL,
    finca_id bigint NOT NULL,
    cuartel_id bigint NOT NULL,
    fertilizante_id bigint NOT NULL,
    fecha date NOT NULL,
    dosis numeric NOT NULL,                    -- Campo legacy (mantener compatibilidad)
    unidad_dosis character varying NOT NULL,   -- Campo legacy
    metodo_aplicacion character varying NOT NULL,
    sistema_aplicacion character varying,      -- inorganico, organico, foliares, etc.
    superficie_aplicada numeric,               -- Campo legacy
    operador_id uuid,                          -- UUID del operador
    equipo_trabajadores text,
    costo_total numeric,
    clima character varying,
    humedad_suelo character varying,
    observaciones text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    -- NUEVOS CAMPOS (enfoque cantidades reales)
    dosis_referencia numeric,                  -- Dosis recomendada (referencia)
    unidad_dosis_referencia character varying DEFAULT 'kg/ha',
    cantidad_aplicada numeric,                 -- CANTIDAD REAL aplicada (campo principal)
    unidad_cantidad character varying DEFAULT 'kg',  -- kg, litros, gramos, ml
    superficie_cuartel numeric,                -- Superficie específica del cuartel
    dosis_real_calculada numeric              -- cantidad_aplicada / superficie_cuartel
);
```

**Políticas RLS activas:**
- ✅ `Solo dueño puede insertar fertilizaciones`
- ✅ `Solo dueño puede modificar sus fertilizaciones`
- ✅ `Solo dueño puede ver sus fertilizaciones`
- ✅ `Admins e ingenieros pueden ver todas las fertilizaciones`

**Campos Críticos:**
- `cantidad_aplicada` - **Campo principal** para control de inventario
- `dosis_referencia` - Información orientativa del fabricante
- `superficie_cuartel` - Superficie específica tratada
- `dosis_real_calculada` - Cálculo automático para análisis

### 🏥 **visitas** (Visitas técnicas)
```sql
CREATE TABLE visitas (
    id integer PRIMARY KEY,
    fecha timestamp without time zone NOT NULL,
    texto text NOT NULL,
    id_productor uuid REFERENCES usuarios(id) NOT NULL,
    id_finca bigint REFERENCES fincas(id),
    id_cuartel bigint REFERENCES cuarteles(id),
    id_ingeniero uuid REFERENCES usuarios(id) NOT NULL,
    adjuntos jsonb,
    enviado_mail boolean
);
```

**Políticas RLS activas:**
- ✅ `visitas_edit_admins` - Ingenieros pueden editar
- ✅ `visitas_prod_view` - Productores pueden ver sus visitas

### 🧪 **fertilizantes** (Catálogo de fertilizantes)
```sql
CREATE TABLE fertilizantes (
    id uuid PRIMARY KEY,
    producto text,
    formula text,
    n numeric,                     -- % Nitrógeno
    p numeric,                     -- % Fósforo
    k numeric,                     -- % Potasio
    ca numeric,                    -- % Calcio
    mg numeric,                    -- % Magnesio
    s numeric,                     -- % Azufre
    fe numeric,                    -- % Hierro
    mn numeric,                    -- % Manganeso
    zn numeric,                    -- % Zinc
    cu numeric,                    -- % Cobre
    bo numeric,                    -- % Boro
    mo numeric,                    -- % Molibdeno
    cl numeric,                    -- % Cloro
    ph text,
    otro text
);
```

**Políticas RLS activas:**
- ✅ `Solo lectura para usuarios autenticados`

### 🐛 **fitosanitarios** (Productos fitosanitarios)
```sql
CREATE TABLE fitosanitarios (
    id bigint PRIMARY KEY,
    nombre_comercial text NOT NULL,
    principio_activo text,
    formulacion text,
    plaga_o_enfermedad text,
    accion text,
    tc_tiempo_carencia text,
    ct text,                       -- Clasificación toxicológica
    dosis_marbete text,
    unidad_marbete text,
    lmr_senasa text,
    lmr_eu text,
    uso text,
    dosis_frecuente_100l text,
    registro_para text
);
```

**Políticas RLS activas:**
- ✅ `Solo lectura para usuarios autenticados`

### 🚿 **metodos_de_aplicacion** (Métodos de aplicación)
```sql
CREATE TABLE metodos_de_aplicacion (
    id integer PRIMARY KEY,
    nombre text NOT NULL,
    descripcion text
);
```

**Políticas RLS activas:**
- ✅ `Solo lectura para usuarios autenticados`

---

## 🔑 RELACIONES PRINCIPALES

```
usuarios (1) ←→ (N) fincas [usuario_id]
fincas (1) ←→ (N) cuarteles [finca_id]
cuarteles (N) ←→ (M) variedades [cuartel_variedades]
especies (1) ←→ (N) variedades [especie_id]
organizaciones (1) ←→ (N) usuarios [organizacion_id]

# Actividades
riegos → fincas (N:1) [finca_id]
riegos → cuarteles (N:1) [cuartel_id]
riegos → usuarios (N:1) [operador_id]
tareas → cuarteles (N:1) [cuartel_id]
tareas → tipos_tarea (N:1) [tipo_tarea_id]
fertilizaciones → fincas (N:1) [finca_id]
fertilizaciones → cuarteles (N:1) [cuartel_id]
fertilizaciones → usuarios (N:1) [usuario_id, operador_id]
fertilizaciones → fertilizantes (N:1) [fertilizante_id]
visitas → usuarios (N:1) [id_productor, id_ingeniero]
visitas → fincas (N:1) [id_finca]
visitas → cuarteles (N:1) [id_cuartel]

# Personal
aplicadores_operarios → fincas (N:1) [finca_id]
aplicadores_operarios → usuarios (N:1) [usuario_id]
operario_finca → usuarios (N:1) [operario_id]
operario_finca → fincas (N:1) [finca_id]
```

---

## 🛡️ RESUMEN DE POLÍTICAS RLS

### Por Rol de Usuario:

**🔓 Público (`public`, `anon`):**
- ✅ Lectura: `organizaciones` (para registro)
- ✅ Insertar: `usuarios` (para registro)

**🔐 Autenticado (`authenticated`):**
- ✅ Lectura completa: catálogos (`especies`, `variedades`, `fertilizantes`, etc.)
- ✅ CRUD propio: `fincas`, `cuarteles`, `riegos`, `tareas`
- ✅ Gestión operarios: `aplicadores_operarios`, `operario_finca`

**👔 Ingeniero/Admin:**
- ✅ Lectura ampliada: todas las `fincas`, `cuarteles`, `usuarios`
- ✅ Gestión visitas: CRUD completo en `visitas`
- ✅ Administración: según rol específico

**🔐 Lógica de Propiedad:**
- Cada usuario solo ve/modifica sus propias fincas y cuarteles
- Los operarios asignados pueden registrar actividades
- Los ingenieros tienen acceso de lectura general para asesoramiento

---

## 📊 CAMPOS CRÍTICOS PARA REPORTES

### Campos Obligatorios:
- `riegos.objetivo` - ⭐ Objetivo del riego (disponible)
- `fincas.nombre_finca` - Usar este campo (NO `nombre`)
- `aplicadores_operarios.apellido` - Para formato "Apellido, Nombre"
- `fertilizaciones.cantidad_aplicada` - ⭐ Campo principal para inventario
- `fertilizaciones.sistema_aplicacion` - Tipo de fertilización

### Campos Duales:
- `riegos.labor` vs `riegos.labores` - Ambos disponibles
- `cuarteles.especie` vs `especies.nombre` - Texto libre vs catálogo
- `cuarteles.variedad` vs `variedades.nombre` - Texto libre vs catálogo
- `fertilizaciones.dosis` vs `fertilizaciones.cantidad_aplicada` - Legacy vs actual

### Campos de Fertilizaciones:
- `dosis_referencia` - Información orientativa del fabricante
- `cantidad_aplicada` - **Campo principal** para control real
- `superficie_cuartel` - Superficie específica tratada
- `dosis_real_calculada` - Cálculo automático para análisis

---

## ⚠️ CONSIDERACIONES DE DESARROLLO

### Permisos Granulares Futuros:
Se recomienda implementar tabla `operador_cuartel` para permisos por cuartel:

```sql
CREATE TABLE operador_cuartel (
    operador_id uuid REFERENCES usuarios(id),
    cuartel_id bigint REFERENCES cuarteles(id),
    permiso text NOT NULL,         -- 'lectura', 'registro', 'admin'
    estado text NOT NULL,          -- 'activo', 'pendiente', 'revocado'
    created_at timestamp with time zone DEFAULT now(),
    PRIMARY KEY (operador_id, cuartel_id)
);
```

### Flujo de Asignación de Permisos:
1. Productor accede a gestión de cuartel
2. Busca operador por email o lista
3. Asigna permisos específicos
4. Sistema crea registro en `operador_cuartel`
5. RLS valida permisos en cada consulta

### Migración de Usuarios:
- Campo `usuarios.nombre` = username (email)
- Campos `usuarios.nombre_pila` y `usuarios.apellido` = datos reales
- Formularios actualizados para separar nombre y apellido

---

## 🔧 COMANDOS ÚTILES PARA DESARROLLO

### Verificar RLS:
```sql
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename, cmd;
```

### Verificar Usuario Actual:
```sql
SELECT auth.uid(), auth.role();
```

### Test de Permisos:
```sql
-- Como usuario específico
SELECT * FROM fincas WHERE usuario_id = auth.uid();
SELECT * FROM cuarteles WHERE finca_id IN (
    SELECT id FROM fincas WHERE usuario_id = auth.uid()
);
```

---

**✅ Estructura validada el 2/08/2025**  
**🔄 Última sincronización: Tabla fertilizaciones agregada - Sistema completo**  
**📱 Compatible con aplicación web y futuras expansiones móviles**
