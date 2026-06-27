# TintaHub — Plataforma Web de Difusión Literaria

![License](https://img.shields.io/badge/license-CC%20BY--NC--ND%204.0-lightgrey)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Status](https://img.shields.io/badge/status-En%20desarrollo-yellow)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20LTS-orange)
![Docker](https://img.shields.io/badge/Docker-29.3.0-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Nginx](https://img.shields.io/badge/Nginx-latest-green)

## Descripción

TintaHub es una plataforma web de difusión literaria de código abierto desarrollada como Proyecto Intermodular del ciclo de Grado Superior en Administración de Sistemas Informáticos en Red (ASIR).

El objetivo del proyecto ha sido diseñar, desplegar y administrar una infraestructura completa para una aplicación web moderna, aplicando buenas prácticas de administración de sistemas, virtualización, seguridad, bases de datos y automatización de despliegues.

La solución se ejecuta sobre un servidor Ubuntu Server virtualizado e integra una arquitectura basada en contenedores Docker compuesta por un servidor web Nginx, un backend desarrollado con Node.js y una base de datos PostgreSQL. El despliegue continuo se automatiza mediante GitHub Actions y un self-hosted runner instalado en el propio servidor.

## Objetivos técnicos

Además del desarrollo funcional de la aplicación, el proyecto se diseñó con el objetivo de consolidar conocimientos en administración de sistemas e infraestructura mediante la implementación de un entorno de producción completo.

Los principales objetivos técnicos fueron:

* Diseñar una infraestructura basada en contenedores Docker para aislar y administrar los distintos servicios de la aplicación.
* Administrar un servidor Ubuntu Server 24.04 LTS virtualizado como plataforma principal del proyecto.
* Implementar una base de datos relacional PostgreSQL aplicando modelado de datos, integridad referencial, índices y vistas.
* Configurar Nginx como servidor web y *reverse proxy* para la publicación segura de la aplicación.
* Automatizar el despliegue continuo mediante GitHub Actions y un *self-hosted runner* instalado en el servidor.
* Aplicar medidas de hardening y seguridad mediante UFW, Fail2ban, autenticación SSH por claves, HTTPS y Cloudflare Tunnel.
* Gestionar la infraestructura utilizando buenas prácticas de administración, documentación y control de versiones con Git y GitHub.


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

## CI/CD — Despliegue Continuo

El proyecto implementa un pipeline de integración y despliegue 
continuo mediante GitHub Actions y un self-hosted runner instalado 
directamente en el servidor Ubuntu.

git push → GitHub Actions → Runner en servidor → Docker → tintahub.es

### Flujo de despliegue automático

Cada vez que se realiza un push a la rama `main` el pipeline 
ejecuta automáticamente los siguientes pasos:

1. Descarga los últimos cambios del repositorio
2. Para los contenedores Docker en ejecución
3. Levanta los contenedores actualizados
4. Verifica que el servicio responde correctamente

### Tecnologías del pipeline

| Componente | Uso |
|---|---|
| GitHub Actions | Orquestación del pipeline |
| Self-hosted Runner | Ejecución local en el servidor |
| Docker Compose | Gestión de contenedores |
| systemd | Runner como servicio permanente |

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

© 2026 Luis Rodrigo Guillén Calderón. Todos los derechos reservados.# CI/CD test
Pipeline automatico sin contraseña
