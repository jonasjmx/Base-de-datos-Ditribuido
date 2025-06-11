-- ##################################################################################################
-- CONFIGURACIÓN DEL SERVIDOR MAESTRO PARA REPLICACIÓN
-- Este script configura un servidor MySQL para replicación y crea la estructura de una base de datos
-- para un sistema de gestión hospitalaria. Incluye la creación de usuarios, tablas y datos de prueba.
-- ##################################################################################################

-- Configuración de la política de contraseñas
-- Cambia la política de contraseñas a un nivel bajo para facilitar la creación de usuarios.
SET GLOBAL validate_password.policy = LOW;

-- ##################################################################################################
-- CREACIÓN DE USUARIOS PARA REPLICACIÓN Y ACCESO
-- ##################################################################################################

-- Crear usuarios para las sucursales
-- Estos usuarios tendrán acceso a la base de datos desde direcciones IP específicas.
CREATE USER 'guayaquil'@'34.138.97.31' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
CREATE USER 'cuenca'@'34.23.230.158' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
CREATE USER 'latacunga'@'34.138.113.161' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';

-- Otorgar privilegios a los usuarios de las sucursales
-- Se otorgan todos los privilegios sobre la base de datos "GestionHospitalaria".
GRANT ALL PRIVILEGES ON GestionHospitalaria.* TO 'guayaquil'@'34.138.97.31';
GRANT ALL PRIVILEGES ON GestionHospitalaria.* TO 'cuenca'@'34.23.230.158';
GRANT ALL PRIVILEGES ON GestionHospitalaria.* TO 'latacunga'@'34.138.113.161';
FLUSH PRIVILEGES;

-- Eliminar usuarios (opcional, para limpieza)
DROP USER 'guayaquil'@'34.138.97.31';
DROP USER 'cuenca'@'34.23.230.158';
DROP USER 'latacunga'@'34.138.113.161';
FLUSH PRIVILEGES;

-- Crear usuario para replicación
-- Este usuario se utiliza para la replicación entre servidores MySQL.
CREATE USER 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';

-- Otorgar privilegios de replicación al usuario replicator
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;

-- Eliminar usuarios de replicación (opcional, para limpieza)
DROP USER 'replicator'@'%';
FLUSH PRIVILEGES;

-- Crear usuarios de replicación con IP específicas
CREATE USER 'replicator'@'34.138.97.31' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
CREATE USER 'replicator'@'34.23.230.158' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
CREATE USER 'replicator'@'34.138.113.161' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'34.138.97.31';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'34.23.230.158';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'34.138.113.161';
FLUSH PRIVILEGES;

-- Eliminar usuarios de replicación con IP específicas (opcional)
DROP USER 'replicator'@'34.138.97.31';
DROP USER 'replicator'@'34.23.230.158';
DROP USER 'replicator'@'34.138.113.161';
FLUSH PRIVILEGES;

-- ##################################################################################################
-- VERIFICACIONES IMPORTANTES
-- ##################################################################################################

-- Verificar si el log binario está habilitado (necesario para replicación)
SHOW VARIABLES LIKE 'log_bin';

-- Verificar si SSL está habilitado (para conexiones seguras)
SHOW VARIABLES LIKE '%ssl%';

-- Verificar el plugin de autenticación utilizado por el servidor
INSTALL PLUGIN mysql_native_password SONAME 'auth_native_password.so';

-- Cambiar el plugin de autenticación del usuario replicator
ALTER USER 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
ALTER USER 'replicator'@'34.138.97.31' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
ALTER USER 'replicator'@'34.23.230.158' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
ALTER USER 'replicator'@'34.138.113.161' IDENTIFIED WITH mysql_native_password BY 'Centromedico@123';
FLUSH PRIVILEGES;

-- Verificar el UUID del servidor (debe ser único para replicación)
SHOW VARIABLES LIKE 'server_uuid';

