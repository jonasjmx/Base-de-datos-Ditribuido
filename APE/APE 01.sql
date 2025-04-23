-- Codificacion Para la isntalacion de Ubuntu Server 22(Maquina virtual) y SQL Server en Ubuntu, Creando la conexion para Sql Server en Windows(Maquina Fisica)

-- 1. Instalar Ubuntu Server 22 en una maquina virtual (VirtualBox o VMware).
--    - Descargar la imagen ISO de Ubuntu Server 22 desde el sitio oficial.
--    - Crear una nueva maquina virtual en VirtualBox o VMware.
--    - Asignar recursos (CPU, RAM, Disco) a la maquina virtual.
--    - Montar la imagen ISO de Ubuntu Server 22 en la unidad de CD/DVD de la maquina virtual.
--    - Iniciar la maquina virtual y seguir las instrucciones de instalacion de Ubuntu Server 22.
--    - Durante la instalacion, seleccionar las opciones de red y configuracion de usuario segun sea necesario.
--    - Instalar el servidor SSH para poder acceder a la maquina virtual desde Windows.
--    - Configurar la red de la maquina virtual para que tenga acceso a la red local (puente o NAT).

-- 2. Instalar SQL Server en Ubuntu Server 22 siguiendo la documentacion oficial de Microsoft.
--    - Abrir una terminal en la maquina virtual de Ubuntu Server 22.
---   - Comandos para instalar SQL Server:
        sudo apt-get update
        sudo apt-get install -y curl apt-transport-https ca-certificates gnupg2 software-properties-common
        curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
        sudo apt-get update
        sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev
        sudo apt-get install -y mssql-server
        sudo /opt/mssql/bin/sqlservr-setup
--    - Durante la instalacion, se te pedira que configures la contraseña del usuario 'sa' (administrador de SQL Server).
--    - Asegurarse de que el servicio de SQL Server se inicie automaticamente al arrancar la maquina virtual.
        sudo systemctl enable mssql-server
        sudo systemctl start mssql-server
--    - Verificar que SQL Server esta en funcionamiento:
        systemctl status mssql-server
--    - Instalar las herramientas de linea de comandos de SQL Server:
        sudo apt-get install -y mssql-tools
--    - Agregar las herramientas de SQL Server al PATH:
        echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
        source ~/.bashrc
--    - Probar la conexion a SQL Server desde la terminal de Ubuntu:
        sqlcmd -S localhost -U SA -P 'tu_contraseña'
--    - Si la conexion es exitosa, deberias ver el prompt de SQL Server.
--    - Crear una base de datos de ejemplo

-- 3. Configurar Ufw de la maquina virtual para que tenga acceso al puerto 1433 (puerto por defecto de SQL Server).
--    - Abrir el puerto 1433 en el firewall de Ubuntu Server:
        sudo ufw allow 1433/tcp
--    - Habilitar el firewall:
        sudo ufw enable
--    - Verificar el estado del firewall y las reglas configuradas:
        sudo ufw status verbose
--    - Asegurarse de que el firewall no bloquee el acceso al puerto 22 (SSH) para poder acceder a la maquina virtual desde Windows.
--    - Si es necesario, abrir el puerto 22 en el firewall:
        sudo ufw allow 22/tcp
--    - Verificar que el puerto 22 esta abierto:
        sudo ufw status verbose
--    - Probar la conexion a SQL Server desde la terminal de Ubuntu:
        sqlcmd -S localhost -U SA -P 'tu_contraseña'
--    - Si la conexion es exitosa, deberias ver el prompt de SQL Server.

-- 5. Crear una base de datos de ejemplo en SQL Server.

        -- Crear la base de datos
        CREATE DATABASE flotilla;

        -- Crear la tabla Conductor
        CREATE TABLE Conductor (
            nombre VARCHAR(80) NOT NULL,
            licenciaVigente BOOLEAN NOT NULL,
            telefono CHAR(15) NOT NULL,
            curp VARCHAR(20) NOT NULL,
            disponibilidad BOOLEAN NOT NULL DEFAULT 1,
            PRIMARY KEY (curp)
        );

        -- Crear la tabla Combustible
        CREATE TABLE Combustible (
            idCombustible INT NOT NULL,
            tipo VARCHAR(80) NOT NULL,
            precioPorLitro FLOAT NOT NULL,
            PRIMARY KEY (idCombustible)
        );

        -- Crear la tabla Vehiculo
        CREATE TABLE Vehiculo (
            modelo VARCHAR(80) NOT NULL,
            placa VARCHAR(15) NOT NULL,
            ano YEAR NOT NULL,
            disponibilidad BOOLEAN NOT NULL DEFAULT 1,
            marca VARCHAR(80) NOT NULL,
            capacidadCombustible FLOAT NOT NULL,
            seguro VARCHAR(80) NOT NULL,
            idCombustible INT NOT NULL,
            PRIMARY KEY (placa),
            FOREIGN KEY (idCombustible) REFERENCES Combustible (idCombustible)
        );

        -- Crear la tabla Mantenimiento
        CREATE TABLE Mantenimiento (
            fecha DATE NOT NULL,
            costo FLOAT NOT NULL,
            idMantenimiento INT NOT NULL,
            descripcion VARCHAR(100) NOT NULL,
            placa VARCHAR(15) NOT NULL,
            PRIMARY KEY (idMantenimiento),
            FOREIGN KEY (placa) REFERENCES Vehiculo (placa)
        );

        -- Crear la tabla Ruta
        CREATE TABLE Ruta (
            kilometraje FLOAT NOT NULL,
            destino VARCHAR(80) NOT NULL,
            origen VARCHAR(80) NOT NULL,
            fecha DATE NOT NULL,
            idRuta INT NOT NULL,
            horaSalida TIME NOT NULL,
            horaLlegada TIME NOT NULL,
            placa VARCHAR(15) NOT NULL,
            curp VARCHAR(20) NOT NULL,
            PRIMARY KEY (idRuta),
            FOREIGN KEY (placa) REFERENCES Vehiculo (placa),
            FOREIGN KEY (curp) REFERENCES Conductor (curp)
        );

