// =============================================
// utils/jwt.js
// Generacion y verificacion de tokens JWT
// =============================================

const jwt = require('jsonwebtoken');

// El secreto para firmar los tokens viene de variable
// de entorno, nunca debe estar escrito en el codigo
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;

// Genera un token de acceso de corta duracion
// Se usa en cada peticion para verificar quien es el usuario
function generarAccessToken(usuario) {
  return jwt.sign(
    {
      id_usuario: usuario.id_usuario,
      rol: usuario.rol,
    },
    JWT_SECRET,
    { expiresIn: '2h' }
  );
}

// Genera un token de refresco de larga duracion
// Se usa solo para conseguir un nuevo access token
// sin tener que volver a hacer login
function generarRefreshToken(usuario) {
  return jwt.sign(
    { id_usuario: usuario.id_usuario },
    JWT_REFRESH_SECRET,
    { expiresIn: '7d' }
  );
}

// Verifica que un access token es valido y no ha expirado
function verificarAccessToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

// Verifica que un refresh token es valido y no ha expirado
function verificarRefreshToken(token) {
  return jwt.verify(token, JWT_REFRESH_SECRET);
}

module.exports = {
  generarAccessToken,
  generarRefreshToken,
  verificarAccessToken,
  verificarRefreshToken,
};