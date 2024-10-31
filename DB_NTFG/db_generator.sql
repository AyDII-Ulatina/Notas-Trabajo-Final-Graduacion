CREATE TABLE Estado (
    IdEstado INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion NVARCHAR(100) NOT NULL
);

CREATE TABLE Categoria (
    IdCategoria INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion NVARCHAR(100) NOT NULL
);

CREATE TABLE Rol (
    IdRol INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion NVARCHAR(100) NOT NULL
);

CREATE TABLE Profesor (
    IdProfesor INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL
);

CREATE TABLE Estudiante (
    IdEstudiante INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL,
    Cedula NVARCHAR(20) NOT NULL
);

CREATE TABLE Proyecto (
    IdProyecto INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL,
    Fecha DATE NOT NULL,
    IdProfesor_Tutor INT,
    IdProfesor_Metodologo INT,
    IdEstado INT,
    IdEstudiante INT,
    FOREIGN KEY (IdProfesor_Tutor) REFERENCES Profesor(IdProfesor),
    FOREIGN KEY (IdProfesor_Metodologo) REFERENCES Profesor(IdProfesor),
    FOREIGN KEY (IdEstado) REFERENCES Estado(IdEstado),
    FOREIGN KEY (IdEstudiante) REFERENCES Estudiante(IdEstudiante)
);

CREATE TABLE Rubro (
    IdRubro INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion NVARCHAR(255) NOT NULL,
    IdCategoria INT,
    IdEstado INT,
    FOREIGN KEY (IdCategoria) REFERENCES Categoria(IdCategoria),
    FOREIGN KEY (IdEstado) REFERENCES Estado(IdEstado)
);

CREATE TABLE RegistroDeNotas (
    IdRubro INT,
    IdProyecto INT,
    Comentario NVARCHAR(MAX),
    Calificacion INT CHECK (Calificacion BETWEEN 0 AND 5),
    PRIMARY KEY (IdRubro, IdProyecto),
    FOREIGN KEY (IdRubro) REFERENCES Rubro(IdRubro),
    FOREIGN KEY (IdProyecto) REFERENCES Proyecto(IdProyecto)
);

CREATE TABLE ProfesorRol (
    IdRol INT,
    IdProfesor INT,
    IdEstado INT,
    PRIMARY KEY (IdRol, IdProfesor),
    FOREIGN KEY (IdRol) REFERENCES Rol(IdRol),
    FOREIGN KEY (IdProfesor) REFERENCES Profesor(IdProfesor),
    FOREIGN KEY (IdEstado) REFERENCES Estado(IdEstado)
);