-- Verificar el plugin de autenticación del usuario replicator
SELECT User, Host, plugin FROM mysql.user WHERE User = 'replicator';

-- Mostrar los privilegios del usuario replicator
SHOW GRANTS FOR 'replicator'@'%';

-- Verificar las bases de datos configuradas para replicación
SHOW VARIABLES LIKE 'binlog_do_db';

-- Mostrar eventos del log binario (opcional para depuración)
SHOW BINLOG EVENTS IN 'mysql-bin.000004' FROM 569 LIMIT 10;

-- Bloquear y desbloquear tablas (para sincronización)
FLUSH TABLES WITH READ LOCK;
UNLOCK TABLES;

-- Desbloquear IPs bloqueadas (importante en caso de errores de conexión)
FLUSH HOSTS;

-- Mostrar todos los usuarios configurados en el servidor
SELECT User, Host FROM mysql.user;

-- ##################################################################################################
-- VERIFICACIONES FINALES
-- ##################################################################################################

-- Mostrar la versión del servidor MySQL
SELECT @@version;

-- Mostrar el estado del maestro para replicación
SHOW MASTER STATUS;

-- Nota: Si los valores cambian después de un reinicio, actualice los esclavos.


-- ##################################################################################################
-- CREACIÓN DE LA BASE DE DATOS PARA EL CENTRO MÉDICO
-- ##################################################################################################

CREATE DATABASE IF NOT EXISTS CentroMedicoDB;
USE CentroMedicoDB;

-- Tabla de centros médicos
CREATE TABLE CentrosMedicos (
    CentroID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(100) NOT NULL,
    Direccion VARCHAR(200),
    Telefono VARCHAR(20)
);

-- Tabla de especialidades
CREATE TABLE Especialidades (
    EspecialidadID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255)
);

-- Tabla de usuarios para inicio de sesión
CREATE TABLE UsuariosCentro (
    UsuarioID INT AUTO_INCREMENT PRIMARY KEY,
    CentroID INT NOT NULL,
    Email VARCHAR(75) NOT NULL UNIQUE,
    Contrasena VARCHAR(75) NOT NULL,
    FOREIGN KEY (CentroID) REFERENCES CentrosMedicos(CentroID)
);

-- Tabla de médicos
CREATE TABLE Medicos (
    MedicoID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    EspecialidadID INT NOT NULL,
    CentroID INT NOT NULL,
    Email VARCHAR(100),
    Telefono VARCHAR(20),
    FOREIGN KEY (EspecialidadID) REFERENCES Especialidades(EspecialidadID),
    FOREIGN KEY (CentroID) REFERENCES CentrosMedicos(CentroID)
);

-- Tabla de asignación de especialidades
CREATE TABLE AsignacionEspecialidades (
    AsignacionID INT AUTO_INCREMENT PRIMARY KEY,
    MedicoID INT NOT NULL,
    EspecialidadID INT NOT NULL,
    FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID),
    FOREIGN KEY (EspecialidadID) REFERENCES Especialidades(EspecialidadID)
);

-- Tabla de empleados
CREATE TABLE Empleados (
    EmpleadoID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Cargo VARCHAR(100),
    Email VARCHAR(100),
    Telefono VARCHAR(20)
);

-- Tabla de clientes
CREATE TABLE Clientes (
    ClienteID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Correo VARCHAR(100),
    Telefono VARCHAR(20)
);

