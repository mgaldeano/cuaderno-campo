# 📒 Cuaderno de Campo Digital

Aplicación web para cooperativas, productores y técnicos vitícolas. Permite registrar tareas, gestionar fincas, cuarteles y usuarios. Desarrollada con Supabase, HTML + PicoCSS.

---

## 🚀 Funcionalidades principales

- 🏡 Inicio y navegación por secciones
- 🌱 Gestión de Fincas y Cuarteles
- 🛠 Registro de Tareas (Riego, Tratamiento, Cosecha, etc.)
- 📊 Reportes por tipo de tarea y cuartel
- 👤 Sistema de autenticación:
  - Email y contraseña
  - Google Auth (OAuth)
- 🛡 Control de acceso por organización y roles

---

## 🧪 Estructura de carpetas

cuaderno-campo/
├── index.html
├── login.html
├── fincas.html
├── cuarteles.html
├── tareas.html
├── usuarios.html
├── reportes.html
├── supabaseClient.js
├── README.md




---

## 🔐 Configuración Supabase

1. Crear un proyecto en [Supabase](https://supabase.com)
2. Activar proveedores (Email y Google)
3. Crear tabla `usuarios` y relacionarlas con `organizaciones`
4. Editar `supabaseClient.js` con tu información:

```js
const supabase = createClient(
  'https://TUPROYECTO.supabase.co',
  'TU_ANON_KEY'
);