-- 7. Insertar datos de ejemplo en la tabla.
        -- Insertar datos en la tabla Combustible
        INSERT INTO Combustible VALUES 
        (1, 'Magna', 24.79),
        (2, 'Premium', 25.55),
        (3, 'Diesel', 26.80);

        -- Insertar datos en la tabla Conductor
        INSERT INTO Conductor VALUES 
        ('Alejandro Gonzalez Cruz', 1, '5546986133', 'GOCA040227HDFMZSA1', 1),
        ('Ruben Ruiz Diaz', 1, '5546236512', 'RUDR040227HDFMZSA1', 1),
        ('Luis Torres Lopez', 0, '5598683214', 'TOLL040227HDFMZSA1', 1),
        ('Antonio Cruz Rosas', 1, '5590436712', 'CRRA040227HDFMZSA1', 1),
        ('Pedro Fuentes Herrera', 0, '5553681243', 'FUHP040227HDFMZSA1', 1);

        -- Insertar datos en la tabla Vehiculo
        INSERT INTO Vehiculo VALUES 
        ('Rifter', 'AS12-AS3', 2020, 1, 'Peugeot', 20, 'Qualitas', 1),
        ('Saveiro', 'FDS32-12', 2021, 1, 'Volkswagen', 18, 'Qualitas', 2),
        ('Oroch', 'FD3-45G', 2020, 1, 'Renault', 16, 'GNP', 3),
        ('RAM 1200', 'FDL-42K', 2023, 1, 'RAM', 14, 'GNP', 1),
        ('Rifter', 'SDF-12', 2024, 1, 'Peugeot', 15, 'Qualitas', 2);

        -- Insertar datos en la tabla Ruta
        INSERT INTO Ruta VALUES 
        (200, 'Cuautitlan', 'Toreo', '2025-02-07', 10, '17:55:59', '21:55:59', 'AS12-AS3', 'GOCA040227HDFMZSA1'),
        (100, 'Coapa', 'Toreo', '2025-02-06', 2, '14:31:45', '15:55:59', 'FDS32-12', 'RUDR040227HDFMZSA1'),
        (40, 'Santa Fe', 'Toreo', '2025-02-06', 3, '13:55:12', '14:55:59', 'FD3-45G', 'TOLL040227HDFMZSA1'),
        (50, 'Lomas Verdes', 'San Mateo', '2025-02-08', 4, '18:51:39', '19:55:59', 'FDL-42K', 'CRRA040227HDFMZSA1'),
        (60, 'Satelite', 'San Mateo', '2025-02-08', 5, '19:52:13', '20:55:59', 'SDF-12', 'FUHP040227HDFMZSA1');

        -- Insertar datos en la tabla Mantenimiento
        INSERT INTO Mantenimiento VALUES 
        ('2024-10-12', 5000, 1, 'Servicio completo', 'AS12-AS3'),
        ('2024-12-20', 3000, 2, 'Servicio parcial', 'FDS32-12'),
        ('2025-01-10', 4000, 3, 'Servicio completo', 'FD3-45G'),
        ('2024-08-29', 3500, 4, 'Servicio parcial', 'FDL-42K'),
        ('2025-02-01', 4500, 5, 'Servicio completo', 'SDF-12');

-- 8. Crear un usuario de SQL Server con permisos para acceder a la base de datos.
        -- Crear un nuevo usuario
        CREATE LOGIN nuevo_usuario WITH PASSWORD
    = 'tu_contraseña';
        -- Crear un nuevo usuario en la base de datos
        CREATE USER nuevo_usuario FOR LOGIN nuevo_usuario;
        -- Asignar permisos al nuevo usuario
        GRANT SELECT, INSERT, UPDATE, DELETE ON flotilla TO nuevo_usuario;
        -- Probar la conexion a SQL Server desde la terminal de Ubuntu:
        sqlcmd -S localhost -U nuevo_usuario -P 'tu_contraseña'
        -- Si la conexion es exitosa, deberias ver el prompt de SQL Server.

-- 9. Probar la conexion desde Windows a SQL Server en Ubuntu Server 22.
--    - Descargar e instalar SQL Server Management Studio (SSMS) en Windows.
--    - Abrir SQL Server Management Studio (SSMS) en Windows.
--    - En la ventana de conexion, ingresar la direccion IP de la maquina virtual de Ubuntu Server 22 (puedes obtenerla con el comando 'ip addr' en Ubuntu).
--    - Ingresar el nombre de usuario y la contraseña del usuario creado en SQL Server.
--    - Hacer clic en 'Connect' para conectarse a SQL Server en Ubuntu Server 22.
--    - Si la conexion es exitosa, deberias ver la base de datos 'flotilla' en el panel de exploracion de SSMS.

-- 10. Realizar consultas de ejemplo desde Windows a SQL Server en Ubuntu Server 22.
--     - Abrir una nueva consulta en SQL Server Management Studio (SSMS).
--     - Realizar consultas de ejemplo:
        -- Consultar todos los conductores
        SELECT * FROM Conductor;
        -- Consultar todos los vehiculos
        SELECT * FROM Vehiculo;
        -- Consultar todas las rutas
        SELECT * FROM Ruta;
        -- Consultar todos los mantenimientos
        SELECT * FROM Mantenimiento;
        -- Consultar todos los combustibles
        SELECT * FROM Combustible;
