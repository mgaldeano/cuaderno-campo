#!/usr/bin/env node

/**
 * Script para crear la tabla labores_suelo en Supabase
 * Ejecutar: node crear_tabla_labores_suelo.js
 */

import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';

// Configuración de Supabase (usar las mismas credenciales del proyecto)
const SUPABASE_URL = "https://djvdjulfeuqohpnatdmt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqdmRqdWxmZXVxb2hwbmF0ZG10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNTYyMTEsImV4cCI6MjA2NzkzMjIxMX0.aD_klISxuwoGxMYtPq6XPARva8D32YkKFu7s_Ffq0fw";

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function crearTablaLaboresSuelo() {
    try {
        console.log('🚀 Iniciando creación de tabla labores_suelo...');
        
        // Leer el archivo SQL
        const sqlPath = path.join(process.cwd(), 'scripts-debug', 'crear_tabla_labores_suelo.sql');
        const sqlContent = fs.readFileSync(sqlPath, 'utf8');
        
        console.log('📄 Ejecutando script SQL...');
        
        // Ejecutar el SQL
        const { data, error } = await supabase.rpc('sql', { 
            query: sqlContent 
        });
        
        if (error) {
            console.error('❌ Error ejecutando SQL:', error);
            return false;
        }
        
        console.log('✅ Tabla labores_suelo creada exitosamente');
        console.log('📊 Resultado:', data);
        
        // Verificar que la tabla existe
        const { data: tableCheck, error: checkError } = await supabase
            .from('labores_suelo')
            .select('*')
            .limit(1);
            
        if (checkError && !checkError.message.includes('0 rows')) {
            console.error('❌ Error verificando tabla:', checkError);
            return false;
        }
        
        console.log('✅ Verificación exitosa - La tabla está lista para usar');
        return true;
        
    } catch (err) {
        console.error('💥 Error inesperado:', err);
        return false;
    }
}

// Ejecutar si es llamado directamente
if (import.meta.url === `file://${process.argv[1]}`) {
    crearTablaLaboresSuelo()
        .then(success => {
            if (success) {
                console.log('\n🎉 ¡Proceso completado exitosamente!');
                console.log('👉 Ahora puedes usar labores-suelo.html');
                process.exit(0);
            } else {
                console.log('\n💔 Proceso fallido - revisa los errores arriba');
                process.exit(1);
            }
        })
        .catch(err => {
            console.error('\n💥 Error fatal:', err);
            process.exit(1);
        });
}

export { crearTablaLaboresSuelo };
