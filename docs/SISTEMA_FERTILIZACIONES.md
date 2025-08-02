# 🌱 Sistema de Fertilizaciones - Documento de Trabajo

## 📋 Información del Proyecto
- **Fecha de inicio**: 2 de agosto de 2025
- **Rama**: `Fertilizaciones`
- **Estado**: 🚧 En desarrollo
- **Desarrollador**: GitHub Copilot + mgaldeano

---

## 🎯 Objetivo General
Implementar un sistema completo de registro y gestión de fertilizaciones que permita a los productores agrícolas llevar un control detallado de las aplicaciones de fertilizantes en sus fincas y cuarteles, **cumpliendo con los estándares Global GAP** para certificación agrícola.

---

## 🔧 Funcionalidades Principales

### ✅ Por Implementar:
- [ ] **Página principal** - `fertilizaciones.html`
- [x] **Base de datos** - Tablas y esquemas ✅
- [ ] **Registro de fertilizaciones** - Sistema batch múltiple
- [ ] **Gestión de fertilizantes** - CRUD de productos
- [ ] **Reportes y análisis** - Dashboard de fertilizaciones
- [ ] **Filtros avanzados** - Búsquedas complejas
- [ ] **Integración** - Enlaces con sistema existente

### 📊 Características Técnicas:
- [ ] **Bootstrap Select** - Selectores múltiples
- [ ] **Paginación** - Lista de aplicaciones
- [ ] **Validaciones** - Frontend y backend
- [ ] **RLS Policies** - Seguridad por usuario
- [ ] **Responsive Design** - Mobile friendly
- [ ] **Modal de detalles** - Ver aplicaciones completas

---

## 🗄️ Diseño de Base de Datos

### Tabla Principal: `fertilizaciones`
```sql
CREATE TABLE fertilizaciones (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id),
    finca_id INTEGER REFERENCES fincas(id),
    cuartel_id INTEGER REFERENCES cuarteles(id),
    fertilizante_id INTEGER REFERENCES fertilizantes_disponibles(id),
    fecha DATE NOT NULL,
    dosis DECIMAL(10,2) NOT NULL,
    unidad_dosis VARCHAR(20) NOT NULL, -- kg/ha, l/ha, gr/planta, etc.
    metodo_aplicacion VARCHAR(50) NOT NULL, -- foliar, suelo, fertirrigacion, hidroponico, etc.
    sistema_aplicacion VARCHAR(30), -- hidroponico, fertirrigacion, convencional
    superficie_aplicada DECIMAL(10,2), -- hectareas
    operador_id INTEGER REFERENCES aplicadores_operarios(id),
    equipo_trabajadores TEXT, -- JSON: nombres del equipo aplicador
    costo_total DECIMAL(10,2),
    clima VARCHAR(50), -- soleado, nublado, lluvia, etc.
    humedad_suelo VARCHAR(20), -- seco, humedo, saturado
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tabla Soporte: `fertilizantes_disponibles`
```sql
CREATE TABLE fertilizantes_disponibles (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id),
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- granulado, liquido, foliar, organico, bioestimulante
    subtipo VARCHAR(50), -- inorganico, organico, bioestimulante
    composicion TEXT, -- NPK 20-10-10, etc.
    concentracion VARCHAR(50), -- % de nutrientes
    -- Porcentajes de nutrientes para cálculos automáticos
    porcentaje_n DECIMAL(5,2) DEFAULT 0, -- % Nitrógeno
    porcentaje_p DECIMAL(5,2) DEFAULT 0, -- % Fósforo (P₂O₅)
    porcentaje_k DECIMAL(5,2) DEFAULT 0, -- % Potasio (K₂O)
    porcentaje_ca DECIMAL(5,2) DEFAULT 0, -- % Calcio
    porcentaje_mg DECIMAL(5,2) DEFAULT 0, -- % Magnesio
    porcentaje_s DECIMAL(5,2) DEFAULT 0, -- % Azufre
    micronutrientes TEXT, -- JSON: {"B": 0.1, "Zn": 0.5, "Fe": 2.0}
    unidad_venta VARCHAR(20), -- kg, litros, bolsas
    precio_unidad DECIMAL(10,2),
    fabricante VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Índices Propuestos:
