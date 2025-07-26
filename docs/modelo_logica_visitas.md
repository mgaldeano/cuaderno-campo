# Modelo y lógica de VISITAS (informes de ingeniero)

## Esquema SQL sugerido
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

## Seguridad y RLS
- Solo el ingeniero puede crear, editar y borrar informes de visita.
- El productor puede consultar los informes asociados a su usuario, finca o cuartel.
- Los adjuntos deben validarse y almacenarse en bucket seguro (ej: Supabase Storage).

## Lógica de mails
- Al crear un informe, se envía mail inmediato al productor (si tiene mail registrado).
- Alternativamente, se puede enviar un resumen semanal con todos los informes nuevos.
- El mail incluye el texto, fecha, ingeniero, entidad asociada y links a adjuntos.

## Carga de informe
- Formulario para ingeniero: seleccionar productor, finca/s, cuartel/es, escribir texto, adjuntar archivos.
- Validar que al menos una entidad esté seleccionada.
- Guardar en la tabla y disparar lógica de mail.

## Consultas de informes de visitas
- El productor puede ver todos los informes asociados a su usuario, fincas y cuarteles.
- Al consultar una finca, mostrar informes de esa finca y del productor.
- Al consultar un cuartel, mostrar informes de ese cuartel, de la finca y del productor (herencia).
- Filtros por fecha, ingeniero, entidad, etc.

## Herencia de informes
- Al ver un reporte de una entidad menor (ej: finca o cuartel), mostrar también los informes aplicados a una entidad mayor o superior.
- Ejemplo: Si se consulta el reporte de un cuartel, traer los informes aplicados al cuartel, a la finca correspondiente y al productor asociado.

---
Actualizado: 26/07/2025
