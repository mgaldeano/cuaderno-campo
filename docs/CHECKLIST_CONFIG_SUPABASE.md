# CHECKLIST CONFIGURACIÓN SUPABASE - NUEVO SISTEMA AUTH

## 🔧 Configuraciones Críticas a Revisar

### 1. **Authentication Settings** 
Ve a: **Dashboard Supabase → Authentication → Settings**

#### ✅ **General Settings**
- [ ] **Site URL**: `http://localhost:8000` (para desarrollo) / Tu dominio (para producción)
- [ ] **Redirect URLs**: 
  - `http://localhost:8000/setup-wizard.html`
  - `http://localhost:8000/index.html`
  - Tu dominio/setup-wizard.html (para producción)

#### ✅ **Email Settings**
- [ ] **Enable email confirmations**: ✅ ACTIVADO (recomendado)
- [ ] **Enable email change confirmations**: ✅ ACTIVADO 
- [ ] **Enable secure email change**: ✅ ACTIVADO

#### ✅ **Email Templates**
Revisa estos templates en **Authentication → Email Templates**:
- [ ] **Confirm signup**: Mensaje de confirmación de registro
- [ ] **Magic Link**: Para login sin password (opcional)
- [ ] **Change Email Address**: Para cambio de email
- [ ] **Reset Password**: Para recuperar contraseña

### 2. **Provider Settings (Google OAuth)**
Ve a: **Authentication → Providers**

#### ✅ **Google Provider**
- [ ] **Enable Google provider**: ✅ ACTIVADO
- [ ] **Client ID**: Tu Google Client ID configurado
- [ ] **Client Secret**: Tu Google Client Secret configurado
- [ ] **Redirect URL**: `https://tu-proyecto.supabase.co/auth/v1/callback`

### 3. **Database Policies (RLS)**
Ve a: **Database → Authentication → Policies**

#### ✅ **Tabla usuarios**
- [ ] **RLS habilitado**: ✅ ACTIVADO
- [ ] **Política SELECT**: Usuarios pueden ver su propio perfil
- [ ] **Política UPDATE**: Usuarios pueden actualizar su propio perfil
- [ ] **Política INSERT**: Solo para sistema (triggers)

### 4. **API Keys y URLs**
Ve a: **Settings → API**

#### ✅ **Verificar configuración en supabaseClient.js**
- [ ] **Project URL**: Coincide con tu proyecto
- [ ] **Anon Public Key**: Coincide con tu clave
- [ ] **Service Role Key**: NO usar en frontend (solo backend)

### 5. **Email Service Provider**
Ve a: **Settings → Auth → SMTP Settings**

#### ✅ **Opciones de configuración:**

**Opción A: Usar servicio de Supabase (por defecto)**
- [ ] Sin configuración adicional
- [ ] Límite: 4 emails/hora en plan gratuito
- [ ] Para pruebas está bien

**Opción B: SMTP personalizado (recomendado para producción)**
- [ ] **SMTP Host**: ej. smtp.gmail.com
- [ ] **SMTP Port**: 587 o 465
- [ ] **SMTP User**: tu-email@gmail.com
- [ ] **SMTP Pass**: contraseña de aplicación
- [ ] **Sender Name**: Cuaderno de Campo
- [ ] **Sender Email**: tu-email@dominio.com

### 6. **Rate Limiting**
Ve a: **Authentication → Rate Limits**

#### ✅ **Límites recomendados para desarrollo:**
- [ ] **Sign up**: 10 por hora
- [ ] **Sign in**: 30 por hora
- [ ] **Password reset**: 5 por hora

---

## 🚨 **CONFIGURACIÓN EMAIL EN SUPABASE**

### **Configuración Recomendada para Desarrollo:**

#### ✅ **Enable Email provider**
- **Estado**: ✅ ACTIVADO (crítico para login/registro)

#### ✅ **Secure email change**
- **Recomendación**: ✅ ACTIVADO (seguridad)
- **Descripción**: Confirma cambios en email antiguo Y nuevo

#### ✅ **Secure password change**
- **Recomendación**: ✅ ACTIVADO (seguridad)
- **Descripción**: Requiere login reciente (24h) para cambiar password

#### ✅ **Prevent use of leaked passwords**
- **Recomendación**: ✅ ACTIVADO (seguridad)
- **Descripción**: Usa HaveIBeenPwned.org para validar passwords

#### ✅ **Minimum password length**
- **Recomendación**: `8` caracteres
- **Mínimo permitido**: 6 (pero 8 es más seguro)

#### ✅ **Password Requirements**
- **Recomendación**: Activar al menos:
  - ✅ Una letra minúscula
  - ✅ Una letra mayúscula
  - ✅ Un número
  - 🔶 Símbolos especiales (opcional para desarrollo)

#### ✅ **Email OTP Expiration**
- **Recomendación**: `3600` segundos (1 hora)
- **Para desarrollo**: Puedes usar `7200` (2 horas) para más tiempo

#### ✅ **Email OTP Length**
- **Recomendación**: `6` dígitos (estándar)

---

## 🚨 **Configuraciones Mínimas para Prueba**

### **Para testing local inmediato:**

1. **Site URL**: `http://localhost:8000`
2. **Redirect URLs**: Agregar `http://localhost:8000/setup-wizard.html`
3. **Email confirmations**: Puedes desactivarlo temporalmente para pruebas
4. **Google OAuth**: Solo si quieres probar esa funcionalidad

### **Comandos de verificación rápida:**

```sql
-- Verificar políticas RLS
SELECT tablename, policyname, cmd, permissive 
FROM pg_policies 
WHERE tablename = 'usuarios';

-- Verificar trigger de auto-creación
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers 
WHERE event_object_table = 'usuarios';
```

---

## 📝 **Orden de configuración recomendado:**

1. **Primero**: Site URL y Redirect URLs
2. **Segundo**: Decisión sobre email confirmations
3. **Tercero**: Probar registro básico
4. **Cuarto**: Configurar SMTP si es necesario
5. **Quinto**: Configurar Google OAuth si se requiere

---

## ⚠️ **Para producción adicional:**

- [ ] Configurar dominio personalizado
- [ ] SMTP con servicio profesional (SendGrid, Mailgun, etc.)
- [ ] Rate limiting más restrictivo
- [ ] Monitoreo de logs de autenticación
- [ ] Backup de configuraciones

---

¿Quieres que revisemos estas configuraciones una por una o prefieres hacer una prueba básica primero?
