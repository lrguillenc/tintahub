-- =============================================
-- TintaHub - Infraestructura para una Plataforma Web de Difusión Literaria
-- Base de datos PostgreSQL 16
-- Autor: Luis Rodrigo Guillén Calderón
-- TFG ASIR - ThePower FP Oficial 2026
-- Licencia: CC BY-NC-ND 4.0
-- =============================================

-- Eliminar tablas si existen
DROP TABLE IF EXISTS like_obra CASCADE;
DROP TABLE IF EXISTS seguimiento CASCADE;
DROP TABLE IF EXISTS comentario CASCADE;
DROP TABLE IF EXISTS mensaje CASCADE;
DROP TABLE IF EXISTS obra CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;

-- Eliminar vistas si existen
DROP VIEW IF EXISTS vista_usuario_publico;

-- Eliminar funciones si existen
DROP FUNCTION IF EXISTS registrar_acceso(INTEGER);
DROP FUNCTION IF EXISTS incrementar_intentos(VARCHAR);

-- =============================================
-- TABLAS
-- =============================================

-- Tabla usuario
CREATE TABLE usuario (
    id_usuario     SERIAL PRIMARY KEY,
    nombre         VARCHAR(100)  NOT NULL
                   CHECK (LENGTH(TRIM(nombre)) >= 2),
    email          VARCHAR(250)  NOT NULL UNIQUE
                   CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    password_hash  VARCHAR(255)  NOT NULL,
    rol            VARCHAR(10)   NOT NULL
                   CHECK (rol IN ('escritor','lector')),
    fecha_registro TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bio            VARCHAR(500),
    ultimo_acceso  TIMESTAMP,
    intentos_login INTEGER       NOT NULL DEFAULT 0,
    activo         BOOLEAN       NOT NULL DEFAULT TRUE
);

-- Tabla obra
CREATE TABLE obra (
    id_obra           SERIAL PRIMARY KEY,
    id_autor          INTEGER       NOT NULL
                      REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    titulo            VARCHAR(200)  NOT NULL
                      CHECK (LENGTH(TRIM(titulo)) >= 1),
    descripcion       VARCHAR(1000),
    genero            VARCHAR(50),
    precio            NUMERIC(10,2) NOT NULL DEFAULT 0.00
                      CHECK (precio >= 0),
    archivo_url       VARCHAR(500)  NOT NULL,
    num_lecturas      INTEGER       NOT NULL DEFAULT 0
                      CHECK (num_lecturas >= 0),
    fecha_publicacion TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo            BOOLEAN       NOT NULL DEFAULT TRUE
);

-- Tabla comentario
CREATE TABLE comentario (
    id_comentario    SERIAL PRIMARY KEY,
    id_usuario       INTEGER      NOT NULL
                     REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_obra          INTEGER      NOT NULL
                     REFERENCES obra(id_obra) ON DELETE CASCADE,
    contenido        VARCHAR(500) NOT NULL
                     CHECK (LENGTH(TRIM(contenido)) >= 1),
    fecha_comentario TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo           BOOLEAN      NOT NULL DEFAULT TRUE
);

-- Tabla mensaje
CREATE TABLE mensaje (
    id_mensaje      SERIAL PRIMARY KEY,
    id_remitente    INTEGER       NOT NULL
                    REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_destinatario INTEGER       NOT NULL
                    REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    contenido       VARCHAR(1000) NOT NULL
                    CHECK (LENGTH(TRIM(contenido)) >= 1),
    leido           BOOLEAN       NOT NULL DEFAULT FALSE,
    fecha_envio     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (id_remitente != id_destinatario)
);

-- Tabla like_obra
CREATE TABLE like_obra (
    id_usuario INTEGER   NOT NULL
               REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_obra    INTEGER   NOT NULL
               REFERENCES obra(id_obra) ON DELETE CASCADE,
    fecha_like TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_obra)
);

-- Tabla seguimiento
CREATE TABLE seguimiento (
    id_seguidor       INTEGER   NOT NULL
                      REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_autor          INTEGER   NOT NULL
                      REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    fecha_seguimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_seguidor, id_autor),
    CHECK (id_seguidor != id_autor)
);

-- =============================================
-- ÍNDICES para rendimiento y seguridad
-- =============================================

CREATE INDEX idx_usuario_email
    ON usuario(email);
CREATE INDEX idx_usuario_rol
    ON usuario(rol);
CREATE INDEX idx_obra_autor
    ON obra(id_autor);
CREATE INDEX idx_obra_genero
    ON obra(genero);
CREATE INDEX idx_obra_lecturas
    ON obra(num_lecturas DESC);
CREATE INDEX idx_comentario_obra
    ON comentario(id_obra);
CREATE INDEX idx_mensaje_remitente
    ON mensaje(id_remitente);
CREATE INDEX idx_mensaje_destinatario
    ON mensaje(id_destinatario);
CREATE INDEX idx_like_obra
    ON like_obra(id_obra);
CREATE INDEX idx_seguimiento_autor
    ON seguimiento(id_autor);

-- =============================================
-- VISTA segura de usuarios oculta password_hash e intentos_login
-- =============================================

