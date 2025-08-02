# � MIGRACIÓN: fertilizante_id bigint → uuid ✅ COMPLETADA

## ✅ MIGRACIÓN EXITOSA

**Estado**: **COMPLETADA** ✅  
**Fecha**: 2 de agosto de 2025  
**Resultado**: Nueva columna `fertilizante_uuid` agregada exitosamente  
**Impacto**: Cero downtime, vistas preservadas  

### **Estructura Final:**
```
fertilizaciones:
├── fertilizante_id (bigint)   ← Preservada para vistas
└── fertilizante_uuid (uuid)   ← Nueva para frontend ✅
```🔧 MIGRACIÓN: fertilizante_id bigint → uuid

## � PROBLEMA IDENTIFICADO

**Error de dependencias**: Las vistas `reporte_nutrientes` y `auditoria_global_gap` dependen de `fertilizaciones.fertilizante_id`

```
ERROR: cannot drop column fertilizante_id of table fertilizaciones because other objects depend on it
DETAIL: view reporte_nutrientes depends on column fertilizante_id of table fertilizaciones
        view auditoria_global_gap depends on column fertilizante_id of table fertilizaciones
```

## ✅ ESTRATEGIA REVISADA

**Enfoque seguro**: Agregar nueva columna `fertilizante_uuid` sin eliminar la columna existente, preservando las vistas.

### **Ventajas de este enfoque:**
- ✅ No rompe vistas existentes
- ✅ Migración sin downtime  
- ✅ Rollback simple
- ✅ Testing seguro

---

## 🚨 PRERREQUISITOS

### 1. **Backup Obligatorio**
```sql
-- Crear backup de la tabla fertilizaciones
CREATE TABLE fertilizaciones_backup_20250802 AS 
SELECT * FROM fertilizaciones;
```

### 2. **Verificar Datos Existentes**
```sql
-- Contar registros existentes
SELECT COUNT(*) as total_registros FROM fertilizaciones;

-- Verificar si hay datos en fertilizante_id
SELECT COUNT(*) as registros_con_fertilizante 
FROM fertilizaciones 
WHERE fertilizante_id IS NOT NULL;
```

---

## 🔧 SCRIPTS DE MIGRACIÓN

### **Opción 1: Migración Simple (Tabla Vacía)**
Si la tabla `fertilizaciones` está vacía o no tiene datos críticos:

```sql
-- 1. Eliminar la columna existente
ALTER TABLE fertilizaciones 
DROP COLUMN fertilizante_id;

-- 2. Agregar la nueva columna como UUID
ALTER TABLE fertilizaciones 
ADD COLUMN fertilizante_id UUID NOT NULL 
REFERENCES fertilizantes(id);
```

### **Opción 2: Migración Compleja (Con Datos Existentes)**
Si hay datos existentes que necesitas preservar:

```sql
-- 1. Agregar nueva columna temporal
ALTER TABLE fertilizaciones 
ADD COLUMN fertilizante_id_uuid UUID;

-- 2. Migrar datos (requiere mapeo manual)
-- NOTA: Este paso requiere análisis de los datos existentes
-- UPDATE fertilizaciones SET fertilizante_id_uuid = [mapeo_correspondiente];

-- 3. Eliminar columna antigua
ALTER TABLE fertilizaciones 
DROP COLUMN fertilizante_id;

-- 4. Renombrar nueva columna
ALTER TABLE fertilizaciones 
RENAME COLUMN fertilizante_id_uuid TO fertilizante_id;

-- 5. Agregar restricciones
ALTER TABLE fertilizaciones 
ALTER COLUMN fertilizante_id SET NOT NULL;

ALTER TABLE fertilizaciones 
ADD CONSTRAINT fk_fertilizaciones_fertilizante 
FOREIGN KEY (fertilizante_id) REFERENCES fertilizantes(id);
```

---

## 🎯 SCRIPT RECOMENDADO (ACTUALIZADO)

**Estrategia segura** - Agregar nueva columna sin eliminar la existente:

```sql
-- =====================================
-- MIGRACIÓN SEGURA: Agregar fertilizante_uuid
-- Fecha: 2025-08-02
-- =====================================

-- 1. BACKUP DE SEGURIDAD
CREATE TABLE fertilizaciones_backup_20250802 AS 
SELECT * FROM fertilizaciones;

-- 2. AGREGAR NUEVA COLUMNA UUID
ALTER TABLE fertilizaciones 
ADD COLUMN fertilizante_uuid UUID;

-- 3. CREAR RELACIÓN CON FERTILIZANTES
ALTER TABLE fertilizaciones 
ADD CONSTRAINT fk_fertilizaciones_fertilizante_uuid 
FOREIGN KEY (fertilizante_uuid) REFERENCES fertilizantes(id);

-- 4. VERIFICAR RESULTADO
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fertilizaciones' 
AND column_name LIKE '%fertilizante%'
ORDER BY column_name;
```

---

## ✅ VALIDACIÓN POST-MIGRACIÓN

### 1. **Verificar Nueva Columna**
```sql
-- Verificar que la nueva columna existe
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'fertilizaciones' 
AND column_name = 'fertilizante_uuid';
```

### 2. **Probar Inserción**
```sql
-- Probar inserción con UUID válido en nueva columna
INSERT INTO fertilizaciones (
    usuario_id,
    finca_id,
    cuartel_id,
    fertilizante_uuid,  -- Nueva columna
    fecha,
    dosis,
    unidad_dosis,
    metodo_aplicacion
) VALUES (
    'cf16dae7-2a3f-4fb5-9a39-7faf7a56fd61',
    36,
    27,
    '2e20519a-5c8f-4a59-b455-65a2363fa750', -- UUID del fertilizante
    '2025-08-02',
    50.0,
    'kg/ha',
    'Manual'
);
```

### 3. **Verificar Vistas Intactas**
```sql
-- Verificar que las vistas siguen funcionando
SELECT COUNT(*) FROM reporte_nutrientes;
SELECT COUNT(*) FROM auditoria_global_gap;
```

---

## 🔄 ROLLBACK (Solo si es necesario)

```sql
-- EN CASO DE PROBLEMAS - ROLLBACK COMPLETO
BEGIN;

-- Restaurar desde backup
DROP TABLE fertilizaciones;
CREATE TABLE fertilizaciones AS 
SELECT * FROM fertilizaciones_backup_20250802;

-- Restaurar índices y restricciones originales
-- [Agregar comandos específicos según sea necesario]

COMMIT;
```

---

## 🎯 INSTRUCCIONES DE EJECUCIÓN

### **En Supabase Dashboard:**

1. **Ir a SQL Editor**
2. **Ejecutar verificación inicial:**
   ```sql
   SELECT COUNT(*) FROM fertilizaciones;
   ```

3. **Si tabla está vacía o con datos de prueba:**
   - Ejecutar el "Script Recomendado" completo

4. **Si tabla tiene datos importantes:**
   - Contactar para análisis de migración de datos

5. **Verificar resultado:**
   - Ejecutar scripts de validación

---

## 📝 NOTAS IMPORTANTES

1. **Coordinación con Frontend**: El frontend ya está preparado para enviar UUIDs
2. **Impacto en Aplicación**: Solucionará el error actual de tipos de datos
3. **Testing Required**: Probar flujo completo de fertilización después de migración
4. **Backup Critical**: No proceder sin backup de seguridad

---

**Responsable**: Martin Galdeano  
**Revisado**: Pendiente  
**Ejecutado**: Pendiente
