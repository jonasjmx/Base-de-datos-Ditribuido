/*
-- Descripción:
-- Este script define el esquema de base de datos para un sistema de gestión de una cooperativa de vehículos. 
-- Incluye tablas para gestionar usuarios, conductores, vehículos, licencias, proveedores, mantenimientos, 
-- consumo de combustible, documentos de vehículos, rutas, asignaciones de conductores, viajes, incidentes y registros de auditoría.

-- Tablas:
-- 1. Usuarios: Almacena información de los usuarios, roles y estado de las cuentas.
-- 2. Conductores: Almacena detalles de los conductores, incluyendo licencias e información de contacto.
-- 3. Vehiculos: Almacena detalles de los vehículos, incluyendo especificaciones y estado.
-- 4. LicenciasConducir: Almacena detalles de las licencias de los conductores y su validez.
-- 5. Proveedores: Almacena información de proveedores para mantenimiento y servicios de vehículos.
-- 6. Mantenimientos: Registra los mantenimientos de los vehículos, incluyendo tipo y costo.
-- 7. Estaciones: Almacena detalles de las estaciones de combustible.
-- 8. ConsumoCombustible: Registra el consumo de combustible de los vehículos, incluyendo costo y kilometraje.
-- 9. DocumentosVehiculos: Registra documentos relacionados con los vehículos, como seguros y tenencias.
-- 10. Rutas: Almacena detalles de las rutas, incluyendo origen, destino y distancia.
-- 11. AsignacionesConductores: Registra las asignaciones de conductores a vehículos.
-- 12. Viajes: Registra detalles de los viajes, incluyendo rutas, kilometraje y estado del viaje.
-- 13. Incidentes: Registra incidentes relacionados con los vehículos, como accidentes o fallas mecánicas.

-- Características Adicionales:
-- - Restricciones: Incluye claves primarias, claves foráneas, restricciones únicas y restricciones CHECK para garantizar la integridad de los datos.
-- - Valores Predeterminados: Proporciona valores predeterminados para ciertos campos, como fechas y estados.

-- Notas:
-- - El esquema asegura la consistencia de los datos y aplica reglas de negocio mediante restricciones y relaciones.
*/
9
-- Base de datos para Oracle express edition 10g --

-- BD COOPERATIVA_AUTOS --
CONNECT SYSTEM;
CREATE USER COOPERATIVA_AUTOS IDENTIFIED BY COOPERATIVA;
GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE, CREATE ANY VIEW TO COOPERATIVA_AUTOS;
DISCONNECT;

-- administrador del sistema (CUANDO YA HAYA CREADO LA BD) --
CONNECT SYSTEM;
CREATE USER PABLO IDENTIFIED BY PABLO;
GRANT CREATE SESSION TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.USUARIOS TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.CONDUCTORES TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.VEHICULOS TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.ASIGNACIONESCONDUCTORES TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.LICENCIASCONDUCIR TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.PROVEEDORES TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.MANTENIMIENTOS TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.ESTACIONES TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.CONSUMOCOMBUSTIBLE TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.DOCUMENTOSVEHICULOS TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.RUTAS TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.VIAJES TO PABLO;
GRANT SELECT, INSERT, UPDATE, DELETE ON COOPERATIVA_AUTOS.INCIDENTES TO PABLO;
DISCONNECT;

-- Creo las tablas para la BD COOPERATIVA_AUTOS --

CONNECT COOPERATIVA_AUTOS/COOPERATIVA;

CREATE TABLE Usuarios (
    id_usuario NUMBER PRIMARY KEY,
    nombre VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(20) NOT NULL,
    primer_nombre VARCHAR(20) NOT NULL,
    segundo_nombre VARCHAR(20),
    primer_apellido VARCHAR(20) NOT NULL,
    segundo_apellido VARCHAR(20),
    email VARCHAR(40) UNIQUE NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('ADMINISTRADOR', 'SUPERVISOR', 'OPERADOR')),
    fecha_creacion DATE NOT NULL,
    ultima_session DATE,
    estado VARCHAR(20) DEFAULT 'INACTIVO' CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

CREATE SEQUENCE seq_usuarios;

