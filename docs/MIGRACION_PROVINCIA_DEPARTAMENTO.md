# Migración: Provincia y Departamento de Cuarteles a Fincas

## Descripción
Se refactorizó la estructura de datos para mover los campos `provincia` y `departamento` desde la tabla `cuarteles` hacia la tabla `fincas`, ya que estos datos geográficos corresponden a la ubicación de la finca completa y no a cada cuartel individual.

## Cambios realizados

### 1. Actualización en fincas.html
- ✅ Agregados campos `provincia` y `departamento` al formulario
- ✅ Actualizada la visualización para mostrar provincia y departamento
- ✅ Modificadas las funciones de guardar/editar para incluir estos campos
- ✅ Agregadas validaciones JavaScript para los nuevos campos

### 2. Actualización en cuarteles.html
- ✅ Removidos campos `provincia` y `departamento` del formulario
- ✅ Actualizada `cargarFincas()` para incluir provincia/departamento de las fincas
- ✅ Modificada la visualización de cuarteles para mostrar provincia/departamento de la finca padre
- ✅ Actualizadas las funciones de guardar/editar para remover estos campos

### 3. Lógica mejorada
- ✅ Los cuarteles ahora heredan automáticamente provincia/departamento de su finca
- ✅ La información geográfica se centraliza en el nivel correcto (finca)
- ✅ Se reduce redundancia de datos y posibles inconsistencias

## Migración de Base de Datos Requerida

**ESTADO ACTUAL**: Los cambios de interfaz están implementados, pero los campos `provincia` y `departamento` aún no existen en la tabla `fincas` de la base de datos.

**SOLUCIÓN TEMPORAL**: El código actual detecta automáticamente si los campos existen en la BD y funciona con ambas estructuras (con y sin los nuevos campos).

**PARA APLICAR LA MIGRACIÓN COMPLETA**, ejecutar estos comandos SQL en Supabase:

```sql
-- 1. Agregar campos provincia y departamento a la tabla fincas
ALTER TABLE fincas 
ADD COLUMN provincia TEXT,
ADD COLUMN departamento TEXT;

-- 2. Migrar datos existentes de cuarteles a fincas (ejecutar solo una vez)
UPDATE fincas 
SET provincia = (
    SELECT DISTINCT provincia 
    FROM cuarteles 
    WHERE cuarteles.finca_id = fincas.id 
    AND provincia IS NOT NULL 
    LIMIT 1
),
departamento = (
    SELECT DISTINCT departamento 
    FROM cuarteles 
    WHERE cuarteles.finca_id = fincas.id 
    AND departamento IS NOT NULL 
    LIMIT 1
)
WHERE EXISTS (
    SELECT 1 FROM cuarteles 
    WHERE cuarteles.finca_id = fincas.id 
    AND (provincia IS NOT NULL OR departamento IS NOT NULL)
);

-- 3. Remover campos provincia y departamento de la tabla cuarteles
ALTER TABLE cuarteles 
DROP COLUMN provincia,
DROP COLUMN departamento;
```

## Validación Post-Migración

1. Verificar que las fincas tengan correctamente asignadas provincia y departamento
2. Confirmar que los cuarteles muestran la información geográfica de su finca padre
3. Probar la creación y edición de fincas con los nuevos campos
4. Probar la creación y edición de cuarteles sin campos redundantes

## Beneficios

1. **Consistencia de datos**: La información geográfica está centralizada donde corresponde
2. **Menos redundancia**: No se repite provincia/departamento en cada cuartel
3. **Menor probabilidad de errores**: Un solo lugar para mantener datos geográficos
4. **Lógica más clara**: Los cuarteles heredan automáticamente la ubicación de su finca
5. **Mejor UX**: Los usuarios configuran la ubicación una sola vez por finca

## Archivos modificados

- `fincas.html` - Formulario y lógica ampliados
- `cuarteles.html` - Formulario simplificado, visualización mejorada
- `MIGRACION_PROVINCIA_DEPARTAMENTO.md` - Esta documentación
