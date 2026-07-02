// =============================================
// utils/sanitizar.js
// Limpieza de contenido generado por usuarios
// para prevenir ataques XSS
// =============================================

const { JSDOM } = require('jsdom');
const DOMPurify = require('dompurify');

// Creamos una ventana virtual de navegador
// porque DOMPurify necesita un DOM para funcionar
// y en el backend no existe un navegador real
const window = new JSDOM('').window;
const purify = DOMPurify(window);

// Limpia cualquier texto de codigo HTML/JavaScript
// malicioso antes de guardarlo en la base de datos
// Ejemplo: si alguien escribe <script>robarDatos()</script>
// esta funcion lo elimina dejando solo texto plano
function sanitizarTexto(texto) {
  if (typeof texto !== 'string') {
    return texto;
  }

  // ALLOWED_TAGS vacio significa que eliminamos
  // absolutamente todas las etiquetas HTML
  // dejando solo texto plano limpio
  return purify.sanitize(texto, {
    ALLOWED_TAGS: [],
    ALLOWED_ATTR: [],
  });
}

module.exports = { sanitizarTexto };