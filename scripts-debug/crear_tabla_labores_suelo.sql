-- Crear tabla labores_suelo (ahora renombrada conceptualmente como "labores")
-- Este script crea la tabla para registrar las labores realizadas en las fincas

CREATE TABLE IF NOT EXISTS labores_suelo (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    fecha timestamp with time zone NOT NULL DEFAULT now(),
    finca_id bigint NOT NULL REFERENCES fincas(id) ON DELETE CASCADE,
    cuartel_id bigint NOT NULL REFERENCES cuarteles(id) ON DELETE CASCADE,
    tipo_labor text NOT NULL,
    objetivo text NOT NULL,
    tiempo_horas numeric(6,2) DEFAULT 0,
    operador_id uuid NOT NULL REFERENCES aplicadores_operarios(id),
    maquinaria text DEFAULT 'ninguna',
    superficie_hectareas numeric(10,2),
    costo numeric(10,2),
    resultado text,
    observaciones text,
    usuario_id uuid NOT NULL REFERENCES usuarios(id),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_labores_suelo_fecha ON labores_suelo(fecha);
CREATE INDEX IF NOT EXISTS idx_labores_suelo_finca ON labores_suelo(finca_id);
CREATE INDEX IF NOT EXISTS idx_labores_suelo_cuartel ON labores_suelo(cuartel_id);
CREATE INDEX IF NOT EXISTS idx_labores_suelo_tipo ON labores_suelo(tipo_labor);
CREATE INDEX IF NOT EXISTS idx_labores_suelo_usuario ON labores_suelo(usuario_id);

-- Crear trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_labores_suelo_updated_at 
    BEFORE UPDATE ON labores_suelo 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentar la tabla
COMMENT ON TABLE labores_suelo IS 'Registra las labores realizadas en fincas y cuarteles (suelo, poda, cultivo, cosecha)';
COMMENT ON COLUMN labores_suelo.tipo_labor IS 'Tipo de labor realizada (personalizable por usuario)';
COMMENT ON COLUMN labores_suelo.objetivo IS 'Objetivo/propósito de la labor';
COMMENT ON COLUMN labores_suelo.tiempo_horas IS 'Tiempo invertido en la labor en horas (opcional)';
COMMENT ON COLUMN labores_suelo.maquinaria IS 'Maquinaria o herramientas utilizadas (opcional)';
COMMENT ON COLUMN labores_suelo.superficie_hectareas IS 'Superficie trabajada en hectáreas (opcional)';
COMMENT ON COLUMN labores_suelo.costo IS 'Costo total de la labor (opcional)';
COMMENT ON COLUMN labores_suelo.resultado IS 'Resultado/efectividad de la labor (opcional)';

-- Configurar RLS (Row Level Security)
ALTER TABLE labores_suelo ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo vean sus propios registros y los de su organización
CREATE POLICY "Usuarios pueden ver labores de su organización" ON labores_suelo
    FOR SELECT USING (
        usuario_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM usuarios u1, usuarios u2
            WHERE u1.id = auth.uid() 
            AND u2.id = labores_suelo.usuario_id
            AND u1.organizacion_id = u2.organizacion_id
        )
    );

-- Política para insertar registros
CREATE POLICY "Usuarios pueden insertar labores" ON labores_suelo
    FOR INSERT WITH CHECK (usuario_id = auth.uid());

-- Política para actualizar registros propios
CREATE POLICY "Usuarios pueden actualizar sus labores" ON labores_suelo
    FOR UPDATE USING (usuario_id = auth.uid());

-- Política para eliminar registros propios
CREATE POLICY "Usuarios pueden eliminar sus labores" ON labores_suelo
    FOR DELETE USING (usuario_id = auth.uid());
