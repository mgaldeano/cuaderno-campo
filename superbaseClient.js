// supabaseClient.js
import { createClient as create } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

export function createClient() {
  return create(
    "https://djvdjulfeuqohpnatdmt.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  );
}
