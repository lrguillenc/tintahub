# TintaHub — Plataforma Web de Difusión Literaria

![License](https://img.shields.io/badge/license-CC%20BY--NC--ND%204.0-lightgrey)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Status](https://img.shields.io/badge/status-En%20desarrollo-yellow)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20LTS-orange)
![Docker](https://img.shields.io/badge/Docker-29.3.0-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Nginx](https://img.shields.io/badge/Nginx-latest-green)

## Descripción

TintaHub es una plataforma web de difusión literaria de carácter open source 
y sin ánimo de lucro, orientada a escritores emergentes que buscan publicar 
sus obras de forma libre e independiente, y a lectores interesados en 
descubrir nuevos talentos literarios fuera de los circuitos comerciales 
tradicionales.

Este proyecto forma parte del Trabajo de Fin de Grado del ciclo formativo 
de Grado Superior en Administración de Sistemas Informáticos en Red (ASIR).

## Características principales

- Registro y autenticación de usuarios con roles diferenciados (escritor/lector)
- Publicación y gestión de obras digitales en formato PDF
- Sistema de mensajería interna entre usuarios
- Sistema de interacción: likes, comentarios y seguimiento de autores
- Algoritmo de visibilidad basado en interacción de la comunidad
- Sin comisiones sobre ventas ni modelos de suscripción

## Stack tecnológico

| Tecnología | Versión | Uso |
|---|---|---|
| Ubuntu Server LTS | 24.04 | Sistema operativo del servidor |
| Docker | 29.3.0 | Contenedorización de servicios |
| Docker Compose | 2.40.0 | Orquestación de contenedores |
| Nginx | latest | Servidor web y reverse proxy |
| PostgreSQL | 16 | Base de datos relacional |
| Node.js | 20 | Backend de la aplicación |
| Express | 4.18 | Framework web del backend |
| Cloudflare Tunnel | 2026.3.0 | Acceso seguro sin IP pública |
| VMware Workstation Pro | 17 | Virtualización del servidor |

## Estructura del proyecto
tintahub/
│   docker-compose.yml
│   .env.example
│   README.md
│   LICENSE
│
├── backend/
│     Dockerfile
│     package.json
│     server.js
│
├── base_datos/
│     init.sql
│
├── frontend/
│     index.html
│
└── nginx/
└── conf/
default.conf

## Arquitectura

Internet → Cloudflare (SSL/TLS) → Cloudflare Tunnel
↓
Ubuntu Server 24.04 LTS
(VMware Workstation Pro 17)
↓
Docker Network
┌───────────────────────┐
│  Nginx (puerto 80)    │
│  Backend Node.js      │
│  PostgreSQL 16        │
└───────────────────────┘

## Requisitos previos

- VMware Workstation Pro 17 o superior
- Ubuntu Server 24.04 LTS
- Docker 20.0 o superior
- Docker Compose 2.0 o superior
- Dominio propio (opcional, recomendado)
- Cuenta en Cloudflare (gratuita)

## Instalación

### 1 — Clonar el repositorio

```bash
git clone https://github.com/lrguillenc/tintahub.git
cd tintahub
```

### 2 — Crear el archivo de variables de entorno

```bash
cp .env.example .env
nano .env
```

Rellena las variables con tus propios valores.

### 3 — Levantar el stack

```bash
docker compose up -d
```

### 4 — Verificar

```bash
docker ps
```

## Seguridad implementada

- Autenticación SSH mediante par de claves RSA de 4096 bits
- Firewall UFW con política de denegación por defecto
- Fail2ban para prevención de ataques de fuerza bruta
- Credenciales en variables de entorno
- PostgreSQL y backend no expuestos externamente
- Cabeceras HTTP de seguridad en Nginx
- IP del servidor oculta mediante Cloudflare Tunnel
- HTTPS con certificado SSL de Cloudflare

## Autor

**Luis Rodrigo Guillén Calderón**
Trabajo de Fin de Grado — ASIR
ThePower FP Oficial — 2026

## Licencia

Este proyecto está protegido bajo la licencia Creative Commons
Atribución-NoComercial-SinDerivadas 4.0 Internacional (CC BY-NC-ND 4.0)

- Puedes ver y estudiar el código
- Puedes compartirlo citando al autor
- No puedes usarlo con fines comerciales
- No puedes modificarlo y redistribuirlo
- No puedes presentarlo como trabajo propio

© 2026 Luis Rodrigo Guillén Calderón. Todos los derechos reservados.