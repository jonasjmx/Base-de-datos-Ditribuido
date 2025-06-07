-- ===========================================
-- Instalación y configuración de MySQL en Ubuntu 25.04 (Google Cloud)
-- ===========================================

-- 1. Actualiza los repositorios del sistema
sudo apt update

-- 2. Instala los paquetes necesarios para trabajar con repositorios HTTPS
sudo apt install wget lsb-release gnupg -y

-- 3. Descarga el repositorio oficial de MySQL
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb

-- 4. Instala el repositorio descargado (elige la versión de MySQL en el menú interactivo)
sudo dpkg -i mysql-apt-config_0.8.29-1_all.deb

-- 5. Vuelve a actualizar los repositorios (ahora con los de MySQL)
sudo apt update

-- 6. Instala MySQL Server
sudo apt install mysql-server -y

-- 7. Verifica que el servicio esté activo
sudo systemctl status mysql
-- Si usas una versión antigua de Debian/Ubuntu:
-- sudo service mysql status

-- 8. Accede a la consola de MySQL como root
sudo mysql -u root -p

-- ===========================================
-- Configuración básica de seguridad (recomendado)
-- ===========================================
-- Ejecuta el siguiente script para fortalecer la seguridad de tu instalación:
sudo mysql_secure_installation
-- (Sigue las instrucciones para establecer contraseña, eliminar usuarios anónimos, deshabilitar acceso remoto root, etc.)

-- ===========================================
-- Configuración de red y firewall en Google Cloud
-- ===========================================
-- - Abre el puerto 3306 (MySQL) en el firewall de Google Cloud para permitir conexiones externas si es necesario.
-- - Limita el acceso solo a las IPs necesarias por seguridad.

-- ===========================================
-- Preparación de la base de datos y usuario
-- ===========================================
-- Una vez dentro de la consola de MySQL:
-- Crea una base de datos y un usuario con permisos remotos (ajusta los valores según tu caso):

CREATE DATABASE `centro-medico2` 
CREATE USER 'admin'@'%' IDENTIFIED BY 'admin123'; 
GRANT ALL PRIVILEGES ON `centro-medico2`.* TO 'admin'@'%'; 
FLUSH PRIVILEGES;

sudo systemctl restart mysql 

-- ===========================================
BASE DE DATOS 
-- ===========================================
USE `centro-medico2`; 

-- Tabla de usuarios para inicio de sesión 
CREATE TABLE UsuariosCentro ( 
    UsuarioID INT PRIMARY KEY AUTO_INCREMENT, 
    CentroID INT NOT NULL, 
    Email VARCHAR(75) NOT NULL UNIQUE, 
    Contrasena VARCHAR(75) NOT NULL, 
    FOREIGN KEY (CentroID) REFERENCES CentrosMedicos(CentroID) 

); 

-- Tabla de centros médicos 
CREATE TABLE CentrosMedicos ( 
    CentroID INT PRIMARY KEY AUTO_INCREMENT, 
    Nombre VARCHAR(100) NOT NULL, 
    Ciudad VARCHAR(100) NOT NULL, 
    Direccion VARCHAR(200), 
    Telefono VARCHAR(20) 
); 

-- Tabla de especialidades 
CREATE TABLE Especialidades ( 
    EspecialidadID INT PRIMARY KEY AUTO_INCREMENT, 
    Nombre VARCHAR(100) NOT NULL, 
    Descripcion VARCHAR(255) 
); 

-- Tabla de médicos (debe ir antes por las claves foráneas) 
CREATE TABLE Medicos ( 
    MedicoID INT PRIMARY KEY AUTO_INCREMENT, 
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
    AsignacionID INT PRIMARY KEY AUTO_INCREMENT, 
    MedicoID INT NOT NULL, 
    EspecialidadID INT NOT NULL, 
    FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID), 
    FOREIGN KEY (EspecialidadID) REFERENCES Especialidades(EspecialidadID) 
); 

-- Tabla de empleados 
CREATE TABLE Empleados ( 
    EmpleadoID INT PRIMARY KEY AUTO_INCREMENT, 
    Nombre VARCHAR(100) NOT NULL, 
    Apellido VARCHAR(100) NOT NULL, 
    Cargo VARCHAR(100), 
    Email VARCHAR(100), 
    Telefono VARCHAR(20) 
); 

-- Tabla de clientes 
CREATE TABLE Clientes ( 
    ClienteID INT PRIMARY KEY AUTO_INCREMENT, 
    Nombre VARCHAR(100) NOT NULL, 
    Apellido VARCHAR(100) NOT NULL, 
    Correo VARCHAR(100), 
    Telefono VARCHAR(20) 
); 

-- Tabla de consultas 
CREATE TABLE Consultas ( 
    ConsultaID INT PRIMARY KEY AUTO_INCREMENT, 
    MedicoID INT NOT NULL, 
    ClienteID INT NOT NULL, 
    FechaConsulta DATETIME NOT NULL, 
    Diagnostico VARCHAR(255), 
    Tratamiento VARCHAR(255), 
    FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID), 
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID) 
); 

