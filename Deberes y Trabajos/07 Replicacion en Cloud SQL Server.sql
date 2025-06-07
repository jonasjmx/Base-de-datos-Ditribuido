-- ===========================================
-- 1. Instalación de SQL Server en Ubuntu 25.04
-- ===========================================

-- Agregar la clave y el repositorio de Microsoft
sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/25.04/prod $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mssql-release.list

-- Actualizar repositorios e instalar SQL Server
sudo apt-get update
sudo apt-get install -y mssql-server

-- Configurar SQL Server (establecer contraseña de SA, edición, etc.)
sudo /opt/mssql/bin/mssql-conf setup

-- Verificar estado del servicio
systemctl status mssql-server

-- Instalar herramientas de línea de comandos
sudo apt-get install -y mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

-- ===========================================
-- 2. Configuración de red y firewall
-- ===========================================

-- En Google Cloud, crea una regla de firewall para permitir el puerto 1433 (SQL Server) y 5022 (Always On)
-- Origen: 0.0.0.0/0  Puertos: 1433,5022  Protocolo: tcp

-- ===========================================
-- PASOS PREVIOS PARA TODA REPLICACIÓN
-- ===========================================

-- 1. Instala SQL Server en ambas VMs (ver sección inicial del archivo).
-- 2. Configura los puertos 1433 y 5022 en el firewall de Google Cloud.
-- 3. Ambas VMs deben resuelverse por nombre o IP y el usuario SA tengan la misma contraseña.
-- 4. Crea la base de datos y ponla en modo FULL RECOVERY si aplica:
CREATE DATABASE Medicity;
ALTER DATABASE Medicity SET RECOVERY FULL;
GO

-- ===========================================
-- 1. Alta disponibilidad (Activa/Pasiva) - Always On Availability Groups
-- ===========================================
-- Uso: Alta disponibilidad, failover automático, cero pérdida de datos (modo síncrono).

-- En cada nodo (primaria y secundaria), crea el endpoint:
CREATE ENDPOINT [HADR]
  STATE = STARTED
  AS TCP (LISTENER_PORT = 5022)
  FOR DATA_MIRRORING (
    ROLE = ALL,
    AUTHENTICATION = WINDOWS NEGOTIATE,
    ENCRYPTION = REQUIRED ALGORITHM AES
  );
GO

-- En la primaria, crea el Availability Group:
CREATE AVAILABILITY GROUP [MedicityAG]
  WITH (CLUSTER_TYPE = NONE)
  FOR DATABASE Medicity
  REPLICA ON
    N'sql-primary' WITH (
      ENDPOINT_URL = N'tcp://sql-primary:5022',
      FAILOVER_MODE = AUTOMATIC,
      AVAILABILITY_MODE = SYNCHRONOUS_COMMIT
    ),
    N'sql-secondary' WITH (
      ENDPOINT_URL = N'tcp://sql-secondary:5022',
      FAILOVER_MODE = AUTOMATIC,
      AVAILABILITY_MODE = SYNCHRONOUS_COMMIT
    );
GO

ALTER AVAILABILITY GROUP [MedicityAG] GRANT CREATE ANY DATABASE;
GO

-- En la secundaria, únela al Availability Group:
ALTER AVAILABILITY GROUP [MedicityAG]
  JOIN WITH (CLUSTER_TYPE = NONE);
GO

-- ===========================================
-- 2. Replicación Instantánea (Snapshot)
-- ===========================================
-- Uso: Datos que cambian poco, coherencia puntual, fácil de configurar.

-- En la primaria, habilita la publicación snapshot:
USE Medicity;
EXEC sp_replicationdboption @dbname = N'Medicity', @optname = N'publish', @value = N'true';
EXEC sp_addpublication @publication = N'Medicity_Snapshot', @snapshot_in_defaultfolder = 1, @type = N'snapshot';
EXEC sp_addarticle @publication = N'Medicity_Snapshot', @article = N'TablaClinica', @source_owner = N'dbo', @source_object = N'TablaClinica';
EXEC sp_startpublication_snapshot @publication = N'Medicity_Snapshot';
GO

-- En la secundaria, crea la suscripción:
EXEC sp_addsubscription
  @publication = N'Medicity_Snapshot',
  @subscriber = N'sql-secondary',
  @destination_db = N'Medicity',
  @subscription_type = N'pull',
  @sync_type = N'automatic';
GO

EXEC sp_startpullsubscription_agent @publication = N'Medicity_Snapshot', @subscriber = N'sql-secondary', @subscriber_db = N'Medicity';
GO

-- ===========================================
-- 3. Replicación Transaccional
-- ===========================================
-- Uso: Alta tasa de cambios, baja latencia, solo escritura en primaria.

-- En la primaria, crea la publicación transaccional:
EXEC sp_replicationdboption @dbname = N'Medicity', @optname = N'publish', @value = N'true';
EXEC sp_addpublication @publication = N'Medicity_Trans', @publication_type = N'transactional';
EXEC sp_addarticle @publication = N'Medicity_Trans', @article = N'TablaPacientes', @source_object = N'TablaPacientes', @type = N'logbased';
GO

-- En la secundaria, crea la suscripción:
EXEC sp_addsubscription @publication = N'Medicity_Trans',
  @subscriber = N'sql-secondary',
  @destination_db = N'Medicity',
  @subscription_type = N'push';
GO

EXEC sp_startpushsubscription_agent @publication = N'Medicity_Trans', @subscriber = N'sql-secondary', @subscriber_db = N'Medicity';
GO

-- ===========================================
-- 4. Replicación Merge
-- ===========================================
-- Uso: Escritura en ambas réplicas, fusión de cambios, entornos desconectados.

-- En la primaria, crea la publicación merge:
EXEC sp_replicationdboption @dbname = N'Medicity', @optname = N'publish', @value = N'true';
EXEC sp_addpublication @publication = N'Medicity_Merge', @publication_type = N'merge';
EXEC sp_addmergearticle @publication = N'Medicity_Merge', @article = N'TablaCitas', @source_object = N'TablaCitas';
GO

-- En la secundaria, crea la suscripción merge:
EXEC sp_addmergesubscription @publication = N'Medicity_Merge',
  @subscriber = N'sql-secondary',
  @subscriber_db = N'Medicity';
GO

EXEC sp_startmergesync @publication = N'Medicity_Merge', @subscriber = N'sql-secondary', @subscriber_db = N'Medicity';
GO

-- ===========================================
-- 5. Replicación Síncrona (Solo lectura en secundarias)
-- ===========================================
-- Uso: Consultas de solo lectura en réplicas secundarias (parte de Always On).

ALTER AVAILABILITY GROUP [MedicityAG]
  MODIFY REPLICA ON N'sql-secondary'
    WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
GO

-- ===========================================
-- 6. Verificación y pruebas (para cualquier modalidad)
-- ===========================================

-- Verifica el estado del grupo de disponibilidad:
SELECT * FROM sys.availability_groups;
SELECT * FROM sys.availability_replicas;
SELECT * FROM sys.dm_hadr_availability_replica_states;

-- Verifica el estado de la replicación:
-- Para snapshot/transaccional/merge:
EXEC sp_helppublication;
EXEC sp_helpsubscription;
GO

-- ===========================================
-- Notas finales:
-- - Elige el tipo de replicación según tus necesidades de negocio.
-- - Siempre realiza backups antes de configurar replicación.
-- - Consulta la documentación oficial de SQL Server para detalles avanzados.