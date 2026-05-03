-- =============================================
-- TintaHub - Plataforma Web de Difusión Literaria
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

-- =============================================
-- MEDIDA — Roles y permisos de base de datos
-- =============================================

-- Eliminar roles si existen para evitar errores
DROP ROLE IF EXISTS tintahub_app;
DROP ROLE IF EXISTS tintahub_readonly;

-- Rol para la aplicación — solo lo necesario
CREATE ROLE tintahub_app WITH LOGIN
    PASSWORD :'TINTAHUB_APP_PASSWORD'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOINHERIT
    CONNECTION LIMIT 20;

-- Rol de solo lectura — para consultas de reporting
CREATE ROLE tintahub_readonly WITH LOGIN
    PASSWORD :'TINTAHUB_READONLY_PASSWORD'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    CONNECTION LIMIT 5;

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
    activo         BOOLEAN       NOT NULL DEFAULT TRUE,
    bio            VARCHAR(500),
    intentos_login INTEGER       NOT NULL DEFAULT 0,
    ultimo_acceso  TIMESTAMP
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
    PRIMARY KEY (id_seguidor, id_autor),
    CHECK (id_seguidor != id_autor)
);

-- =============================================
-- MEDIDA — Índices para rendimiento
-- =============================================
CREATE INDEX idx_obra_autor        ON obra(id_autor);
CREATE INDEX idx_obra_genero       ON obra(genero);
CREATE INDEX idx_obra_lecturas     ON obra(num_lecturas DESC);
CREATE INDEX idx_comentario_obra   ON comentario(id_obra);
CREATE INDEX idx_mensaje_remitente ON mensaje(id_remitente);
CREATE INDEX idx_mensaje_destinatario ON mensaje(id_destinatario);
CREATE INDEX idx_like_obra         ON like_obra(id_obra);
CREATE INDEX idx_seguimiento_autor ON seguimiento(id_autor);

-- =============================================
-- MEDIDA — Permisos del rol de aplicación
-- =============================================

-- Permisos de lectura y escritura para la aplicación
GRANT SELECT, INSERT, UPDATE, DELETE
    ON usuario, obra, comentario, mensaje, like_obra, seguimiento
    TO tintahub_app;

-- Permisos sobre las secuencias SERIAL
GRANT USAGE, SELECT
    ON ALL SEQUENCES IN SCHEMA public
    TO tintahub_app;

-- Permisos de solo lectura
GRANT SELECT
    ON usuario, obra, comentario, mensaje, like_obra, seguimiento
    TO tintahub_readonly;

-- =============================================
-- MEDIDA — Vista segura de usuarios (oculta password_hash e intentos_login)
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

GRANT SELECT ON vista_usuario_publico TO tintahub_app;

-- =============================================
-- MEDIDA — Función para registrar accesos
-- =============================================

CREATE OR REPLACE FUNCTION registrar_acceso(p_id_usuario INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE usuario
    SET ultimo_acceso = CURRENT_TIMESTAMP,
        intentos_login = 0
    WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- MEDIDA — Función para bloquear tras intentos fallidos de login
-- =============================================

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
CREATE INDEX idx_usuario_email ON usuario(email);
CREATE INDEX idx_usuario_rol   ON usuario(rol);