-- ===========================================
-- Permitir conexiones remotas (opcional)
-- ===========================================
-- Edita el archivo de configuración de MySQL para aceptar conexiones externas:
-- do nano /etc/mysql/mysql.conf.d/mysqld.cnf
-- Busca la línea:
-- bind-address = 127.0.0.1
-- y cámbiala por:
-- bind-address = 0.0.0.0
-- Guarda y cierra el archivo.

-- Reinicia el servicio para aplicar cambios:
sudo systemctl restart mysql

-- ===========================================
-- Verificación de acceso remoto
-- ===========================================
-- Desde otra máquina, prueba conectarte:
-- mysql -h <IP-EXTERNA-VM> -u usuario -p

-- ===========================================
-- PREPARACIÓN Y CONFIGURACIÓN DE REPLICACIÓN MySQL ENTRE VMs (MASTER-SLAVE)
-- ===========================================
-- Esta guía está pensada para MySQL 8.x en Google Cloud, pero aplica a la mayoría de entornos Linux.
-- Asegúrate de tener los puertos abiertos y la seguridad adecuada antes de exponer servicios a Internet.

-- 1. CONFIGURACIÓN DEL SERVIDOR MASTER (PRIMARIO)
-- -------------------------------------------
-- Edita el archivo de configuración principal de MySQL:
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
-- En la sección [mysqld], agrega o modifica:
server-id = 1                # Identificador único para el master (debe ser diferente en cada servidor)
log_bin = /var/log/mysql/mysql-bin.log   # Habilita el log binario (requerido para replicación)
# binlog_do_db = centro-medico2         # (Opcional) Limita la replicación a una base de datos específica
-- Guarda y cierra el archivo.

-- Reinicia el servicio para aplicar los cambios:
sudo systemctl restart mysql

-- 2. CREAR USUARIO DE REPLICACIÓN EN EL MASTER
-- -------------------------------------------
-- En la consola de MySQL (como root):
CREATE USER 'replicador'@'%' IDENTIFIED BY 'tu_password_replicacion';
GRANT REPLICATION SLAVE ON *.* TO 'replicador'@'%';
FLUSH PRIVILEGES;

-- 3. BLOQUEA LAS TABLAS Y OBTÉN LA POSICIÓN DEL LOG BINARIO
-- -------------------------------------------
-- Esto asegura que el dump esté sincronizado con el log binario.
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
-- Anota los valores de File y Position. No cierres la sesión hasta terminar el dump.

-- 4. REALIZA UN DUMP DE LA BASE DE DATOS
-- -------------------------------------------
-- En otra terminal, ejecuta:
sudo mysqldump -u root -p --all-databases --master-data > respaldo.sql
-- Cuando termine, puedes liberar el lock en la sesión anterior:
UNLOCK TABLES;

-- 5. COPIA EL RESPALDO AL SERVIDOR SLAVE
-- -------------------------------------------
-- Usa scp o similar:
scp respaldo.sql usuario@ip_slave:/ruta/destino/

-- 6. CONFIGURACIÓN DEL SERVIDOR SLAVE (SECUNDARIO)
-- -------------------------------------------
-- Edita el archivo de configuración de MySQL:
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
-- En la sección [mysqld]:
server-id = 2                # Debe ser diferente al del master
# replicate-do-db = centro-medico2      # (Opcional) Limita la replicación a una base de datos
-- Guarda y cierra el archivo.

-- Reinicia el servicio en el slave:
sudo systemctl restart mysql

-- 7. RESTAURA EL RESPALDO EN EL SLAVE
-- -------------------------------------------
sudo mysql -u root -p < respaldo.sql

-- 8. CONFIGURA LA CONEXIÓN DE REPLICACIÓN EN EL SLAVE
-- -------------------------------------------
-- En la consola de MySQL del slave, usa los datos anotados de SHOW MASTER STATUS:
CHANGE MASTER TO
  MASTER_HOST='ip_master',
  MASTER_USER='replicador',
  MASTER_PASSWORD='tu_password_replicacion',
  MASTER_LOG_FILE='archivo_binario',
  MASTER_LOG_POS=posicion;
START SLAVE;

-- 9. VERIFICA EL ESTADO DE LA REPLICACIÓN
-- -------------------------------------------
SHOW SLAVE STATUS\G
-- Busca que 'Slave_IO_Running: Yes' y 'Slave_SQL_Running: Yes'.
-- Si hay errores, revisa los mensajes en Last_IO_Error y Last_SQL_Error.

-- ===========================================
-- RECOMENDACIONES DE SEGURIDAD Y BUENAS PRÁCTICAS
-- ===========================================
-- - Usa contraseñas seguras para el usuario de replicación.
-- - Limita el acceso del usuario de replicación a la IP del slave si es posible.
-- - Asegúrate de que el puerto 3306 esté abierto solo entre las VMs necesarias.
-- - Realiza pruebas de inserción en el master y verifica que se repliquen en el slave.
-- - Considera cifrar el tráfico de replicación si es sensible.
-- - Realiza backups periódicos y monitorea el estado de la replicación.