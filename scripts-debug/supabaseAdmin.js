// supabaseAdmin.js - Cliente con acceso administrativo
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const SUPABASE_URL = "https://djvdjulfeuqohpnatdmt.supabase.co";

// 🚨 IMPORTANTE: Reemplaza con tu SERVICE_ROLE_KEY (no la anon key)
// La encontrarás en: Supabase Dashboard → Settings → API → service_role key
const SUPABASE_SERVICE_KEY = "TU_SERVICE_ROLE_KEY_AQUI"; // ← Reemplazar con la clave real

export const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// Cliente normal para operaciones de usuario
export { supabase } from './supabaseClient.js';