INSERT INTO Usuarios VALUES (seq_usuarios.NEXTVAL,'admin1', 'pass123', 'Pablo', 'Carlos', 'Pérez', 'Gómez', 'admin1@example.com', 'ADMINISTRADOR',TO_DATE('2026-05-15', 'YYYY-MM-DD'), NULL,'ACTIVO');
INSERT INTO Usuarios VALUES (seq_usuarios.NEXTVAL,'supervisor1', 'pass456', 'María', 'Luisa', 'Rodríguez', 'López', 'supervisor1@example.com', 'SUPERVISOR',TO_DATE('2025-12-01', 'YYYY-MM-DD'), NULL,'ACTIVO');
INSERT INTO Usuarios VALUES (seq_usuarios.NEXTVAL,'operador1', 'pass789', 'Luis', 'Fernando', 'Martínez', 'Hernández', 'operador1@example.com', 'OPERADOR',TO_DATE('2024-08-20', 'YYYY-MM-DD'), NULL,'INACTIVO');
INSERT INTO Usuarios VALUES (seq_usuarios.NEXTVAL,'admin2', 'adminpass', 'Ana', 'Sofía', 'García', 'Torres', 'admin2@example.com', 'ADMINISTRADOR',TO_DATE('2027-03-30', 'YYYY-MM-DD'), NULL,'ACTIVO');
INSERT INTO Usuarios VALUES (seq_usuarios.NEXTVAL,'operador2', 'op12345', 'Carlos', 'Eduardo', 'Ramírez', 'Flores', 'operador2@example.com', 'OPERADOR',TO_DATE('2025-06-10', 'YYYY-MM-DD'), NULL,'ACTIVO');

CREATE TABLE Conductores (
    id_conductor NUMBER PRIMARY KEY,
    primer_nombre VARCHAR(20) NOT NULL,
    segundo_nombre VARCHAR(20),
    primer_apellido VARCHAR(20) NOT NULL,
    segundo_apellido VARCHAR(20),
    licencia_conducir VARCHAR(20) UNIQUE NOT NULL,
    vigencia_licencia DATE NOT NULL,
    telefono VARCHAR(10),
    email VARCHAR(40),
    direccion VARCHAR(40),
    fecha_nacimiento DATE,
    estado VARCHAR(15) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'INACTIVO', 'SUSPENDIDO'))
);

CREATE SEQUENCE seq_conductores;

INSERT INTO Conductores VALUES (seq_conductores.NEXTVAL ,'Carlos', 'Andrés', 'Pérez', 'Gómez', 'ABC12345', TO_DATE('2026-05-15', 'YYYY-MM-DD'), '0987654321', 'carlos.perez@example.com', 'Av. Siempre Viva 123', TO_DATE('1985-03-10', 'YYYY-MM-DD'), 'ACTIVO'); 
INSERT INTO Conductores VALUES (seq_conductores.NEXTVAL ,'María', 'Luisa', 'Rodríguez', 'López', 'DEF67890', TO_DATE('2025-12-01', 'YYYY-MM-DD'), '0981234567', 'maria.rodriguez@example.com', 'Calle Falsa 456', TO_DATE('1990-07-25', 'YYYY-MM-DD'), 'ACTIVO'); 
INSERT INTO Conductores VALUES (seq_conductores.NEXTVAL ,'Luis', 'Fernando', 'Martínez', 'Hernández', 'GHI54321', TO_DATE('2024-08-20', 'YYYY-MM-DD'), '0976543210', 'luis.martinez@example.com', 'Av. Central 789', TO_DATE('1988-11-15', 'YYYY-MM-DD'), 'SUSPENDIDO'); 
INSERT INTO Conductores VALUES (seq_conductores.NEXTVAL ,'Ana', 'Sofía', 'García', 'Torres', 'JKL98765', TO_DATE('2027-03-30', 'YYYY-MM-DD'), '0965432109', 'ana.garcia@example.com', 'Calle Norte 321', TO_DATE('1995-02-05', 'YYYY-MM-DD'), 'ACTIVO'); 
INSERT INTO Conductores VALUES (seq_conductores.NEXTVAL ,'Eduardo', 'José', 'Ramírez', 'Flores', 'MNO65432', TO_DATE('2025-06-10', 'YYYY-MM-DD'), '0954321098', 'eduardo.ramirez@example.com', 'Av. Sur 654', TO_DATE('1982-09-18', 'YYYY-MM-DD'), 'INACTIVO');

