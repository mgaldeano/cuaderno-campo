// supabaseClient.js
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const SUPABASE_URL = "https://djvdjulfeuqohpnatdmt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqdmRqdWxmZXVxb2hwbmF0ZG10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNTYyMTEsImV4cCI6MjA2NzkzMjIxMX0.aD_klISxuwoGxMYtPq6XPARva8D32YkKFu7s_Ffq0fw" // ← usá tu key real aquí

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
