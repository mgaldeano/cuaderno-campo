# 🔧 PROPUESTA DE REFACTORING DEL SISTEMA DE AUTH

## 📋 RESUMEN DE CAMBIOS PROPUESTOS

### 1. **Simplificar Registro**
- ✅ **Solo email + password** en registro inicial
- ✅ **Auto-completar perfil** después del primer login
- ✅ **Organización opcional** (puede agregarse después)
- ✅ **Rol "productor" por defecto**

### 2. **Crear Página "Mi Cuenta"**
- ✅ **Gestión completa de perfil**
- ✅ **Cambio de organización**
- ✅ **Preferencias del usuario**
- ✅ **Configuración de notificaciones**

### 3. **Simplificar Estructura de Datos**
- ✅ **Un solo campo `nombre_completo`** en lugar de nombre/nombre_pila/apellido
- ✅ **Usar `auth.users.raw_user_meta_data`** para datos básicos
- ✅ **Minimizar datos en tabla `usuarios`**

### 4. **Mejorar UX/UI**
- ✅ **Login/Registro en una sola pantalla**
- ✅ **Google OAuth simplificado**
- ✅ **Wizard de configuración inicial**
- ✅ **Onboarding guiado**

---

## 🏗️ NUEVA ESTRUCTURA PROPUESTA

### Tabla `usuarios` Simplificada
```sql
CREATE TABLE usuarios (
    id uuid PRIMARY KEY REFERENCES auth.users(id),
    nombre_completo text,              -- "Juan Pérez" (un solo campo)
    organizacion_id uuid REFERENCES organizaciones(id),
    rol text DEFAULT 'productor',
    telefono text,
    cuit text,
    avatar_url text,                   -- Para foto de perfil
    preferencias jsonb DEFAULT '{}',   -- Configuraciones del usuario
    perfil_completo boolean DEFAULT false,  -- Si completó el wizard inicial
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
```

### Aprovechar `auth.users.raw_user_meta_data`
```sql
-- Datos que van en Supabase Auth automáticamente:
{
  "email": "juan@ejemplo.com",
  "full_name": "Juan Pérez",        -- Desde Google OAuth
  "avatar_url": "https://...",      -- Desde Google OAuth
  "provider": "google"              -- O "email"
}
```

---

## 🎨 NUEVA INTERFAZ DE LOGIN

### Login/Registro Unificado
```html
<!-- Un solo formulario inteligente -->
<form id="auth-form">
  <input type="email" placeholder="Tu email" required>
  <input type="password" placeholder="Contraseña" required>
  
  <!-- Botón que cambia dinámicamente -->
  <button id="auth-btn">Iniciar Sesión</button>
  <p><a href="#" id="toggle-mode">¿No tienes cuenta? Regístrate</a></p>
  
  <!-- Google OAuth -->
  <button type="button" id="google-auth">
    <i class="bi bi-google"></i> Continuar con Google
  </button>
</form>
```

### Wizard de Configuración Inicial
```html
<!-- Solo se muestra la primera vez -->
<div id="setup-wizard" class="wizard-container">
  <div class="wizard-step active" data-step="1">
    <h3>¡Bienvenido! Completemos tu perfil</h3>
    <input type="text" placeholder="Tu nombre completo" id="nombre-completo">
    <button onclick="nextStep()">Continuar</button>
  </div>
  
  <div class="wizard-step" data-step="2">
    <h3>¿Cuál es tu rol principal?</h3>
    <div class="role-cards">
      <div class="role-card" data-rol="productor">
        <i class="bi bi-building"></i>
        <h4>Productor</h4>
        <p>Propietario o administrador de fincas</p>
      </div>
      <div class="role-card" data-rol="ingeniero">
        <i class="bi bi-gear-wide-connected"></i>
        <h4>Ingeniero</h4>
        <p>Asesor técnico o consultor</p>
      </div>
    </div>
  </div>
  
  <div class="wizard-step" data-step="3">
    <h3>¿Perteneces a alguna organización?</h3>
    <select id="organizacion-wizard">
      <option value="">Trabajo independiente</option>
      <!-- Organizaciones cargadas dinámicamente -->
    </select>
    <small>Puedes cambiar esto más tarde en "Mi Cuenta"</small>
    <button onclick="finishSetup()">Finalizar</button>
  </div>
</div>
```

---

## 📱 PÁGINA "MI CUENTA"

