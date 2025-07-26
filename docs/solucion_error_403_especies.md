# Registro de solución de error 403 en especies

## Problema
- Error 403 al intentar cargar/editar especies desde la app (Supabase).
- Causa: Falta de política RLS que permita acceso a usuarios autenticados.

## Solución aplicada
- Se creó la política:

```sql
CREATE POLICY especies_all_authenticated
  ON especies
  FOR ALL
  USING (auth.role() = 'authenticated');
```
- Permite SELECT, INSERT, UPDATE y DELETE a cualquier usuario autenticado.
- Verificado: ya se puede cargar y editar especies correctamente.

## Recomendaciones
- Si en el futuro se requiere restricción por usuario, agregar campo `usuario_id` y usar `USING (usuario_id = auth.uid())`.
- Documentar todas las políticas RLS aplicadas en cada tabla para trazabilidad.

---
Actualizado: 26/07/2025