-- Tabla de consultas
CREATE TABLE Consultas (
    ConsultaID INT AUTO_INCREMENT PRIMARY KEY,
    MedicoID INT NOT NULL,
    ClienteID INT NOT NULL,
    FechaConsulta DATETIME NOT NULL,
    Diagnostico VARCHAR(255),
    Tratamiento VARCHAR(255),
    FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Insertar datos de prueba

INSERT INTO CentrosMedicos (Nombre, Ciudad, Direccion, Telefono) VALUES
('Centro Médico Quito', 'Quito', 'Av. Amazonas 123', '022345678'),
('Centro Médico Guayaquil', 'Guayaquil', 'Malecón 2000', '042345678'),
('Centro Médico Cuenca', 'Cuenca', 'Av. Solano 456', '072345678');

INSERT INTO Especialidades (Nombre, Descripcion) VALUES
('Cardiología', 'Especialidad en enfermedades del corazón'),
('Pediatría', 'Especialidad en atención infantil'),
('Dermatología', 'Especialidad en enfermedades de la piel');

INSERT INTO UsuariosCentro (CentroID, Email, Contrasena) VALUES
(1, 'admin@norte.com', 'admin123'),
(2, 'admin@sur.com', 'admin456'),
(3, 'admin@este.com', 'admin789');

INSERT INTO Medicos (Nombre, Apellido, EspecialidadID, CentroID, Email, Telefono) VALUES
('Juan', 'Pérez', 1, 1, 'juan.perez@medico.com', '0991111111'),
('María', 'Gómez', 2, 2, 'maria.gomez@medico.com', '0992222222'),
('Carlos', 'Lopez', 3, 3, 'carlos.lopez@medico.com', '0993333333');

INSERT INTO AsignacionEspecialidades (MedicoID, EspecialidadID) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO Empleados (Nombre, Apellido, Cargo, Email, Telefono) VALUES
('Ana', 'Martínez', 'Recepcionista', 'ana.martinez@empleado.com', '0981111111'),
('Luis', 'Ramírez', 'Enfermero', 'luis.ramirez@empleado.com', '0982222222'),
('Sofía', 'Vega', 'Administrador', 'sofia.vega@empleado.com', '0983333333');

INSERT INTO Clientes (Nombre, Apellido, Correo, Telefono) VALUES
('Pedro', 'Alvarez', 'pedro.alvarez@cliente.com', '0971111111'),
('Lucía', 'Mora', 'lucia.mora@cliente.com', '0972222222'),
('Miguel', 'Salas', 'miguel.salas@cliente.com', '0973333333');

INSERT INTO Consultas (MedicoID, ClienteID, FechaConsulta, Diagnostico, Tratamiento) VALUES
(1, 1, '2024-06-08 09:00:00', 'Chequeo general', 'Paracetamol 500mg'),
(2, 2, '2024-06-08 10:00:00', 'Consulta pediátrica', 'Ibuprofeno 200mg'),
(3, 3, '2024-06-08 11:00:00', 'Consulta dermatológica', 'Crema hidratante');

-- ##################################################################################################
-- Script de configuración para la replicación en MySQL (Servidor Esclavo)
-- Archivo: Centro_Medico_Guayaquil.sql
-- Descripción: Este script configura un servidor esclavo para la replicación de datos desde un servidor maestro.
-- Incluye la configuración inicial del esclavo, verificaciones, reinicio de replicación y creación de vistas.
-- ##################################################################################################

-- ##################################################################################################
-- CREACIÓN DE LA BASE DE DATOS
-- ##################################################################################################

-- Crear la base de datos para la gestión hospitalaria si no existe.
-- Esto asegura que el esquema esté disponible antes de iniciar la replicación.
CREATE DATABASE IF NOT EXISTS GestionHospitalaria;

-- ##################################################################################################
-- CONFIGURACIÓN INICIAL DEL ESCLAVO PARA LA REPLICACIÓN
-- ##################################################################################################

-- Configurar el servidor esclavo para conectarse al servidor maestro.
-- NOTA: Asegúrate de que los valores de MASTER_HOST, MASTER_USER, MASTER_PASSWORD, MASTER_LOG_FILE y MASTER_LOG_POS
-- coincidan con los valores del servidor maestro. Estos valores deben ser proporcionados por el administrador del maestro.
CHANGE MASTER TO
    MASTER_HOST 	= '34.138.196.138',               -- Dirección IP o nombre del host del servidor maestro
    MASTER_USER 	= 'replicator',                -- Usuario configurado para la replicación en el maestro
    MASTER_PASSWORD = 'Centromedico@123',          -- Contraseña del usuario de replicación
    MASTER_LOG_FILE = 'mysql-bin.000002',      -- Archivo de registro binario actual en el maestro
    MASTER_LOG_POS 	= 9641;                     -- Posición en el archivo binario del maestro

-- Iniciar el proceso de replicación en el servidor esclavo.
START SLAVE;

-- ##################################################################################################
-- VERIFICACIONES INICIALES
-- ##################################################################################################

-- Mostrar los primeros 10 eventos del relay log para verificar que los datos se están replicando correctamente.
SHOW RELAYLOG EVENTS IN 'mysql-relay-bin.000002';

-- Mostrar las variables relacionadas con la replicación para confirmar la configuración.
SHOW VARIABLES LIKE '%replicate%';

-- Mostrar el estado del esclavo para verificar que la replicación esté funcionando correctamente.
-- Esto incluye información como el estado de conexión con el maestro y posibles errores.
SHOW SLAVE STATUS;

-- NOTA IMPORTANTE: Verificar si las variables MASTER_ son correctas. Si no coinciden, realizar los ajustes necesarios.

-- ##################################################################################################
-- REINICIO Y RECONFIGURACIÓN DEL ESCLAVO (SI ES NECESARIO)
-- ##################################################################################################

-- Detener el proceso de replicación en caso de que sea necesario realizar ajustes.
STOP SLAVE;

-- Reiniciar la configuración del esclavo para limpiar cualquier configuración previa.
RESET SLAVE ALL;

-- Reconfigurar el esclavo con nuevos valores (si es necesario).
CHANGE MASTER TO
    MASTER_HOST 	= '34.138.196.138',               -- Dirección IP o nombre del host del servidor maestro
    MASTER_USER 	= 'replicator',                -- Usuario configurado para la replicación en el maestro
    MASTER_PASSWORD = 'Centromedico@123',          -- Contraseña del usuario de replicación
    MASTER_LOG_FILE = 'mysql-bin.000003',      -- Archivo de registro binario actual en el maestro
    MASTER_LOG_POS 	= 754;                     -- Posición en el archivo binario del maestro

-- Iniciar nuevamente el proceso de replicación después de la reconfiguración.
START SLAVE;

-- ##################################################################################################
-- VERSIONES DE MYSQL SUPERIOR A 8.0.22
-- ##################################################################################################

-- Si estás utilizando MySQL 8.0.22 o superior, es necesario habilitar la compatibilidad con versiones anteriores.
SET GLOBAL show_compatibility_56 = ON;

-- Detener el proceso de replicación en caso de que sea necesario realizar ajustes.
STOP REPLICA;

-- Reiniciar la configuración del esclavo para limpiar cualquier configuración previa.
RESET REPLICA ALL;

-- Reconfigurar el esclavo con nuevos valores (si es necesario).
CHANGE REPLICATION SOURCE TO
    SOURCE_HOST 	= '10.0.0.2',
    SOURCE_USER 	= 'replicator',
    SOURCE_PASSWORD = 'Centromedico@123',
    SOURCE_LOG_FILE = 'mysql-bin.000006',
    SOURCE_LOG_POS 	= 10580;

-- Iniciar nuevamente el proceso de replicación después de la reconfiguración.
START REPLICA;

-- Mostrar el estado del esclavo para verificar que la replicación esté funcionando correctamente.
SHOW REPLICA STATUS;

-- ##################################################################################################
-- INFORMACIÓN ADICIONAL PARA LA VERIFICACIÓN
-- ##################################################################################################

-- Verificar la versión del servidor MySQL para asegurarse de que sea compatible con la replicación configurada.
SELECT @@version;

-- Mostrar el UUID del servidor para asegurarse de que no esté duplicado en otra máquina.
-- El UUID debe ser único para cada servidor en la replicación.
SHOW VARIABLES LIKE 'server_uuid';

-- ##################################################################################################
-- CREACIÓN DE UNA VISTA PARA CONSULTAS ESPECÍFICAS
-- ##################################################################################################

-- Cambiar al esquema de la base de datos para trabajar con las tablas replicadas.
USE GestionHospitalaria;

-- Crear una vista para filtrar las consultas médicas realizadas en Guayaquil.
-- Esto permite realizar consultas específicas sobre los datos replicados.
CREATE VIEW ConsultasGUAYAQUIL AS
SELECT * 
FROM GestionHospitalaria.Consultas C, GestionHospitalaria.Medicos M, GestionHospitalaria.CentroMedico CM
WHERE C.MedicoID = M.MedicoID
AND M.CentroID = CM.CentroID
AND CM.CentroMedico = 'Centro Médico Guayaquil';

-- ##################################################################################################
-- FIN DEL SCRIPT
-- ##################################################################################################

-- Esquemas de replicación en Google Cloud con MySQL y PostgreSQL

-- ===========================================
-- 1. Replicación Activa/Pasiva (Alta disponibilidad)
-- ===========================================
-- En MySQL: Master-Slave (Primario-Secundario)
-- El nodo primario acepta escrituras, el secundario solo lecturas y actúa como respaldo.
-- En PostgreSQL: Streaming Replication
-- El primario envía los WAL logs al secundario, que los aplica en tiempo real.

-- ===========================================
-- 2. Replicación Instantánea (Snapshot)
-- ===========================================
-- MySQL: Mediante mysqldump y restauración periódica en el secundario (no es en tiempo real, útil para datos que cambian poco).
-- PostgreSQL: Usando pg_dump y restauración programada, o herramientas como Bucardo para snapshots programados.

-- ===========================================
-- 3. Replicación Transaccional
-- ===========================================
-- MySQL: Replicación binaria (binlog), cada transacción se replica casi en tiempo real al slave.
-- PostgreSQL: Streaming Replication + logical replication para replicar cambios a nivel de transacción.

-- ===========================================
-- 4. Replicación Merge
-- ===========================================
-- MySQL: No soporta merge nativo, pero se puede lograr con soluciones externas (como Galera Cluster para multi-master).
-- PostgreSQL: Bucardo permite replicación multi-master y merge de cambios, resolviendo conflictos.

-- ===========================================
-- Ejemplos en diagramas ASCII de replicación
-- ===========================================

-- 1. Replicación Activa/Pasiva (Master-Slave)
-- MySQL y PostgreSQL (Streaming Replication)
--
--   +-----------+           +-----------+
--   |  Master   |  --->     |  Slave    |
--   +-----------+           +-----------+
--        |                       |
--   Escrituras y lecturas   Solo lecturas
--
-- Cambios en el master se replican automáticamente al slave.

-- 2. Replicación Instantánea (Snapshot)
--
--   +-----------+   (mysqldump/pg_dump)   +-----------+
--   |  Primario |  ====================>  |  Secundario|
--   +-----------+                        +-----------+
--   Dump/restore periódico, no en tiempo real.

-- 3. Replicación Transaccional (Binlog/Logical)
--
--   +-----------+   (binlog/WAL)   +-----------+
--   |  Master   |  ------------->  |  Slave    |
--   +-----------+                 +-----------+
--   Cada transacción se replica casi en tiempo real.

-- 4. Replicación Merge (Multi-master)
--
--   +-----------+ <----------> +-----------+
--   |  Nodo 1   | <----------> |  Nodo 2   |
--   +-----------+ <----------> +-----------+
--   Cambios pueden ocurrir en ambos nodos y se fusionan (requiere solución externa como Galera o Bucardo).

-- ===========================================
-- Notas
-- ===========================================
-- - Elige el esquema según tus necesidades: alta disponibilidad, escalabilidad o tolerancia a fallos.
-- - Siempre realiza respaldos antes de configurar replicación.
-- - Monitorea el estado de la replicación y realiza pruebas periódicas.