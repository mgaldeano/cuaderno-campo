// combo-utils.js
// Funciones utilitarias para cargar datos en combos/selects

// Importar supabase
import { supabase } from './supabaseClient.js';

/**
 * Cargar operadores para combos
 */
export async function cargarOperadoresCombo() {
    try {
        const { data, error } = await supabase
            .from('aplicadores_operarios')
            .select('id, nombre')
            .order('nombre');
        
        if (error) throw error;
        
        return data || [];
    } catch (error) {
        console.error('Error en cargarOperadoresCombo:', error);
        throw error;
    }
}

/**
 * Cargar fincas para combos
 */
export async function cargarFincasCombo() {
    try {
        const { data, error } = await supabase
            .from('fincas')
            .select('id, nombre_finca')
            .order('nombre_finca');
        
        if (error) throw error;
        
        return data || [];
    } catch (error) {
        console.error('Error en cargarFincasCombo:', error);
        throw error;
    }
}

/**
 * Cargar cuarteles por fincas seleccionadas
 */
export async function cargarCuartelesPorFincasCombo(fincasIds) {
    try {
        const { data, error } = await supabase
            .from('cuarteles')
            .select(`
                id, 
                nombre, 
                superficie,
                finca_id,
                fincas!inner(id, nombre_finca)
            `)
            .in('finca_id', fincasIds)
            .order('nombre');
        
        if (error) throw error;
        
        // Formatear datos para el combo
        return (data || []).map(cuartel => ({
            id: cuartel.id,
            nombre: cuartel.nombre,
            superficie: cuartel.superficie,
            finca_id: cuartel.finca_id,
            finca_nombre: cuartel.fincas?.nombre_finca || 'Sin nombre'
        }));
    } catch (error) {
        console.error('Error en cargarCuartelesPorFincasCombo:', error);
        throw error;
    }
}

/**
 * Cargar todos los cuarteles (para casos donde se necesite)
 */
export async function cargarTodosCuartelesCombo() {
    try {
        const { data, error } = await supabase
            .from('cuarteles')
            .select(`
                id, 
                nombre, 
                superficie,
                finca_id,
                fincas!inner(id, nombre_finca)
            `)
            .order('nombre');
        
        if (error) throw error;
        
        // Formatear datos para el combo
        return (data || []).map(cuartel => ({
            id: cuartel.id,
            nombre: cuartel.nombre,
            superficie: cuartel.superficie,
            finca_id: cuartel.finca_id,
            finca_nombre: cuartel.fincas?.nombre_finca || 'Sin nombre'
        }));
    } catch (error) {
        console.error('Error en cargarTodosCuartelesCombo:', error);
        throw error;
    }
}

/**
 * Cargar variedades para combos
 */
export async function cargarVariedadesCombo() {
    try {
        const { data, error } = await supabase
            .from('variedades')
            .select('id, nombre')
            .order('nombre');
        
        if (error) throw error;
        
        return data || [];
    } catch (error) {
        console.error('Error en cargarVariedadesCombo:', error);
        throw error;
    }
}

/**
 * Cargar especies para combos
 */
export async function cargarEspeciesCombo() {
    try {
        const { data, error } = await supabase
            .from('especies')
            .select('id, nombre')
            .order('nombre');
        
        if (error) throw error;
        
        return data || [];
    } catch (error) {
        console.error('Error en cargarEspeciesCombo:', error);
        throw error;
    }
}

/**
 * Cargar fertilizantes disponibles para combos
 */
export async function cargarFertilizantesCombo() {
    try {
        const { data, error } = await supabase
            .from('fertilizantes')
            .select('*')
            .order('producto');
        
        if (error) throw error;
        
        return data || [];
    } catch (error) {
        console.error('Error en cargarFertilizantesCombo:', error);
        throw error;
    }
}

/**
 * Cargar fitosanitarios para combos
 */
export async function cargarFitosanitariosCombo() {
    try {
        const { data, error } = await supabase
            .from('fitosanitarios')
            .select('*')
            .order('nombre_comercial');
        
        if (error) throw error;
        
        return data || [];
    } catch (error) {
        console.error('Error en cargarFitosanitariosCombo:', error);
        throw error;
    }
}

/**
 * Cargar métodos de aplicación para combos
 */
export async function cargarMetodosAplicacionCombo() {
    try {
        const { data, error } = await supabase
            .from('metodos_de_aplicacion')
            .select('*')
            .order('nombre');
        
        if (error) throw error;
        
        return data || [];
    } catch (error) {
        console.error('Error en cargarMetodosAplicacionCombo:', error);
        throw error;
    }
}
