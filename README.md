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

TintaHub se despliega sobre un servidor **Ubuntu Server 24.04 LTS** virtualizado mediante **VMware Workstation Pro**. La aplicación sigue una arquitectura multicapa basada en contenedores Docker, donde cada servicio se ejecuta de forma independiente y se comunica a través de una red privada gestionada por Docker Compose.

El acceso desde Internet se realiza de forma segura mediante **Cloudflare Tunnel**, evitando la exposición directa de la dirección IP pública del servidor. **Nginx** actúa como *reverse proxy*, gestionando las peticiones HTTP y redirigiéndolas al backend de la aplicación, mientras que **PostgreSQL** permanece aislado y accesible únicamente desde la red interna de Docker.

### Flujo de la arquitectura

```text
                 Internet
                     │
             Cloudflare (HTTPS)
                     │
           Cloudflare Tunnel
                     │
      Ubuntu Server 24.04 LTS
     (VMware Workstation Pro)
                     │
             Docker Compose
                     │
      ┌────────┬──────────┬────────────┐
      │        │          │            │
   Nginx   Backend     PostgreSQL   Docker Network
 (Reverse   Node.js      16
  Proxy)
```

### Componentes de la infraestructura

| Componente              | Función                                 |
| ----------------------- | --------------------------------------- |
| Ubuntu Server 24.04 LTS | Sistema operativo del servidor          |
| VMware Workstation Pro  | Virtualización del entorno              |
| Docker                  | Contenedorización de los servicios      |
| Docker Compose          | Orquestación de la infraestructura      |
| Nginx                   | Reverse Proxy y servidor web            |
| Node.js + Express       | Backend de la aplicación                |
| PostgreSQL 16           | Base de datos relacional                |
| Cloudflare Tunnel       | Acceso seguro sin exponer la IP pública |
| GitHub Actions          | Automatización del despliegue continuo  |

## Base de datos

TintaHub utiliza **PostgreSQL 16** como sistema de gestión de bases de datos relacional. El modelo de datos fue diseñado siguiendo principios de normalización e integridad referencial para garantizar la consistencia de la información y facilitar el mantenimiento de la aplicación.

La base de datos se ejecuta como un contenedor independiente dentro de la red privada de Docker Compose, permaneciendo inaccesible desde Internet y permitiendo conexiones únicamente desde el servicio backend.

### Modelo relacional

La base de datos está compuesta por **6 tablas principales**, una **vista** y **dos funciones PL/pgSQL**.

| Objeto                     | Función                                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **usuario**                | Gestión de usuarios, autenticación, roles y estado de la cuenta.                                            |
| **obra**                   | Información de las obras publicadas por los autores.                                                        |
| **comentario**             | Comentarios realizados por los lectores sobre cada obra.                                                    |
| **mensaje**                | Sistema de mensajería privada entre usuarios.                                                               |
| **like_obra**              | Relación entre usuarios y obras para registrar los "Me gusta".                                              |
| **seguimiento**            | Relación entre lectores y autores seguidos.                                                                 |
| **vista_usuario_publico**  | Vista segura que oculta información sensible de los usuarios.                                               |
| **registrar_acceso()**     | Actualiza el último acceso del usuario y reinicia el contador de intentos fallidos.                         |
| **incrementar_intentos()** | Gestiona los intentos de inicio de sesión y bloquea automáticamente la cuenta tras cinco intentos fallidos. |

### Diseño e integridad de los datos

Durante el diseño de la base de datos se implementaron diferentes mecanismos para garantizar la calidad, seguridad y consistencia de la información:

* Modelado relacional normalizado.
* Claves primarias (`PRIMARY KEY`) en todas las entidades.
* Claves foráneas (`FOREIGN KEY`) para mantener la integridad referencial.
* Restricciones (`CHECK`) para validar datos y reglas de negocio.
* Restricciones `UNIQUE` para evitar duplicidades.
* Valores por defecto (`DEFAULT`) para simplificar la inserción de registros.
* Eliminación en cascada (`ON DELETE CASCADE`) para mantener la consistencia entre tablas relacionadas.

### Optimización del rendimiento

Con el objetivo de mejorar el rendimiento de las consultas más frecuentes se implementaron índices específicos sobre los campos de búsqueda y relaciones entre tablas, incluyendo:

* Búsqueda de usuarios por correo electrónico.
* Filtrado por rol.
* Consulta de obras por autor y género.
* Ordenación por número de lecturas.
* Recuperación de comentarios por obra.
* Mensajería entre usuarios.
* Consultas de seguidores y "Me gusta".

### Seguridad aplicada

La base de datos incorpora diferentes mecanismos de protección orientados a la seguridad de la información:

* Almacenamiento de contraseñas mediante hash.
* Vista pública que oculta información sensible como el hash de la contraseña y el número de intentos de inicio de sesión.
* Funciones PL/pgSQL para controlar el acceso de los usuarios.
* Bloqueo automático de cuentas tras múltiples intentos fallidos de autenticación.
* Gestión de credenciales mediante variables de entorno.
* Acceso restringido exclusivamente desde el backend a través de la red privada de Docker.

### Competencias técnicas aplicadas

* PostgreSQL 16
* Diseño de bases de datos relacionales
* Modelado de datos
* Integridad referencial
* Optimización mediante índices
* Vistas SQL
* Funciones PL/pgSQL
* Seguridad en bases de datos
* Docker
* SQL


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
