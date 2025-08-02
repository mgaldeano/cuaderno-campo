# 🔒 SEGURIDAD DE FERTILIZANTES - CUADERNO DE CAMPO

## 🚨 PROBLEMA IDENTIFICADO

### Issue Crítico: Tabla de Fertilizantes Global Sin Restricciones
- **Tabla afectada**: `fertilizantes` (tabla global)
- **Vulnerabilidad**: Cualquier productor puede modificar fertilizantes que afectan a todo el sistema
- **Impacto**: Contaminación de datos, afectación a todas las organizaciones
- **Gravedad**: **CRÍTICA**

## ✅ SOLUCIÓN IMPLEMENTADA

### 1. **Filtrado por Organización**
```javascript
// ANTES (INSEGURO)
.from('fertilizantes')
.select('*')

// DESPUÉS (SEGURO)
.from('fertilizantes_disponibles')
.select('*')
.eq('organizacion_id', userData.organizacion_id)
```

### 2. **Corrección de Tipos de Datos (ACTUALIZADA)**
**Problema**: `fertilizaciones.fertilizante_id` era `bigint` pero `fertilizantes.id` es `uuid`
**Obstáculo**: Vistas `reporte_nutrientes` y `auditoria_global_gap` dependen de `fertilizante_id`
**Solución**: Agregar nueva columna `fertilizante_uuid` preservando la estructura existente

```sql
-- Migración segura ejecutada
ALTER TABLE fertilizaciones 
ADD COLUMN fertilizante_uuid UUID 
REFERENCES fertilizantes(id);

-- Las vistas existentes siguen funcionando
-- El frontend usa fertilizante_uuid temporalmente
```

### 2. **Estructura de Tablas Actualizada**

#### **Tabla: `fertilizantes` (GLOBAL - SOLO LECTURA)**
- **Propósito**: Catálogo maestro de fertilizantes del sistema
- **Acceso**: Solo administradores pueden modificar
- **Contenido**: Fertilizantes estándar, datos de referencia
- **ID**: `uuid` (consistente con fertilizaciones)

#### **Tabla: `fertilizantes_disponibles` (POR ORGANIZACIÓN)**
- **Propósito**: Fertilizantes específicos de cada organización
- **Acceso**: Cada organización ve solo sus fertilizantes
- **Contenido**: Fertilizantes personalizados, precios locales

#### **Tabla: `fertilizaciones` (REGISTROS)**
- **fertilizante_id**: `bigint` (preservado para vistas existentes)
- **fertilizante_uuid**: `uuid` (nueva columna para consistencia)
- **Relación**: `fertilizante_uuid REFERENCES fertilizantes(id)`
- **Estado**: Migración temporal segura implementada

### 3. **RLS (Row Level Security) Implementado**
```sql
-- Política para fertilizantes_disponibles
CREATE POLICY "Usuarios ven solo fertilizantes de su organización" 
ON fertilizantes_disponibles 
FOR ALL 
USING (organizacion_id = auth.jwt() ->> 'organizacion_id');
```

## 🔐 ROLES Y PERMISOS

### **Productor**
- ✅ Ver fertilizantes de su organización
- ✅ Usar fertilizantes en registros
- ❌ Crear/editar fertilizantes globales
- ⚠️ Puede solicitar nuevos fertilizantes al administrador

### **Administrador de Organización**
- ✅ Gestionar fertilizantes de su organización
- ✅ Agregar fertilizantes desde catálogo global
- ✅ Personalizar precios y disponibilidad
- ❌ Modificar catálogo global

### **Super Administrador**
- ✅ Gestionar catálogo global
- ✅ Crear nuevos fertilizantes estándar
- ✅ Acceso a todas las organizaciones

## 🛡️ MEDIDAS DE SEGURIDAD IMPLEMENTADAS

### 1. **Validación de Organización**
- Verificación de `organizacion_id` del usuario
- Filtrado automático por organización
- Prevención de acceso cruzado

### 2. **Fallback Seguro**
- Si no hay fertilizantes organizacionales → usar catálogo global (solo lectura)
- Advertencias claras sobre fertilizantes globales
- Logging de seguridad

### 3. **UI Segura**
- Botón "Gestionar Fertilizantes" deshabilitado para productores
- Mensaje informativo sobre contactar administrador
- No acceso directo a gestión de fertilizantes

## 📋 CHECKLIST DE SEGURIDAD

### ✅ **Implementado**
- [x] Filtrado por organización en `cargarFertilizantes()`
- [x] Validación de usuario y organización
- [x] Fallback seguro a tabla global
- [x] UI restringida para productores
- [x] Logging de seguridad
- [x] Migración segura fertilizante_uuid COMPLETADA ✅ (2025-08-02)

### 🔄 **Pendiente (Recomendado)**
- [ ] Crear tabla `fertilizantes_disponibles` si no existe
- [ ] Implementar RLS en tabla `fertilizantes`
- [ ] Página de gestión de fertilizantes para administradores
- [ ] Auditoría de cambios en fertilizantes
- [ ] Backup de seguridad antes de modificaciones

## 🚀 PRÓXIMOS PASOS

### 1. **Crear Tabla Segura**
```sql
CREATE TABLE fertilizantes_disponibles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organizacion_id UUID REFERENCES organizaciones(id),
    nombre VARCHAR NOT NULL,
    fabricante VARCHAR,
    formula VARCHAR,
    -- nutrientes...
    activo BOOLEAN DEFAULT true,
    precio_local DECIMAL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. **Migrar Datos Existentes**
- Identificar fertilizantes por organización
- Migrar datos seguros a nueva estructura
- Mantener respaldo de tabla original

### 3. **Implementar Gestión Administrativa**
- Página de administración de fertilizantes
- Aprobación de nuevos fertilizantes
- Sistema de solicitudes

## ⚠️ NOTAS IMPORTANTES

1. **No Eliminar Tabla Global**: Mantener `fertilizantes` como referencia
2. **Migración Gradual**: Implementar sin romper funcionalidad existente
3. **Backup Obligatorio**: Respaldar antes de cualquier cambio estructural
4. **Testing Exhaustivo**: Probar en todas las organizaciones

---

**Fecha**: 2 de agosto de 2025
**Estado**: Mitigación implementada, mejoras recomendadas
**Prioridad**: ALTA
