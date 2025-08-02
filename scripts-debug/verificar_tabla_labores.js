#!/usr/bin/env node

/**
 * Script alternativo para crear la tabla labores_suelo en Supabase
 * Ejecuta las consultas DDL una por una
 */

import { createClient } from '@supabase/supabase-js';

// Configuración de Supabase (usar las mismas credenciales del proyecto)
const SUPABASE_URL = "https://djvdjulfeuqohpnatdmt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqdmRqdWxmZXVxb2hwbmF0ZG10Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNTYyMTEsImV4cCI6MjA2NzkzMjIxMX0.aD_klISxuwoGxMYtPq6XPARva8D32YkKFu7s_Ffq0fw";

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function verificarTablaLaboresSuelo() {
    try {
        console.log('🔍 Verificando si la tabla labores_suelo existe...');
        
        // Intentar hacer una consulta simple para verificar si la tabla existe
        const { data, error } = await supabase
            .from('labores_suelo')
            .select('id')
            .limit(1);
            
        if (error) {
            console.log('❌ La tabla no existe o no es accesible:', error.message);
            console.log('\n📋 Necesitas crear la tabla manualmente en Supabase.');
            console.log('🔗 Ve a: https://supabase.com/dashboard/project/djvdjulfeuqohpnatdmt/editor');
            console.log('📄 Copia y pega el contenido de: scripts-debug/crear_tabla_labores_suelo.sql');
            return false;
        }
        
        console.log('✅ ¡La tabla labores_suelo ya existe y es accesible!');
        console.log('📊 Resultado de verificación:', data?.length === 0 ? 'Tabla vacía (normal)' : `${data?.length} registros encontrados`);
        
        // Verificar algunas columnas específicas haciendo una consulta con límite
        const { data: testData, error: testError } = await supabase
            .from('labores_suelo')
            .select('id, tipo_labor, objetivo, tiempo_horas, maquinaria, costo, resultado')
            .limit(1);
            
        if (testError) {
            console.log('⚠️  La tabla existe pero puede tener un esquema diferente:', testError.message);
            return false;
        }
        
        console.log('✅ Esquema de tabla verificado correctamente');
        return true;
        
    } catch (err) {
        console.error('💥 Error inesperado:', err);
        return false;
    }
}

// Función para crear algunas labores de prueba
async function crearDatosPrueba() {
    try {
        console.log('\n🧪 ¿Quieres crear algunos datos de prueba? (opcional)');
        
        // Por ahora solo verificamos que podemos insertar
        const { data: usuario, error: userError } = await supabase.auth.getUser();
        
        if (userError || !usuario.user) {
            console.log('ℹ️  No hay usuario autenticado - los datos de prueba requieren autenticación');
            return true;
        }
        
        console.log('👤 Usuario autenticado detectado');
        console.log('ℹ️  Puedes crear labores de prueba desde la interfaz web');
        
        return true;
        
    } catch (err) {
        console.error('⚠️  Error verificando autenticación:', err);
        return true; // No es crítico
    }
}

// Ejecutar verificación
async function main() {
    console.log('🚀 Iniciando verificación de tabla labores_suelo...');
    
    const tablaExiste = await verificarTablaLaboresSuelo();
    
    if (tablaExiste) {
        await crearDatosPrueba();
        console.log('\n🎉 ¡Verificación completada exitosamente!');
        console.log('👉 La tabla está lista - puedes usar labores-suelo.html');
        console.log('🌐 Abre: labores-suelo.html en tu navegador');
        return true;
    } else {
        console.log('\n📋 INSTRUCCIONES PARA CREAR LA TABLA:');
        console.log('1. Ve a: https://supabase.com/dashboard/project/djvdjulfeuqohpnatdmt/editor');
        console.log('2. Abre una nueva consulta SQL');
        console.log('3. Copia todo el contenido de: scripts-debug/crear_tabla_labores_suelo.sql');
        console.log('4. Pega y ejecuta el SQL');
        console.log('5. Ejecuta este script nuevamente para verificar');
        return false;
    }
}

if (import.meta.url === `file://${process.argv[1]}`) {
    main()
        .then(success => {
            process.exit(success ? 0 : 1);
        })
        .catch(err => {
            console.error('\n💥 Error fatal:', err);
            process.exit(1);
        });
}

export { verificarTablaLaboresSuelo };