```sql
-- Índices para optimizar consultas
CREATE INDEX idx_fertilizaciones_usuario_fecha ON fertilizaciones(usuario_id, fecha);
CREATE INDEX idx_fertilizaciones_finca_cuartel ON fertilizaciones(finca_id, cuartel_id);
CREATE INDEX idx_fertilizaciones_fertilizante ON fertilizaciones(fertilizante_id);
CREATE INDEX idx_fertilizantes_usuario_activo ON fertilizantes_disponibles(usuario_id, activo);
```

### Políticas RLS:
```sql
-- Políticas de seguridad
ALTER TABLE fertilizaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE fertilizantes_disponibles ENABLE ROW LEVEL SECURITY;

-- Solo acceso a datos propios
CREATE POLICY "Users can manage their own fertilizations"
    ON fertilizaciones
    FOR ALL
    USING (usuario_id = auth.uid());

CREATE POLICY "Users can manage their own fertilizers"
    ON fertilizantes_disponibles
    FOR ALL
    USING (usuario_id = auth.uid());
```

---

## 🎨 Diseño de Interfaz

### Estructura de `fertilizaciones.html`:
```
📄 fertilizaciones.html
├── 🏠 Header (reutilizado)
├── 🎯 Título y navegación
├── 📊 Cards de tipos de fertilización
│   ├── 🌱 Fertilizante Inorgánico (NPK)
│   ├── 🍃 Fertilizante Orgánico
│   ├── ⚡ Bioestimulantes
│   ├── 💧 Fertirrigación
│   └── 🏭 Sistema Hidropónico
├── 📝 Formulario de registro
│   ├── ℹ️ Información básica
│   ├── 🧪 Detalles del fertilizante
│   ├── 📏 Dosis y aplicación
│   └── 💰 Costo y observaciones
├── 📋 Lista de fertilizaciones
│   ├── 🔍 Filtros avanzados
│   ├── 📄 Paginación
│   └── 👁️ Modal de detalles
└── 🔧 Gestión de fertilizantes
```

### Flujo de Usuario:
1. **Seleccionar tipo** de fertilización desde cards visuales
2. **Completar formulario** con selección múltiple de fincas/cuarteles
3. **Elegir fertilizante** del catálogo disponible (con % de nutrientes)
4. **Definir dosis** y método de aplicación
5. **Registrar aplicación** en todos los cuarteles seleccionados
6. **Ver y filtrar** aplicaciones realizadas
7. **Generar reportes** con cálculos automáticos de nutrientes

### 📊 Dashboard de Nutrientes:
```
🧮 Panel de Análisis Nutricional
├── 📈 Gráfico de barras: Nutrientes aplicados por mes
├── 🥧 Gráfico circular: Distribución N-P-K
├── 📋 Tabla resumen: kg por nutriente y por cuartel
├── 💰 Costo por kg de nutriente aplicado
├── 🎯 Eficiencia: kg nutriente / hectárea
└── 📅 Planificación: Próximas aplicaciones sugeridas
```

---

## 📈 Sistema de Reportes

### Reportes Principales:
- [ ] **Consumo por fertilizante** - Cantidad utilizada en período
- [ ] **Unidades de nutrientes aplicadas** - Cálculo automático por componente (N-P-K)
- [ ] **Costo por hectárea** - Análisis económico
- [ ] **Frecuencia de aplicaciones** - Programa de fertilización
- [ ] **Comparativo por cuartel** - Rendimiento vs fertilización
- [ ] **Calendario de aplicaciones** - Planificación temporal
- [ ] **Balance nutricional** - Análisis de nutrientes por período

