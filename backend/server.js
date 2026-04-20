const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const pool = new Pool({
    host:     process.env.DB_HOST,
    port:     process.env.DB_PORT,
    user:     process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
});

app.get('/', (req, res) => {
    res.json({ 
        plataforma: 'TintaHub',
        descripcion: 'Plataforma Web de Difusion Literaria',
        estado: 'API funcionando correctamente'
    });
});

app.get('/test-db', async (req, res) => {
    try {
        const result = await pool.query('SELECT COUNT(*) FROM usuario');
        res.json({
            estado: 'Base de datos conectada',
            usuarios: result.rows[0].count
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.listen(3000, () => {
    console.log('TintaHub API escuchando en puerto 3000');
});