CREATE VIEW vista_usuario_publico AS
    SELECT
        id_usuario,
        nombre,
        email,
        rol,
        fecha_registro,
        bio,
        ultimo_acceso
    FROM usuario
    WHERE activo = TRUE;

-- =============================================
-- FUNCIONES de seguridad
-- =============================================

-- Registrar acceso exitoso
CREATE OR REPLACE FUNCTION registrar_acceso(p_id_usuario INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE usuario
    SET ultimo_acceso  = CURRENT_TIMESTAMP,
        intentos_login = 0
    WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;

-- Incrementar intentos fallidos y bloquear tras 5 intentos
CREATE OR REPLACE FUNCTION incrementar_intentos(p_email VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    v_intentos INTEGER;
BEGIN
    UPDATE usuario
    SET intentos_login = intentos_login + 1
    WHERE email = p_email
    RETURNING intentos_login INTO v_intentos;

    IF v_intentos >= 5 THEN
        UPDATE usuario
        SET activo = FALSE
        WHERE email = p_email;
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- HARDENING DE BASE DE DATOS
-- Medidas de seguridad adicionales
-- =============================================

-- Medida: Timeouts de seguridad
-- Cierra transacciones inactivas tras 5 minutos
-- Cancela consultas que tarden mas de 30 segundos
ALTER ROLE tintahub_user SET idle_in_transaction_session_timeout = '5min';
ALTER ROLE tintahub_user SET statement_timeout = '30s';

-- Medida: Logging de seguridad
-- Registra consultas lentas, conexiones y bloqueos
ALTER SYSTEM SET log_min_duration_statement = '1000';
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_lock_waits = 'on';

-- Medida: Revocar permisos publicos por defecto
-- Aplica el principio de minimo privilegio
REVOKE ALL ON DATABASE tintahub_db FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO tintahub_user;

-- Recargar configuracion para aplicar los cambios
SELECT pg_reload_conf();

-- =============================================
-- RGPD - Reglamento General de Proteccion de Datos
-- =============================================

-- Campos de consentimiento y trazabilidad legal
-- en la tabla usuario
ALTER TABLE usuario 
    ADD COLUMN IF NOT EXISTS consentimiento_rgpd BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE usuario 
    ADD COLUMN IF NOT EXISTS fecha_consentimiento TIMESTAMP;

ALTER TABLE usuario 
    ADD COLUMN IF NOT EXISTS version_terminos VARCHAR(10);

ALTER TABLE usuario 
    ADD COLUMN IF NOT EXISTS fecha_solicitud_baja TIMESTAMP;

ALTER TABLE usuario 
    ADD COLUMN IF NOT EXISTS anonimizado BOOLEAN NOT NULL DEFAULT FALSE;

-- Tabla de registro de consentimientos
-- Guarda un historial inmutable de cada vez que
-- un usuario acepta o retira su consentimiento
-- Obligatorio para poder DEMOSTRAR cumplimiento ante una auditoria
CREATE TABLE IF NOT EXISTS registro_consentimiento (
    id_registro    SERIAL PRIMARY KEY,
    id_usuario     INTEGER      NOT NULL
                   REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    accion         VARCHAR(20)  NOT NULL
                   CHECK (accion IN ('otorgado', 'retirado')),
    version_terminos VARCHAR(10) NOT NULL,
    ip_origen      VARCHAR(45),
    fecha          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_registro_consentimiento_usuario
    ON registro_consentimiento(id_usuario);

-- Funcion para anonimizar un usuario
-- en lugar de borrarlo fisicamente
-- Esto permite cumplir el "derecho al olvido" 
-- sin romper la integridad referencial de obras,
-- comentarios y mensajes ya existentes
CREATE OR REPLACE FUNCTION anonimizar_usuario(p_id_usuario INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE usuario
    SET nombre         = 'Usuario eliminado',
        email          = 'eliminado_' || p_id_usuario || '@tintahub.es',
        password_hash  = 'ANONIMIZADO',
        bio            = NULL,
        activo         = FALSE,
        anonimizado    = TRUE,
        fecha_solicitud_baja = CURRENT_TIMESTAMP
    WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;

-- Funcion para exportar todos los datos de un usuario
-- Cumple el derecho de portabilidad del RGPD (Art. 20)
CREATE OR REPLACE FUNCTION exportar_datos_usuario(p_id_usuario INTEGER)
RETURNS JSONB AS $$
DECLARE
    resultado JSONB;
BEGIN
    SELECT jsonb_build_object(
        'datos_personales', (
            SELECT row_to_json(u) FROM (
                SELECT id_usuario, nombre, email, rol, 
                       fecha_registro, bio, ultimo_acceso
                FROM usuario WHERE id_usuario = p_id_usuario
            ) u
        ),
        'obras', (
            SELECT COALESCE(jsonb_agg(row_to_json(o)), '[]'::JSONB)
            FROM obra o WHERE id_autor = p_id_usuario
        ),
        'comentarios', (
            SELECT COALESCE(jsonb_agg(row_to_json(c)), '[]'::JSONB)
            FROM comentario c WHERE id_usuario = p_id_usuario
        ),
        'mensajes_enviados', (
            SELECT COALESCE(jsonb_agg(row_to_json(m)), '[]'::JSONB)
            FROM mensaje m WHERE id_remitente = p_id_usuario
        )
    ) INTO resultado;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;