### Estructura Propuesta
```html
<div class="cuenta-container">
  <!-- Header con avatar -->
  <div class="profile-header">
    <div class="avatar-container">
      <img src="avatar.jpg" alt="Avatar" id="user-avatar">
      <button class="change-avatar">Cambiar foto</button>
    </div>
    <h2 id="user-name">Juan Pérez</h2>
    <span class="user-role">Productor</span>
  </div>
  
  <!-- Pestañas de configuración -->
  <div class="account-tabs">
    <div class="tab active" data-tab="perfil">
      <i class="bi bi-person"></i> Perfil
    </div>
    <div class="tab" data-tab="organizacion">
      <i class="bi bi-building"></i> Organización
    </div>
    <div class="tab" data-tab="preferencias">
      <i class="bi bi-gear"></i> Preferencias
    </div>
    <div class="tab" data-tab="seguridad">
      <i class="bi bi-shield-lock"></i> Seguridad
    </div>
  </div>
  
  <!-- Contenido de pestañas -->
  <div class="tab-content">
    <!-- Pestaña Perfil -->
    <div class="tab-pane active" id="perfil">
      <form id="perfil-form">
        <div class="form-group">
          <label>Nombre completo</label>
          <input type="text" id="nombre-completo" value="Juan Pérez">
        </div>
        <div class="form-group">
          <label>Email</label>
          <input type="email" value="juan@ejemplo.com" disabled>
          <small>Para cambiar el email, contacta soporte</small>
        </div>
        <div class="form-group">
          <label>Teléfono</label>
          <input type="tel" id="telefono" value="+54 11 1234-5678">
        </div>
        <div class="form-group">
          <label>CUIT/DNI</label>
          <input type="text" id="cuit" value="20-12345678-9">
        </div>
        <div class="form-group">
          <label>Rol</label>
          <select id="rol">
            <option value="productor" selected>Productor</option>
            <option value="ingeniero">Ingeniero</option>
            <option value="operador">Operario</option>
          </select>
        </div>
        <button type="submit">Guardar cambios</button>
      </form>
    </div>
    
    <!-- Pestaña Organización -->
    <div class="tab-pane" id="organizacion">
      <div class="org-card">
        <div class="org-info">
          <img src="logo-org.png" alt="Logo">
          <div>
            <h4>Mi Organización Actual</h4>
            <p>Cooperativa Agrícola del Valle</p>
          </div>
        </div>
        <button class="btn-change-org">Cambiar organización</button>
      </div>
      
      <div class="org-options" style="display:none;">
        <h4>Seleccionar nueva organización</h4>
        <select id="nueva-organizacion">
          <option value="">Trabajo independiente</option>
          <!-- Organizaciones dinámicas -->
        </select>
        <button onclick="changeOrganization()">Confirmar cambio</button>
        <button onclick="cancelChangeOrg()">Cancelar</button>
      </div>
    </div>
    
    <!-- Pestaña Preferencias -->
    <div class="tab-pane" id="preferencias">
      <div class="preference-group">
        <h4>Notificaciones</h4>
        <div class="toggle-option">
          <label>Recordatorios de riego</label>
          <input type="checkbox" class="toggle" checked>
        </div>
        <div class="toggle-option">
          <label>Reportes semanales</label>
          <input type="checkbox" class="toggle">
        </div>
      </div>
      
      <div class="preference-group">
        <h4>Interfaz</h4>
        <div class="toggle-option">
          <label>Modo oscuro</label>
          <input type="checkbox" class="toggle">
        </div>
        <div class="form-group">
          <label>Zona horaria</label>
          <select>
            <option>Argentina/Buenos_Aires</option>
            <option>America/Santiago</option>
          </select>
        </div>
      </div>
    </div>
    
    <!-- Pestaña Seguridad -->
    <div class="tab-pane" id="seguridad">
      <form id="password-form">
        <h4>Cambiar contraseña</h4>
        <div class="form-group">
          <label>Contraseña actual</label>
          <input type="password" id="current-password" required>
        </div>
        <div class="form-group">
          <label>Nueva contraseña</label>
          <input type="password" id="new-password" required>
        </div>
        <div class="form-group">
          <label>Confirmar nueva contraseña</label>
          <input type="password" id="confirm-password" required>
        </div>
        <button type="submit">Cambiar contraseña</button>
      </form>
      
      <div class="security-info">
        <h4>Sesiones activas</h4>
        <div class="session-item">
          <div class="session-info">
            <strong>Chrome - Windows</strong>
            <small>IP: 192.168.1.100 - Activa ahora</small>
          </div>
          <button class="btn-revoke">Cerrar sesión</button>
        </div>
      </div>
    </div>
  </div>
</div>
```

---

## 🚀 PLAN DE IMPLEMENTACIÓN

### Fase 1: Backend (Base de datos)
1. **Migrar estructura de usuarios**
2. **Limpiar datos duplicados**
3. **Actualizar RLS policies**
4. **Crear triggers para sync**

### Fase 2: Login Simplificado
1. **Nuevo login.html minimalista**
2. **Google OAuth mejorado**
3. **Wizard de configuración inicial**

### Fase 3: Mi Cuenta
1. **Crear mi-cuenta.html**
2. **Funcionalidades de gestión de perfil**
3. **Sistema de preferencias**

### Fase 4: Integración
1. **Actualizar header.js**
2. **Links a "Mi Cuenta" en todas las páginas**
3. **Migrar usuarios existentes**

---

## 💡 BENEFICIOS DE LA PROPUESTA

### ✅ **Simplicidad**
- Registro en 30 segundos
- Configuración progresiva
- Menos campos obligatorios

### ✅ **Mejor UX**
- Un solo lugar para gestionar cuenta
- Onboarding guiado
- Configuración personalizable

### ✅ **Menos Código**
- Eliminación de duplicación
- Estructura más clara
- Menos mantenimiento

### ✅ **Escalabilidad**
- Fácil agregar nuevas preferencias
- Sistema de roles flexible
- Preparado para futuras features

---

**¿Te gusta esta propuesta? ¿Empezamos con la implementación?**