### Métricas Clave:
- Total de aplicaciones por mes
- **Unidades reales de nutrientes** (kg N, kg P₂O₅, kg K₂O aplicados)
- Costo promedio por hectárea
- Fertilizantes más utilizados
- Superficie total fertilizada
- Dosis promedio por cultivo
- **Eficiencia nutricional** por cuartel/finca

### 🧮 Cálculo de Unidades de Nutrientes:

#### Fórmula Base:
```
Unidades de Nutriente = (% Nutriente / 100) × Cantidad Aplicada × Superficie
```

#### Ejemplo Práctico:
```
Fertilizante: NPK 20-10-10 (20% N, 10% P₂O₅, 10% K₂O)
Dosis aplicada: 150 kg/ha
Superficie: 5 hectáreas
Cantidad total: 150 × 5 = 750 kg

Unidades aplicadas:
- Nitrógeno (N): (20/100) × 750 = 150 kg N
- Fósforo (P₂O₅): (10/100) × 750 = 75 kg P₂O₅  
- Potasio (K₂O): (10/100) × 750 = 75 kg K₂O
```

#### Implementación en BD:
```sql
-- Campos adicionales en fertilizantes_disponibles
ALTER TABLE fertilizantes_disponibles ADD COLUMN porcentaje_n DECIMAL(5,2);
ALTER TABLE fertilizantes_disponibles ADD COLUMN porcentaje_p DECIMAL(5,2);
ALTER TABLE fertilizantes_disponibles ADD COLUMN porcentaje_k DECIMAL(5,2);
ALTER TABLE fertilizantes_disponibles ADD COLUMN porcentaje_otros TEXT; -- JSON para otros nutrientes

-- Vista para cálculos automáticos
CREATE VIEW reporte_nutrientes AS
SELECT 
    f.fecha,
    fi.nombre_finca,
    c.nombre as cuartel,
    fd.nombre as fertilizante,
    f.dosis,
    f.superficie_aplicada,
    (f.dosis * f.superficie_aplicada) as cantidad_total,
    -- Cálculo de unidades de nutrientes
    ROUND((fd.porcentaje_n/100) * (f.dosis * f.superficie_aplicada), 2) as kg_nitrogeno,
    ROUND((fd.porcentaje_p/100) * (f.dosis * f.superficie_aplicada), 2) as kg_fosforo,
    ROUND((fd.porcentaje_k/100) * (f.dosis * f.superficie_aplicada), 2) as kg_potasio
FROM fertilizaciones f
JOIN fertilizantes_disponibles fd ON f.fertilizante_id = fd.id
JOIN fincas fi ON f.finca_id = fi.id
JOIN cuarteles c ON f.cuartel_id = c.id;
```

---

## 🔄 Integración con Sistema Existente

### Enlaces requeridos:
- [ ] **tareas.html** - Agregar botón "Fertilizaciones"
- [ ] **header.html** - Menú de navegación
- [ ] **index.html** - Dashboard principal
- [ ] **reportes.html** - Integrar reportes de fertilización

### Datos compartidos:
- ✅ **fincas** - Reutilizar tabla existente
- ✅ **cuarteles** - Reutilizar tabla existente  
- ✅ **aplicadores_operarios** - Reutilizar tabla existente
- ✅ **auth.users** - Sistema de autenticación existente

---

## 🧪 Testing y Validaciones

### Validaciones Frontend:
- [ ] Campos obligatorios marcados
- [ ] Dosis mínimas y máximas
- [ ] Fechas válidas (no futuras)
- [ ] Selección de al menos una finca/cuartel
- [ ] Formato numérico en costos

### Validaciones Backend:
- [ ] Políticas RLS funcionando
- [ ] Integridad referencial
- [ ] Tipos de datos correctos
- [ ] Triggers de actualización

