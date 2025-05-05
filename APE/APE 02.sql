-- Codificacion para hacer transacciones en MySQL para la BD GestionHospitalaria

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS GestionHospitalaria;
USE GestionHospitalaria;

-- Crear tabla CentrosMedicos
-- Almacena información sobre los centros médicos.
CREATE TABLE CentroMedico (
    CentroID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Direccion VARCHAR(50) NOT NULL,
    Telefono VARCHAR(10),
    Email VARCHAR(100) UNIQUE
);

-- Crear tabla Usuarios
-- Almacena información sobre los usuarios del sistema, incluyendo su rol y credenciales.
CREATE TABLE Usuario (
    UsuarioID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Sexo ENUM('MASCULINO', 'FEMENINO') NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Direccion VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Rol ENUM('ADMIN', 'MEDICO', 'EMPLEADO') NOT NULL
);

-- Crear tabla Especialidades
-- Almacena las especialidades médicas disponibles.
CREATE TABLE Especialidad (
    EspecialidadID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL
);

-- Crear tabla Medicos
-- Almacena información sobre los médicos, incluyendo su especialidad y centro médico asociado.
CREATE TABLE Medico (
    MedicoID INT AUTO_INCREMENT PRIMARY KEY,
    EspecialidadID INT NOT NULL,
    CentroID INT NOT NULL,
    UsuarioID INT NOT NULL,
    FOREIGN KEY (EspecialidadID) REFERENCES Especialidad(EspecialidadID),
    FOREIGN KEY (CentroID) REFERENCES CentroMedico(CentroID),
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID)
);

-- Crear tabla Empleados
-- Almacena información sobre los empleados de los centros médicos.
CREATE TABLE Empleado (
    EmpleadoID INT AUTO_INCREMENT PRIMARY KEY,
    Cargo VARCHAR(50) NOT NULL,
    UsuarioID INT NOT NULL,
    CentroID INT NOT NULL,
    FOREIGN KEY (CentroID) REFERENCES CentroMedico(CentroID)
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID)
);

-- Crear tabla Pacientes
-- Almacena información sobre los pacientes atendidos en los centros médicos.
CREATE TABLE Paciente (
    PacienteID INT AUTO_INCREMENT PRIMARY KEY,
    UsuarioID INT NOT NULL,
    CentroID INT NOT NULL,
    FechaRegistro DATE NOT NULL,
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID)
);

-- Crear tabla Consultas
-- Almacena información sobre las consultas médicas realizadas, incluyendo el médico y el paciente.
CREATE TABLE Consulta (
    ConsultaID INT AUTO_INCREMENT PRIMARY KEY,
    MedicoID INT NOT NULL,
    PacienteID INT NOT NULL,
    FechaConsulta DATE NOT NULL,
    Diagnostico TEXT,
    Receta TEXT,
    FOREIGN KEY (MedicoID) REFERENCES Medico(MedicoID),
    FOREIGN KEY (PacienteID) REFERENCES Paciente(PacienteID)
);

-- Transacciones par insertar datos en las tablas
-- commit; -- Confirma la transacción
-- rollback; -- Revierte la transacción en caso de error
-- start transaction; -- Inicia una nueva transacción

-- Transaccion sql con commit
-- Inicia una nueva transacción
start transaction;

INSERT INTO MEDICOS (Nombre, Apellido, Sexo, FechaNacimiento, Direccion, Telefono, Email, Password, Rol) VALUES
('Juan', 'Pérez', 'MASCULINO', '1980-01-01', 'Calle 123', '5551234567', 'juanperez@email.com', 'password123', 'MEDICO');

commit; -- Confirma la transacción


-- Transaccion sql con rollback
-- Inicia una nueva transacción
start transaction;

INSERT INTO MEDICOS (Nombre, Apellido, Sexo, FechaNacimiento, Direccion, Telefono, Email, Password, Rol) VALUES
('Juan', 'Pérez', 'MASCULINO', '1980-01-01', 'Calle 123', '5551234567', 'juanperez@email.com', 'password123', 'MEDICO');

rollback; -- Revierte la transacción en caso de error

-- Transaccion update sql con rockback
-- Inicia una nueva transacción

start transaction;
UPDATE MEDICOS SET Telefono = '5559876543' WHERE MedicoID = 1;
rollback; -- Revierte la transacción en caso de error



