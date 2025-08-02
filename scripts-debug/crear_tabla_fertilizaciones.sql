-- =====================================================
-- SCRIPT: Creación de tablas para Sistema de Fertilizaciones
-- FECHA: 2 de agosto de 2025
-- RAMA: Fertilizaciones
-- DESCRIPCIÓN: Tablas para registro y gestión de fertilizaciones
--              con cumplimiento Global GAP
-- =====================================================

-- ========================================
-- TABLA: fertilizantes_disponibles
-- ========================================

CREATE TABLE fertilizantes_disponibles (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- granulado, liquido, foliar, organico, bioestimulante
    subtipo VARCHAR(50), -- inorganico, organico, bioestimulante
    composicion TEXT, -- NPK 20-10-10, etc.
    concentracion VARCHAR(50), -- % de nutrientes
    -- Porcentajes de nutrientes para cálculos automáticos
    porcentaje_n DECIMAL(5,2) DEFAULT 0, -- % Nitrógeno
    porcentaje_p DECIMAL(5,2) DEFAULT 0, -- % Fósforo (P₂O₅)
    porcentaje_k DECIMAL(5,2) DEFAULT 0, -- % Potasio (K₂O)
    porcentaje_ca DECIMAL(5,2) DEFAULT 0, -- % Calcio
    porcentaje_mg DECIMAL(5,2) DEFAULT 0, -- % Magnesio
    porcentaje_s DECIMAL(5,2) DEFAULT 0, -- % Azufre
    micronutrientes TEXT, -- JSON: {"B": 0.1, "Zn": 0.5, "Fe": 2.0}
    unidad_venta VARCHAR(20), -- kg, litros, bolsas
    precio_unidad DECIMAL(10,2),
    fabricante VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- TABLA: fertilizaciones
-- ========================================

CREATE TABLE fertilizaciones (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id) NOT NULL,
    finca_id BIGINT REFERENCES fincas(id) NOT NULL,
    cuartel_id BIGINT REFERENCES cuarteles(id) NOT NULL,
    fertilizante_id BIGINT REFERENCES fertilizantes_disponibles(id) NOT NULL,
    fecha DATE NOT NULL,
    dosis DECIMAL(10,2) NOT NULL,
    unidad_dosis VARCHAR(20) NOT NULL, -- kg/ha, l/ha, gr/planta, etc.
    metodo_aplicacion VARCHAR(50) NOT NULL, -- foliar, suelo, fertirrigacion, hidroponico, etc.
    sistema_aplicacion VARCHAR(30), -- hidroponico, fertirrigacion, convencional
    superficie_aplicada DECIMAL(10,2), -- hectareas
    operador_id UUID REFERENCES aplicadores_operarios(id),
    equipo_trabajadores TEXT, -- JSON: nombres del equipo aplicador
    costo_total DECIMAL(10,2),
    clima VARCHAR(50), -- soleado, nublado, lluvia, etc.
    humedad_suelo VARCHAR(20), -- seco, humedo, saturado
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ========================================

-- Índices para fertilizaciones
CREATE INDEX idx_fertilizaciones_usuario_fecha ON fertilizaciones(usuario_id, fecha);
CREATE INDEX idx_fertilizaciones_finca_cuartel ON fertilizaciones(finca_id, cuartel_id);
CREATE INDEX idx_fertilizaciones_fertilizante ON fertilizaciones(fertilizante_id);
CREATE INDEX idx_fertilizaciones_fecha_desc ON fertilizaciones(fecha DESC);

-- Índices para fertilizantes_disponibles
CREATE INDEX idx_fertilizantes_usuario_activo ON fertilizantes_disponibles(usuario_id, activo);
CREATE INDEX idx_fertilizantes_nombre ON fertilizantes_disponibles(nombre);
CREATE INDEX idx_fertilizantes_tipo ON fertilizantes_disponibles(tipo);

-- ========================================
-- POLÍTICAS RLS (ROW LEVEL SECURITY)
-- ========================================

-- Habilitar RLS en ambas tablas
ALTER TABLE fertilizaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE fertilizantes_disponibles ENABLE ROW LEVEL SECURITY;

-- Políticas para fertilizaciones
CREATE POLICY "Users can manage their own fertilizations"
    ON fertilizaciones
    FOR ALL
    USING (usuario_id = auth.uid());

-- Políticas para fertilizantes_disponibles
CREATE POLICY "Users can manage their own fertilizers"
    ON fertilizantes_disponibles
    FOR ALL
    USING (usuario_id = auth.uid());

-- ========================================
-- VISTA: reporte_nutrientes
-- ========================================

CREATE VIEW reporte_nutrientes AS
SELECT 
    f.id,
    f.fecha,
    fi.nombre_finca,
    c.nombre as cuartel,
    fd.nombre as fertilizante,
    fd.tipo,
    fd.subtipo,
    f.dosis,
    f.unidad_dosis,
    f.superficie_aplicada,
    (f.dosis * f.superficie_aplicada) as cantidad_total,
    f.metodo_aplicacion,
    f.sistema_aplicacion,
    -- Cálculo de unidades de nutrientes
    ROUND((fd.porcentaje_n/100) * (f.dosis * f.superficie_aplicada), 2) as kg_nitrogeno,
    ROUND((fd.porcentaje_p/100) * (f.dosis * f.superficie_aplicada), 2) as kg_fosforo,
    ROUND((fd.porcentaje_k/100) * (f.dosis * f.superficie_aplicada), 2) as kg_potasio,
    ROUND((fd.porcentaje_ca/100) * (f.dosis * f.superficie_aplicada), 2) as kg_calcio,
    ROUND((fd.porcentaje_mg/100) * (f.dosis * f.superficie_aplicada), 2) as kg_magnesio,
    ROUND((fd.porcentaje_s/100) * (f.dosis * f.superficie_aplicada), 2) as kg_azufre,
    f.costo_total,
    CASE 
        WHEN f.superficie_aplicada > 0 THEN ROUND(f.costo_total / f.superficie_aplicada, 2)
        ELSE 0
    END as costo_por_hectarea,
    COALESCE(ao.nombre, f.equipo_trabajadores) as aplicador,
    f.observaciones,
    f.usuario_id
FROM fertilizaciones f
JOIN fertilizantes_disponibles fd ON f.fertilizante_id = fd.id
JOIN fincas fi ON f.finca_id = fi.id
JOIN cuarteles c ON f.cuartel_id = c.id
LEFT JOIN aplicadores_operarios ao ON f.operador_id = ao.id
ORDER BY f.fecha DESC;

-- ========================================
-- VISTA: auditoria_global_gap
-- ========================================

CREATE VIEW auditoria_global_gap AS
SELECT 
    fi.nombre_finca as "Zona Geográfica",
    c.nombre as "Campo/Sector",
    f.fecha as "Fecha Aplicación",
    fd.nombre as "Nombre Fertilizante",
    fd.subtipo as "Tipo (Orgánico/Inorgánico/Bioestimulante)",
    f.dosis || ' ' || f.unidad_dosis as "Cantidad/Dosis",
    COALESCE(ao.nombre, f.equipo_trabajadores) as "Aplicador/Equipo",
    f.sistema_aplicacion as "Sistema Aplicación",
    ROUND((fd.porcentaje_n/100) * (f.dosis * f.superficie_aplicada), 2) as "kg N Aplicado",
    ROUND((fd.porcentaje_p/100) * (f.dosis * f.superficie_aplicada), 2) as "kg P Aplicado",
    ROUND((fd.porcentaje_k/100) * (f.dosis * f.superficie_aplicada), 2) as "kg K Aplicado",
    f.observaciones as "Observaciones",
    f.usuario_id
FROM fertilizaciones f
JOIN fertilizantes_disponibles fd ON f.fertilizante_id = fd.id
JOIN fincas fi ON f.finca_id = fi.id
JOIN cuarteles c ON f.cuartel_id = c.id
LEFT JOIN aplicadores_operarios ao ON f.operador_id = ao.id
ORDER BY f.fecha DESC;

-- ========================================
-- TRIGGERS PARA UPDATED_AT
-- ========================================

-- Función para actualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para fertilizaciones
CREATE TRIGGER update_fertilizaciones_updated_at 
    BEFORE UPDATE ON fertilizaciones 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para fertilizantes_disponibles
CREATE TRIGGER update_fertilizantes_disponibles_updated_at 
    BEFORE UPDATE ON fertilizantes_disponibles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- DATOS DE EJEMPLO (OPCIONAL)
-- ========================================

-- Insertar algunos fertilizantes de ejemplo (comentado)
/*
INSERT INTO fertilizantes_disponibles (
    usuario_id, nombre, tipo, subtipo, composicion, 
    porcentaje_n, porcentaje_p, porcentaje_k,
    unidad_venta, activo
) VALUES 
(auth.uid(), 'NPK 20-10-10', 'granulado', 'inorganico', '20-10-10', 20.00, 10.00, 10.00, 'kg', true),
(auth.uid(), 'Urea 46%', 'granulado', 'inorganico', '46-0-0', 46.00, 0.00, 0.00, 'kg', true),
(auth.uid(), 'Compost Orgánico', 'organico', 'organico', 'Materia orgánica', 2.50, 1.00, 1.50, 'kg', true),
(auth.uid(), 'Bioestimulante Foliar', 'liquido', 'bioestimulante', 'Extractos vegetales', 0.00, 0.00, 0.00, 'litros', true);
*/

-- ========================================
-- COMENTARIOS Y NOTAS
-- ========================================

COMMENT ON TABLE fertilizaciones IS 'Registro de aplicaciones de fertilizantes con cumplimiento Global GAP';
COMMENT ON TABLE fertilizantes_disponibles IS 'Catálogo de fertilizantes disponibles con porcentajes de nutrientes';
COMMENT ON VIEW reporte_nutrientes IS 'Vista para reportes con cálculos automáticos de nutrientes';
COMMENT ON VIEW auditoria_global_gap IS 'Vista específica para auditorías Global GAP';

-- ========================================
-- FIN DEL SCRIPT
-- ========================================

-- Script completado exitosamente
-- Tablas creadas: fertilizaciones, fertilizantes_disponibles
-- Vistas creadas: reporte_nutrientes, auditoria_global_gap
-- RLS habilitado y políticas configuradas
-- Índices de optimización creados
