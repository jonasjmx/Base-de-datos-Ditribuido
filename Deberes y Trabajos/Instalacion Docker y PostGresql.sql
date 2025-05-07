Parte 1: Instalación de Docker en Windows
Paso 1: Requisitos del sistema
Windows 10 64-bit: Pro, Enterprise o Education (versión 1903 o posterior)

Habilitar Hyper-V y Virtualización en BIOS

Al menos 4GB de RAM

Paso 2: Descargar Docker Desktop
Visita el sitio oficial: https://www.docker.com/products/docker-desktop

Haz clic en "Download for Windows"

Ejecuta el instalador descargado (Docker Desktop Installer.exe)

Paso 3: Instalación
Acepta los términos de licencia

Selecciona "Install required Windows components"

Espera a que complete la instalación

Haz clic en "Close" y reinicia tu computadora

Paso 4: Configuración inicial
Después del reinicio, busca "Docker Desktop" en el menú Inicio y ejecútalo

Espera a que Docker se inicie (icono de ballena en la barra de tareas)

Abre PowerShell o CMD y verifica la instalación:

docker --version
docker-compose --version
docker run hello-world

Parte 2: Configuración de Nodos Distribuidos PostgreSQL en Docker
Paso 1: Crear una red Docker

docker network create bdd-distribuida

Paso 2: Crear archivo docker-compose.yml
Crea un archivo llamado docker-compose.yml con el siguiente contenido:

version: '3.8'

services:
  postgres-node1:
    image: postgres:14
    container_name: node1
    environment:
      POSTGRES_PASSWORD: admin123
      POSTGRES_USER: admin
      POSTGRES_DB: bdd_distribuida
    ports:
      - "5432:5432"
    networks:
      - bdd-distribuida

  postgres-node2:
    image: postgres:14
    container_name: node2
    environment:
      POSTGRES_PASSWORD: admin123
      POSTGRES_USER: admin
      POSTGRES_DB: bdd_distribuida
    ports:
      - "5433:5432"
    networks:
      - bdd-distribuida

  postgres-node3:
    image: postgres:14
    container_name: node3
    environment:
      POSTGRES_PASSWORD: admin123
      POSTGRES_USER: admin
      POSTGRES_DB: bdd_distribuida
    ports:
      - "5434:5432"
    networks:
      - bdd-distribuida

networks:
  bdd-distribuida:
    external: true

Paso 3: Iniciar los contenedores

docker-compose up -d

Paso 4: Verificar los contenedores

docker ps

Paso 5: Configurar la distribución de datos
Conectarse al primer nodo:

docker exec -it node1 psql -U admin -d bdd_distribuida

Crear tablas fragmentadas:

-- En node1 (Fragmento 1)
CREATE TABLE clientes_region1 (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  region VARCHAR(50) CHECK (region = 'Norte')
);

-- En node2 (Fragmento 2)
-- Conéctate primero a node2: docker exec -it node2 psql -U admin -d bdd_distribuida
CREATE TABLE clientes_region2 (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  region VARCHAR(50) CHECK (region = 'Sur')
);

Configurar Foreign Data Wrapper en node1:

CREATE EXTENSION postgres_fdw;

-- Configurar acceso a node2
CREATE SERVER node2_server FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'node2', dbname 'bdd_distribuida');

CREATE USER MAPPING FOR admin SERVER node2_server
OPTIONS (user 'admin', password 'admin123');

-- Crear una vista federada
CREATE FOREIGN TABLE clientes_region2_remote (
  id SERIAL,
  nombre VARCHAR(100),
  region VARCHAR(50)
) SERVER node2_server OPTIONS (schema_name 'public', table_name 'clientes_region2');

Paso 6: Probar la distribución
Insertar datos en cada nodo:

-- En node1
INSERT INTO clientes_region1 (nombre, region) VALUES ('Empresa A', 'Norte');

-- En node2 (conéctate primero)
INSERT INTO clientes_region2 (nombre, region) VALUES ('Empresa B', 'Sur');

Consulta federada desde node1:

SELECT * FROM clientes_region1
UNION ALL
SELECT * FROM clientes_region2_remote;

Configuración Avanzada
Para MongoDB (añade al docker-compose.yml)

mongo-node1:
  image: mongo:5
  container_name: mongo-node1
  command: --replSet rs0
  ports:
    - "27017:27017"
  networks:
    - bdd-distribuida


Para Cassandra (añade al docker-compose.yml)

cassandra-node1:
  image: cassandra:4
  container_name: cassandra-node1
  environment:
    CASSANDRA_CLUSTER_NAME: BDD_Cluster
  ports:
    - "9042:9042"
  networks:
    - bdd-distribuida

Monitoreo
Verificar comunicación entre nodos:

docker exec -it node1 ping node2

Instalar PgAdmin para gestión gráfica:

docker run -p 5050:80 -e "PGADMIN_DEFAULT_EMAIL=admin@example.com" -e "PGADMIN_DEFAULT_PASSWORD=admin123" -d dpage/pgadmin4

Accede en: http://localhost:5050



