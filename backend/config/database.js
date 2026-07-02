// =============================================
// config/database.js
// Configuracion de la conexion a PostgreSQL
// =============================================

const { Pool } = require('pg');

const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,

  // Limite de conexiones simultaneas del pool
  // Coincide con el CONNECTION LIMIT que configuramos
  // en el rol de PostgreSQL
  max: 15,

  // Tiempo maximo que una conexion puede estar inactiva
  // antes de ser cerrada por el pool
  idleTimeoutMillis: 30000,

  // Tiempo maximo de espera para conseguir una conexion
  // del pool antes de lanzar un error
  connectionTimeoutMillis: 5000,
});

// Verificar la conexion al arrancar
pool.on('connect', () => {
  console.log('Conexion establecida con PostgreSQL');
});

pool.on('error', (err) => {
  console.error('Error inesperado en el pool de PostgreSQL:', err);
});

module.exports = pool;