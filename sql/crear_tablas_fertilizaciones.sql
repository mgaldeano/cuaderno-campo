-- Script SQL para crear tabla fertilizaciones
-- Basado en docs/SISTEMA_FERTILIZACIONES.md

-- Crear tabla principal de fertilizaciones
CREATE TABLE IF NOT EXISTS fertilizaciones (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id),
    finca_id INTEGER REFERENCES fincas(id),
    cuartel_id INTEGER REFERENCES cuarteles(id),
    fertilizante_id INTEGER, -- Referencia flexible (fertilizantes o fertilizantes_disponibles)
    fecha DATE NOT NULL,
    
    -- DOSIS DE REFERENCIA (orientativa)
    dosis_referencia DECIMAL(10,2), -- Dosis recomendada por fabricante
    unidad_dosis_referencia VARCHAR(20) DEFAULT 'kg/ha', -- kg/ha, l/ha, etc.
    
    -- CANTIDADES REALES APLICADAS (campos principales)
    cantidad_aplicada DECIMAL(10,2) NOT NULL, -- Cantidad real aplicada en el cuartel
    unidad_cantidad VARCHAR(20) NOT NULL DEFAULT 'kg', -- kg, litros, gramos, ml
    superficie_cuartel DECIMAL(10,2), -- Superficie del cuartel específico
    dosis_real_calculada DECIMAL(10,2), -- cantidad_aplicada / superficie_cuartel
    
    -- INFORMACIÓN DE APLICACIÓN
    metodo_aplicacion VARCHAR(50) NOT NULL,
    sistema_aplicacion VARCHAR(30), -- tipo de fertilización (inorganico, organico, etc.)
    operador_id INTEGER REFERENCES aplicadores_operarios(id),
    equipo_trabajadores TEXT,
    
    -- CONDICIONES Y COSTOS
    costo_total DECIMAL(10,2),
    clima VARCHAR(50),
    humedad_suelo VARCHAR(20),
    observaciones TEXT,
    
    -- METADATA
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de fertilizantes disponibles si no existe
CREATE TABLE IF NOT EXISTS fertilizantes_disponibles (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id),
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    subtipo VARCHAR(50),
    composicion TEXT,
    concentracion VARCHAR(50),
    porcentaje_n DECIMAL(5,2) DEFAULT 0,
    porcentaje_p DECIMAL(5,2) DEFAULT 0,
    porcentaje_k DECIMAL(5,2) DEFAULT 0,
    porcentaje_ca DECIMAL(5,2) DEFAULT 0,
    porcentaje_mg DECIMAL(5,2) DEFAULT 0,
    porcentaje_s DECIMAL(5,2) DEFAULT 0,
    micronutrientes TEXT, -- JSON
    unidad_venta VARCHAR(20),
    precio_unidad DECIMAL(10,2),
    fabricante VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_fertilizaciones_usuario_fecha ON fertilizaciones(usuario_id, fecha);
CREATE INDEX IF NOT EXISTS idx_fertilizaciones_finca_cuartel ON fertilizaciones(finca_id, cuartel_id);
CREATE INDEX IF NOT EXISTS idx_fertilizaciones_fertilizante ON fertilizaciones(fertilizante_id);
CREATE INDEX IF NOT EXISTS idx_fertilizantes_usuario_activo ON fertilizantes_disponibles(usuario_id, activo);

-- Habilitar RLS
ALTER TABLE fertilizaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE fertilizantes_disponibles ENABLE ROW LEVEL SECURITY;

-- Políticas RLS básicas (permitir acceso según usuario)
CREATE POLICY "Usuarios pueden ver sus fertilizaciones" ON fertilizaciones
    FOR ALL USING (auth.uid() = usuario_id);

CREATE POLICY "Usuarios pueden ver sus fertilizantes" ON fertilizantes_disponibles
    FOR ALL USING (auth.uid() = usuario_id);

-- Comentarios
COMMENT ON TABLE fertilizaciones IS 'Registro detallado de cantidades reales de fertilizantes aplicados por cuartel';
COMMENT ON COLUMN fertilizaciones.dosis_referencia IS 'Dosis recomendada por fabricante (referencia)';
COMMENT ON COLUMN fertilizaciones.cantidad_aplicada IS 'Cantidad real aplicada en el cuartel (campo principal)';
COMMENT ON COLUMN fertilizaciones.unidad_cantidad IS 'Unidad de la cantidad real aplicada (kg, l, gr, ml)';
COMMENT ON COLUMN fertilizaciones.dosis_real_calculada IS 'Dosis real por hectárea calculada automáticamente';
COMMENT ON TABLE fertilizantes_disponibles IS 'Catálogo de fertilizantes disponibles con información nutricional';