CREATE TABLE Vehiculos (
    id_vehiculo NUMBER PRIMARY KEY,
    marca VARCHAR(20) NOT NULL,
    modelo VARCHAR(20) NOT NULL,
    anio NUMBER NOT NULL,
    placas VARCHAR(10) UNIQUE NOT NULL,
    num_serie VARCHAR(20) UNIQUE NOT NULL,
    color VARCHAR(20),
    capacidad_pasajeros NUMBER,
    kilometraje_actual NUMBER DEFAULT 0,
    tipo_combustible VARCHAR(10) NOT NULL CHECK (tipo_combustible IN ('DISEL', 'GASOLINA')),
    estado VARCHAR(20) DEFAULT 'DISPONIBLE' CHECK (estado IN ('DISPONIBLE', 'MANTENIMIENTO', 'EN RUTA', 'INACTIVO')),
    fecha_adquirida DATE
);

CREATE SEQUENCE seq_vehiculos;

INSERT INTO Vehiculos VALUES (seq_vehiculos.NEXTVAL,'Toyota', 'Corolla', 2020, 'ABC123', '1HGCM82633A123456', 'Blanco', 5, 25000, 'GASOLINA', 'DISPONIBLE', TO_DATE('2020-03-15', 'YYYY-MM-DD'));
INSERT INTO Vehiculos VALUES (seq_vehiculos.NEXTVAL,'Honda', 'Civic', 2019, 'DEF456', '2HGCM82633A654321', 'Negro', 5, 30000, 'GASOLINA', 'MANTENIMIENTO', TO_DATE('2019-06-20', 'YYYY-MM-DD'));
INSERT INTO Vehiculos VALUES (seq_vehiculos.NEXTVAL,'Ford', 'F-150', 2021, 'GHI789', '3FTFW1ET4EFA12345', 'Rojo', 3, 15000, 'DISEL', 'EN RUTA', TO_DATE('2021-01-10', 'YYYY-MM-DD'));
INSERT INTO Vehiculos VALUES (seq_vehiculos.NEXTVAL,'Chevrolet', 'Spark', 2018, 'JKL012', 'KL8CD6SAXJC123456', 'Azul', 4, 40000, 'GASOLINA', 'DISPONIBLE', TO_DATE('2018-09-05', 'YYYY-MM-DD'));
INSERT INTO Vehiculos VALUES (seq_vehiculos.NEXTVAL,'Nissan', 'Versa', 2022, 'MNO345', '1N4AL3APXJC123456', 'Gris', 5, 5000, 'GASOLINA', 'DISPONIBLE', TO_DATE('2022-07-25', 'YYYY-MM-DD'));

CREATE TABLE AsignacionesConductores (
    id_asignacion NUMBER PRIMARY KEY,
    id_conductor NUMBER NOT NULL,
    id_vehiculo NUMBER NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_finalizacion DATE,
    estado VARCHAR(15) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'TERMINADO')),
    CONSTRAINT fk_asignacion_conductor FOREIGN KEY (id_conductor) REFERENCES Conductores(id_conductor),
    CONSTRAINT fk_asignacion_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES Vehiculos(id_vehiculo),
    CONSTRAINT chk_fecha_asignacion CHECK (fecha_finalizacion > fecha_asignacion)
);

CREATE SEQUENCE seq_asignaciones;

