# 📒 Cuaderno de Campo para Fincas Vitivinícolas

Aplicación web para registrar tareas agrícolas por cuarteles y fincas, ideal para productores o cooperativas del ámbito vitivinícola. Incluye gestión de usuarios, tareas, reportes y soporte multi-organización.

---

## 🛠️ Funcionalidades

- Registro de usuarios (con email y Google)
- Gestión de fincas, cuarteles y tareas
- Reportes dinámicos por cuartel o tipo de tarea
- Acceso basado en roles: productor, técnico, superadmin
- Adaptable para diferentes organizaciones

---

## 🧩 Estructura del Proyecto
/cuaderno-campo/
│
├── index.html # Página de inicio
├── fincas.html # Gestión de fincas
├── cuarteles.html # Gestión de cuarteles
├── tareas.html # Registro de tareas
├── reportes.html # Visualización de reportes
├── usuarios.html # Listado de usuarios
├── supabaseClient.js # Conexión centralizada con Supabase
└── README.md # Este archivo


---

## 🌐 Requisitos

- Una cuenta en [Supabase](https://supabase.com)
- Haber creado las siguientes tablas:
  - `usuarios`, `fincas`, `cuarteles`, `tareas`, `tipos_tarea`, `organizaciones`
- Aplicadas las políticas RLS y triggers provistos
- Clave pública de Supabase configurada en `supabaseClient.js`

---

## 🚀 Uso

1. Clonar este repositorio:

```bash
git clone https://github.com/mgaldeano/CuadernoDeCampo.git


