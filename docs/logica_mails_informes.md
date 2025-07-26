# Lógica de envío de mails para informes de visita

## Descripción general
La lógica de mails para los informes de visita por ingeniero debe garantizar que el productor reciba notificaciones automáticas y que el proceso sea seguro y auditable.

## Pasos principales
1. **Disparador:** Cuando se crea o edita un registro en la tabla `visitas`.
2. **Destinatario:** El productor responsable de la finca (`fincas.usuario_id` → `usuarios.email`). Opcionalmente, copia al ingeniero y/o superadmin.
3. **Contenido:** Resumen del informe, adjuntos (fotos, PDF), enlace a la plataforma.
4. **Condiciones:** Solo enviar si el informe está completo. Evitar duplicados.
5. **Implementación:** Trigger SQL, función backend o Supabase Function. Consulta de email, armado del mail y envío por SMTP/API.
6. **Auditoría:** Registrar el envío en una tabla de logs para trazabilidad.

## Ejemplo de política de acceso (RLS)
- Permitir que solo ingenieros y superadmin editen, y productores consulten sus informes.

---
Actualizado: 26/07/2025