INSERT INTO AsignacionesConductores VALUES (seq_asignaciones.NEXTVAL,1, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-06-01', 'YYYY-MM-DD'), 'TERMINADO');
INSERT INTO AsignacionesConductores VALUES (seq_asignaciones.NEXTVAL,2, 2, TO_DATE('2023-02-15', 'YYYY-MM-DD'), TO_DATE('2023-07-15', 'YYYY-MM-DD'), 'TERMINADO');
INSERT INTO AsignacionesConductores VALUES (seq_asignaciones.NEXTVAL,3, 3, TO_DATE('2023-03-10', 'YYYY-MM-DD'), NULL, 'ACTIVO');
INSERT INTO AsignacionesConductores VALUES (seq_asignaciones.NEXTVAL,4, 4, TO_DATE('2023-04-20', 'YYYY-MM-DD'), NULL, 'ACTIVO');
INSERT INTO AsignacionesConductores VALUES (seq_asignaciones.NEXTVAL,5, 5, TO_DATE('2023-05-05', 'YYYY-MM-DD'), TO_DATE('2023-10-05', 'YYYY-MM-DD'), 'TERMINADO');

CREATE TABLE LicenciasConducir (
    id_licencia NUMBER PRIMARY KEY,
    id_conductor NUMBER NOT NULL,
    tipo_licencia VARCHAR(10) NOT NULL CHECK (tipo_licencia IN ('A', 'B', 'C', 'D', 'E')),
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    pais_emision VARCHAR(20) DEFAULT 'ECUADOR',
    provincia_emision VARCHAR(20),
    estado VARCHAR(15) DEFAULT 'VIGENTE' CHECK (estado IN ('VIGENTE', 'VENCIDA', 'SUSPENDIDA', 'CANCELADA')),
    archivo_digital VARCHAR(50),
    fecha_actualizacion DATE NOT NULL,
    CONSTRAINT chk_fecha_vigencia CHECK (fecha_vencimiento > fecha_emision),
    CONSTRAINT fk_licencia_conductor FOREIGN KEY (id_conductor) REFERENCES Conductores(id_conductor)
);

CREATE SEQUENCE seq_licencias;

INSERT INTO LicenciasConducir VALUES (seq_licencias.NEXTVAL, 1, 'A', TO_DATE('2023-01-15', 'YYYY-MM-DD'), TO_DATE('2028-01-15', 'YYYY-MM-DD'), 'ECUADOR', 'Pichincha', 'VIGENTE', 'licencia1.pdf', TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO LicenciasConducir VALUES (seq_licencias.NEXTVAL, 2, 'B', TO_DATE('2022-06-10', 'YYYY-MM-DD'), TO_DATE('2027-06-10', 'YYYY-MM-DD'), 'ECUADOR', 'Guayas', 'VIGENTE', 'licencia2.pdf', TO_DATE('2022-06-10', 'YYYY-MM-DD'));
INSERT INTO LicenciasConducir VALUES (seq_licencias.NEXTVAL, 3, 'C', TO_DATE('2021-03-20', 'YYYY-MM-DD'), TO_DATE('2026-03-20', 'YYYY-MM-DD'), 'ECUADOR', 'Azuay', 'VIGENTE', 'licencia3.pdf', TO_DATE('2021-03-20', 'YYYY-MM-DD'));
INSERT INTO LicenciasConducir VALUES (seq_licencias.NEXTVAL, 4, 'D', TO_DATE('2020-09-05', 'YYYY-MM-DD'), TO_DATE('2025-09-05', 'YYYY-MM-DD'), 'ECUADOR', 'Manabí', 'VIGENTE', 'licencia4.pdf', TO_DATE('2020-09-05', 'YYYY-MM-DD'));
INSERT INTO LicenciasConducir VALUES (seq_licencias.NEXTVAL, 5, 'E', TO_DATE('2019-12-01', 'YYYY-MM-DD'), TO_DATE('2024-12-01', 'YYYY-MM-DD'), 'ECUADOR', 'Loja', 'VIGENTE', 'licencia5.pdf', TO_DATE('2019-12-01', 'YYYY-MM-DD'));

CREATE TABLE Proveedores (
    id_proveedor NUMBER PRIMARY KEY,
    nombre VARCHAR(40) UNIQUE NOT NULL,
    telefono VARCHAR(10),
    email VARCHAR(40),
    direccion VARCHAR(40),
    servicio VARCHAR(40) NOT NULL
);

CREATE SEQUENCE seq_proveedores;

INSERT INTO Proveedores VALUES (seq_proveedores.NEXTVAL,'Taller Mecánico Los Andes', '0987654321', 'contacto@tallerlosandes.com', 'Av. Siempre Viva 123, Quito', 'Mantenimiento Preventivo');
INSERT INTO Proveedores VALUES (seq_proveedores.NEXTVAL,'Lubricantes y Más', '0998765432', 'info@lubricantesymas.com', 'Calle Falsa 456, Guayaquil', 'Cambio de Aceite');
INSERT INTO Proveedores VALUES (seq_proveedores.NEXTVAL,'Repuestos El Rayo', '0976543210', 'ventas@repuestoselrayo.com', 'Av. Central 789, Cuenca', 'Venta de Repuestos');
INSERT INTO Proveedores VALUES (seq_proveedores.NEXTVAL,'Pintura MaCuin', '0965432109', 'servicio@lagasolina.com', 'Calle Norte 321, Loja', 'Reparacion Pintura');
INSERT INTO Proveedores VALUES (seq_proveedores.NEXTVAL,'Taller Automotriz El Maestro', '0954321098', 'soporte@elmaestro.com', 'Av. Sur 654, Ambato', 'Reparaciones Mecánicas');

CREATE TABLE Mantenimientos (
    id_mantenimiento NUMBER PRIMARY KEY,
    id_vehiculo NUMBER NOT NULL,
    id_proveedor NUMBER NOT NULL,
    fecha DATE NOT NULL,
    descripcion VARCHAR(40),
    tipo_mantenimiento VARCHAR(15) NOT NULL CHECK (tipo_mantenimiento IN ('PREVENTIVO', 'CORRECTIVO', 'PREDICTIVO')),
    costo NUMBER(10,2) CHECK (costo > 0),
    km_mantenimiento NUMBER NOT NULL CHECK (km_mantenimiento > 0),
    estado VARCHAR(15) DEFAULT 'PENDIENTE' CHECK (estado IN ('COMPLETADO', 'PENDIENTE')),
    CONSTRAINT fk_mantenimiento_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES Vehiculos(id_vehiculo),
    CONSTRAINT fk_mantenimiento_proveedor FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

CREATE SEQUENCE seq_mantenimientos;

INSERT INTO Mantenimientos VALUES (seq_mantenimientos.NEXTVAL, 1, 1, TO_DATE('2023-03-15', 'YYYY-MM-DD'), 'Cambio de aceite y filtro', 'PREVENTIVO', 150.00, 25000, 'COMPLETADO');
INSERT INTO Mantenimientos VALUES (seq_mantenimientos.NEXTVAL, 2, 2, TO_DATE('2023-05-10', 'YYYY-MM-DD'), 'Revisión general del motor', 'CORRECTIVO', 500.00, 30000, 'COMPLETADO');
INSERT INTO Mantenimientos VALUES (seq_mantenimientos.NEXTVAL, 3, 3, TO_DATE('2023-07-20', 'YYYY-MM-DD'), 'Cambio de pastillas de freno', 'PREVENTIVO', 200.00, 15000, 'PENDIENTE');
INSERT INTO Mantenimientos VALUES (seq_mantenimientos.NEXTVAL, 4, 4, TO_DATE('2023-09-05', 'YYYY-MM-DD'), 'Diagnóstico de sistema eléctrico', 'PREDICTIVO', 300.00, 40000, 'COMPLETADO');
INSERT INTO Mantenimientos VALUES (seq_mantenimientos.NEXTVAL, 5, 5, TO_DATE('2023-11-25', 'YYYY-MM-DD'), 'Reparación de suspensión', 'CORRECTIVO', 800.00, 5000, 'PENDIENTE');

CREATE TABLE Estaciones (
    id_estacionCombustible NUMBER PRIMARY KEY,
    nombre VARCHAR(40) UNIQUE NOT NULL,
    direccion VARCHAR(40),
    telefono VARCHAR(15),
    horario_atencion VARCHAR(30),
    estado VARCHAR(10) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

CREATE SEQUENCE seq_estaciones;

INSERT INTO Estaciones VALUES (seq_estaciones.NEXTVAL, 'Estación Central', 'Av. Siempre Viva 123, Quito', '0987654321', '24 horas', 'ACTIVO');
INSERT INTO Estaciones VALUES (seq_estaciones.NEXTVAL, 'Gasolinera El Sol', 'Calle Falsa 456, Guayaquil', '0998765432', '06:00 - 22:00', 'ACTIVO');
INSERT INTO Estaciones VALUES (seq_estaciones.NEXTVAL, 'Estación Los Andes', 'Av. Central 789, Cuenca', '0976543210', '07:00 - 20:00', 'ACTIVO');
INSERT INTO Estaciones VALUES (seq_estaciones.NEXTVAL, 'Gasolinera La Costa', 'Calle Norte 321, Loja', '0965432109', '05:00 - 23:00', 'ACTIVO');
INSERT INTO Estaciones VALUES (seq_estaciones.NEXTVAL, 'Estación del Sur', 'Av. Sur 654, Ambato', '0954321098', '24 horas', 'INACTIVO');

CREATE TABLE ConsumoCombustible (
    id_consumo NUMBER PRIMARY KEY,
    id_estacionCombustible NUMBER NOT NULL,
    id_asignacion NUMBER NOT NULL,
    fecha DATE NOT NULL,
    combustible VARCHAR(10) NOT NULL CHECK (combustible IN ('DISEL', 'EXTRA', 'SUPER')),
    litros NUMBER(6,2) NOT NULL CHECK (litros > 0),
    costo_total NUMBER(8,2) NOT NULL CHECK (costo_total > 0),
    kilometraje NUMBER NOT NULL CHECK (kilometraje > 0),
    CONSTRAINT fk_consumo_estacion FOREIGN KEY (id_estacionCombustible) REFERENCES Estaciones(id_estacionCombustible),
    CONSTRAINT fk_consumo_asignacion FOREIGN KEY (id_asignacion) REFERENCES AsignacionesConductores(id_asignacion)
);

CREATE SEQUENCE seq_consumo;

INSERT INTO ConsumoCombustible VALUES (seq_consumo.NEXTVAL, 1, 1, TO_DATE('2023-03-15', 'YYYY-MM-DD'), 'EXTRA', 50.00, 75.00, 25000);
INSERT INTO ConsumoCombustible VALUES (seq_consumo.NEXTVAL, 2, 2, TO_DATE('2023-04-10', 'YYYY-MM-DD'), 'DISEL', 60.00, 90.00, 30000);
INSERT INTO ConsumoCombustible VALUES (seq_consumo.NEXTVAL, 3, 3, TO_DATE('2023-05-20', 'YYYY-MM-DD'), 'SUPER', 40.00, 80.00, 15000);
INSERT INTO ConsumoCombustible VALUES (seq_consumo.NEXTVAL, 4, 4, TO_DATE('2023-06-05', 'YYYY-MM-DD'), 'EXTRA', 55.00, 82.50, 40000);
INSERT INTO ConsumoCombustible VALUES (seq_consumo.NEXTVAL, 5, 5, TO_DATE('2023-07-25', 'YYYY-MM-DD'), 'DISEL', 70.00, 105.00, 5000);

CREATE TABLE DocumentosVehiculos (
    id_documento NUMBER PRIMARY KEY,
    id_vehiculo NUMBER NOT NULL,
    tipo_documento VARCHAR(15) NOT NULL CHECK (tipo_documento IN ('SEGURO', 'TENENCIA', 'CIRCULACION', 'VERIFICACION')),
    numero_documento VARCHAR(20) NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_vigencia DATE NOT NULL,
    archivo_digital VARCHAR(50),
    estado VARCHAR(15) DEFAULT 'VIGENTE' CHECK (estado IN ('VIGENTE', 'VENCIDO', 'PROCESO')),
    CONSTRAINT fk_documento_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES Vehiculos(id_vehiculo)
);

CREATE SEQUENCE seq_documentos;

INSERT INTO DocumentosVehiculos VALUES (seq_documentos.NEXTVAL, 1, 'SEGURO', 'DOC12345', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-01', 'YYYY-MM-DD'), 'seguro_vehiculo1.pdf', 'VIGENTE');
INSERT INTO DocumentosVehiculos VALUES (seq_documentos.NEXTVAL, 2, 'TENENCIA', 'DOC67890', TO_DATE('2022-06-15', 'YYYY-MM-DD'), TO_DATE('2023-06-15', 'YYYY-MM-DD'), 'tenencia_vehiculo2.pdf', 'VENCIDO');
INSERT INTO DocumentosVehiculos VALUES (seq_documentos.NEXTVAL, 3, 'CIRCULACION', 'DOC54321', TO_DATE('2023-03-10', 'YYYY-MM-DD'), TO_DATE('2024-03-10', 'YYYY-MM-DD'), 'circulacion_vehiculo3.pdf', 'VIGENTE');
INSERT INTO DocumentosVehiculos VALUES (seq_documentos.NEXTVAL, 4, 'VERIFICACION', 'DOC98765', TO_DATE('2023-05-20', 'YYYY-MM-DD'), TO_DATE('2024-05-20', 'YYYY-MM-DD'), 'verificacion_vehiculo4.pdf', 'VIGENTE');
INSERT INTO DocumentosVehiculos VALUES (seq_documentos.NEXTVAL, 5, 'SEGURO', 'DOC11223', TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2024-07-01', 'YYYY-MM-DD'), 'seguro_vehiculo5.pdf', 'VIGENTE');

CREATE TABLE Rutas (
    id_ruta NUMBER PRIMARY KEY,
    origen VARCHAR(30) NOT NULL,
    destino VARCHAR(30) NOT NULL,
    distancia_km NUMBER(6,2) NOT NULL,
    tiempo_estimado_min NUMBER NOT NULL
);

CREATE SEQUENCE seq_rutas;

INSERT INTO Rutas VALUES (seq_rutas.NEXTVAL, 'Quito', 'Guayaquil', 421.50, 480);
INSERT INTO Rutas VALUES (seq_rutas.NEXTVAL, 'Cuenca', 'Loja', 214.30, 240);
INSERT INTO Rutas VALUES (seq_rutas.NEXTVAL, 'Ambato', 'Riobamba', 50.20, 60);
INSERT INTO Rutas VALUES (seq_rutas.NEXTVAL, 'Guayaquil', 'Manta', 192.80, 180);
INSERT INTO Rutas VALUES (seq_rutas.NEXTVAL, 'Quito', 'Ibarra', 115.40, 120);

CREATE TABLE Viajes (
    id_viaje NUMBER PRIMARY KEY,
    id_ruta NUMBER NOT NULL,
    id_asignacion NUMBER NOT NULL,
    fecha_salida DATE NOT NULL,
    fecha_llegada DATE,
    kilometraje_salida NUMBER NOT NULL,
    kilometraje_llegada NUMBER,
    motivo VARCHAR(50) NOT NULL,
    observaciones VARCHAR(50),
    estado VARCHAR(20) DEFAULT 'PROGRAMADO' CHECK (estado IN ('PROGRAMADO', 'EN CURSO', 'CANCELADO', 'COMPLETADO')),
    costo NUMBER(10,2) DEFAULT 0,
    CONSTRAINT fk_viaje_ruta FOREIGN KEY (id_ruta) REFERENCES Rutas(id_ruta),
    CONSTRAINT fk_viaje_asignacion FOREIGN KEY (id_asignacion) REFERENCES AsignacionesConductores(id_asignacion),
    CONSTRAINT chk_fecha_viaje CHECK (fecha_llegada >= fecha_salida),
    CONSTRAINT chk_kilometraje_viaje CHECK (kilometraje_llegada >= kilometraje_salida)
);

CREATE SEQUENCE seq_viajes;

INSERT INTO Viajes VALUES (seq_viajes.NEXTVAL, 1, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-01-02', 'YYYY-MM-DD'), 25000, 25500, 'Entrega de mercancía', 'Sin novedades', 'COMPLETADO', 150.00);
INSERT INTO Viajes VALUES (seq_viajes.NEXTVAL, 2, 2, TO_DATE('2023-02-15', 'YYYY-MM-DD'), TO_DATE('2023-02-16', 'YYYY-MM-DD'), 30000, 30500, 'Transporte de pasajeros', 'Lluvia en el trayecto', 'COMPLETADO', 200.00);
INSERT INTO Viajes VALUES (seq_viajes.NEXTVAL, 3, 3, TO_DATE('2023-03-10', 'YYYY-MM-DD'), NULL, 15000, NULL, 'Revisión de ruta', 'Pendiente de finalizar', 'EN CURSO', 0.00);
INSERT INTO Viajes VALUES (seq_viajes.NEXTVAL, 4, 4, TO_DATE('2023-04-20', 'YYYY-MM-DD'), TO_DATE('2023-04-21', 'YYYY-MM-DD'), 40000, 40500, 'Entrega urgente', 'Retraso por tráfico', 'COMPLETADO', 180.00);
INSERT INTO Viajes VALUES (seq_viajes.NEXTVAL, 5, 5, TO_DATE('2023-05-05', 'YYYY-MM-DD'), TO_DATE('2023-05-06', 'YYYY-MM-DD'), 5000, 5500, 'Transporte de carga', 'Carga pesada', 'COMPLETADO', 250.00);

CREATE TABLE Incidentes (
    id_incidente NUMBER PRIMARY KEY,
    id_viaje NUMBER,
    fecha_incidente DATE NOT NULL,
    fecha_registro_incidente DATE NOT NULL,
    tipo_incidente VARCHAR(15) NOT NULL CHECK (tipo_incidente IN ('ACCIDENTE', 'FALLA MECANICA', 'INFRACCION', 'OTRO')),
    descripcion VARCHAR(50) NOT NULL,
    conclusion VARCHAR(50),
    costo_reparacion NUMBER(10,2),
    CONSTRAINT fk_incidente_viaje FOREIGN KEY (id_viaje) REFERENCES Viajes(id_viaje)
);

CREATE SEQUENCE seq_incidentes;

INSERT INTO Incidentes VALUES (seq_incidentes.NEXTVAL, 1, TO_DATE('2023-01-02', 'YYYY-MM-DD'), TO_DATE('2023-01-02', 'YYYY-MM-DD'), 'ACCIDENTE', 'Colisión leve en intersección', 'Reparación de parachoques', 300.00);
INSERT INTO Incidentes VALUES (seq_incidentes.NEXTVAL, 2, TO_DATE('2023-02-16', 'YYYY-MM-DD'), TO_DATE('2023-02-16', 'YYYY-MM-DD'), 'FALLA MECANICA', 'Problema en el sistema de frenos', 'Reparación completa de frenos', 500.00);
INSERT INTO Incidentes VALUES (seq_incidentes.NEXTVAL, 3, TO_DATE('2023-03-15', 'YYYY-MM-DD'), TO_DATE('2023-03-15', 'YYYY-MM-DD'), 'INFRACCION', 'Exceso de velocidad', 'Multa pagada', 150.00);
INSERT INTO Incidentes VALUES (seq_incidentes.NEXTVAL, 4, TO_DATE('2023-04-21', 'YYYY-MM-DD'), TO_DATE('2023-04-21', 'YYYY-MM-DD'), 'OTRO', 'Retraso por tráfico', 'Sin costo adicional', 0.00);
INSERT INTO Incidentes VALUES (seq_incidentes.NEXTVAL, 5, TO_DATE('2023-05-06', 'YYYY-MM-DD'), TO_DATE('2023-05-06', 'YYYY-MM-DD'), 'ACCIDENTE', 'Colisión con objeto fijo', 'Reparación de carrocería', 800.00);

-- Select para todas las tablas --
SELECT * FROM Usuarios;
SELECT * FROM Conductores;
SELECT * FROM Vehiculos;
SELECT * FROM AsignacionesConductores;
SELECT * FROM LicenciasConducir;
SELECT * FROM Proveedores;
SELECT * FROM Mantenimientos;
SELECT * FROM Estaciones;
SELECT * FROM ConsumoCombustible;
SELECT * FROM DocumentosVehiculos;
SELECT * FROM Rutas;
SELECT * FROM Viajes;
SELECT * FROM Incidentes;