### Casos de Prueba:
- [ ] Registro de fertilización simple
- [ ] Registro batch en múltiples cuarteles
- [ ] Gestión de fertilizantes CRUD
- [ ] **Cálculo automático de unidades de nutrientes**
- [ ] **Reportes de balance nutricional por período**
- [ ] Filtros y búsquedas
- [ ] Reportes con datos reales
- [ ] **Validación de porcentajes de nutrientes (suma ≤ 100%)**

---

## 🌍 Cumplimiento Global GAP

### ✅ Requisitos Cubiertos:

#### **Registro de Aplicaciones:**
- ✅ **Zona geográfica**: Finca y cuartel específico registrados
- ✅ **Fecha(s)**: Campo fecha obligatorio
- ✅ **Nombre y tipo**: Fertilizante seleccionado del catálogo
- ✅ **Cantidad/dosis**: Campo dosis con unidades específicas
- ✅ **Aplicador**: Operador/equipo responsable identificado
- ✅ **Sistemas especiales**: Hidropónicos y fertirrigación incluidos
- ✅ **Tipos cubiertos**: Orgánicos, inorgánicos y bioestimulantes

#### **Mediciones y Cálculos:**
- ✅ **NPK total aplicado**: Cálculo automático en kg por cultivo/mes/ha
- ✅ **Unidades de tiempo**: Registros por ciclo vegetativo y mes
- ✅ **Cantidad por hectárea**: kg de producto y nutrientes por ha
- ✅ **Fertilizantes orgánicos e inorgánicos**: Ambos tipos registrados

### 📊 Reportes Global GAP Específicos:

#### **1. Resumen Mensual NPK (Global GAP):**
```sql
-- Reporte mensual de nutrientes por finca (Global GAP)
SELECT 
    fi.nombre_finca,
    DATE_TRUNC('month', f.fecha) as mes,
    SUM(ROUND((fd.porcentaje_n/100) * (f.dosis * f.superficie_aplicada), 2)) as kg_nitrogeno_mes,
    SUM(ROUND((fd.porcentaje_p/100) * (f.dosis * f.superficie_aplicada), 2)) as kg_fosforo_mes,
    SUM(ROUND((fd.porcentaje_k/100) * (f.dosis * f.superficie_aplicada), 2)) as kg_potasio_mes,
    SUM(f.superficie_aplicada) as hectareas_totales
FROM fertilizaciones f
JOIN fertilizantes_disponibles fd ON f.fertilizante_id = fd.id
JOIN fincas fi ON f.finca_id = fi.id
WHERE f.fecha >= DATE_TRUNC('year', CURRENT_DATE)
GROUP BY fi.nombre_finca, DATE_TRUNC('month', f.fecha)
ORDER BY fi.nombre_finca, mes;
```

#### **2. NPK por Hectárea por Mes (Global GAP):**
```sql
-- kg/ha/mes para cumplimiento Global GAP
SELECT 
    fi.nombre_finca,
    c.nombre as cuartel,
    DATE_TRUNC('month', f.fecha) as mes,
    ROUND(SUM((fd.porcentaje_n/100) * f.dosis), 2) as kg_n_por_ha_mes,
    ROUND(SUM((fd.porcentaje_p/100) * f.dosis), 2) as kg_p_por_ha_mes,
    ROUND(SUM((fd.porcentaje_k/100) * f.dosis), 2) as kg_k_por_ha_mes
FROM fertilizaciones f
JOIN fertilizantes_disponibles fd ON f.fertilizante_id = fd.id
JOIN fincas fi ON f.finca_id = fi.id
JOIN cuarteles c ON f.cuartel_id = c.id
GROUP BY fi.nombre_finca, c.nombre, DATE_TRUNC('month', f.fecha)
ORDER BY mes DESC;
```

#### **3. Registro de Auditoría (Global GAP):**
```sql
-- Vista completa para auditorías Global GAP
CREATE VIEW auditoria_global_gap AS
SELECT 
    fi.nombre_finca as "Zona Geográfica",
    c.nombre as "Campo/Sector",
    f.fecha as "Fecha Aplicación",
    fd.nombre as "Nombre Fertilizante",
    fd.subtipo as "Tipo (Orgánico/Inorgánico/Bioestimulante)",
    f.dosis || ' ' || f.unidad_dosis as "Cantidad/Dosis",
    COALESCE(ao.nombre, f.equipo_trabajadores) as "Aplicador/Equipo",
    f.sistema_aplicacion as "Sistema Aplicación",
    ROUND((fd.porcentaje_n/100) * (f.dosis * f.superficie_aplicada), 2) as "kg N Aplicado",
    ROUND((fd.porcentaje_p/100) * (f.dosis * f.superficie_aplicada), 2) as "kg P Aplicado",
    ROUND((fd.porcentaje_k/100) * (f.dosis * f.superficie_aplicada), 2) as "kg K Aplicado"
FROM fertilizaciones f
JOIN fertilizantes_disponibles fd ON f.fertilizante_id = fd.id
JOIN fincas fi ON f.finca_id = fi.id
JOIN cuarteles c ON f.cuartel_id = c.id
LEFT JOIN aplicadores_operarios ao ON f.operador_id = ao.id
ORDER BY f.fecha DESC;
```

### 📋 Documentación para Auditoría:
- [ ] **Certificados de análisis** de fertilizantes
- [ ] **Capacitación** del personal aplicador
- [ ] **Procedimientos** de aplicación documentados
- [ ] **Mapas de aplicación** por zonas/cuarteles

### 🔧 Futuras Funcionalidades (Global GAP):
- [ ] **🚜 Gestión de Maquinarias y Herramientas**
  - Registro de equipos de aplicación
  - Calendarios de calibración
  - Historial de mantenimiento
  - Certificados de calibración
  - Control de vida útil de equipos

---

## 📝 Notas de Desarrollo

### Decisiones de Diseño:
- **Reutilizar componentes** del sistema de labores exitoso
- **Bootstrap Select** para consistencia visual
- **Sistema batch** para eficiencia operativa
- **Modularidad** para facilitar mantenimiento

### Consideraciones Especiales:
- **Unidades de medida** - Flexibilidad para diferentes tipos
- **Métodos de aplicación** - Catálogo extensible
- **Condiciones climáticas** - Registro para análisis
- **Cálculos automáticos** - Costo por hectárea, etc.

### Próximos Pasos:
1. ✅ Crear documento de trabajo (COMPLETADO)
2. 🔄 Diseñar base de datos detallada
3. 🔄 Implementar página principal
4. 🔄 Desarrollar formulario de registro
5. 🔄 Crear sistema de reportes

### 🔮 Futuras Extensiones del Sistema:
- [ ] **🚜 Gestión de Maquinarias y Herramientas**
  - CRUD de equipos de aplicación
  - Calendario de calibraciones
  - Historial de mantenimiento
  - Integración con aplicaciones de fertilizantes
  - Alertas de vencimiento de calibraciones
- [ ] **📱 App móvil** para registro en campo
- [ ] **🌡️ Integración climática** - APIs meteorológicas  
- [ ] **📊 BI Avanzado** - Dashboards ejecutivos

---

## 📊 Control de Versiones

### Commits Importantes:
- `ea70382` - 🌱 Inicio de rama Fertilizaciones

### Archivos Clave:
- `docs/SISTEMA_FERTILIZACIONES.md` - Este documento
- `fertilizaciones.html` - (Pendiente)
- `scripts-debug/crear_tabla_fertilizaciones.sql` - ✅ Script SQL completo
- `scripts-debug/fertilizaciones_rls.sql` - (Incluido en script principal)

---

## 🎯 Estado Actual
**📍 Fase**: Planificación y documentación  
**⏳ Tiempo estimado**: 2-3 días de desarrollo  
**🎲 Próxima acción**: Crear esquema de base de datos

---

*Última actualización: 2 de agosto de 2025 - 11:30*
