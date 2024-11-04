-- Inserción de datos en la tabla Categoria
INSERT INTO Categoria (Descripcion)
VALUES 
    ('Defensa'),
    ('Tutor'),
    ('Metodologo');

-- Inserción de datos en la tabla Rol
INSERT INTO Rol (Descripcion)
VALUES 
    ('Tutor'),
    ('Metodologo');

-- Inserción de datos en la tabla Profesor
INSERT INTO Profesor (Nombre)
VALUES 
    ('Prof. Juan Pérez'),
    ('Prof. Ana Rodríguez'),
    ('Prof. Carlos Gómez');

-- Inserción de datos en la tabla Estudiante
INSERT INTO Estudiante (Nombre, Cedula)
VALUES 
    ('Estudiante 1', '1234567890'),
    ('Estudiante 2', '0987654321'),
    ('Estudiante 3', '1122334455');

-- Inserción de datos en la tabla Proyecto
INSERT INTO Proyecto (Nombre, Fecha, IdProfesor_Tutor, IdProfesor_Metodologo, IdEstado, IdEstudiante)
VALUES 
    ('Proyecto A', '2024-11-01', 1, 2, 4, 1),
    ('Proyecto B', '2024-11-02', 2, 3, 3, 2),
    ('Proyecto C', '2024-11-03', 1, 3, 3, 3);

-- Inserción de datos en la tabla Rubro
INSERT INTO Rubro (Descripcion, IdCategoria, IdEstado)
VALUES 
    ('Rubro 1', 1, 1),
    ('Rubro 2', 2, 1),
    ('Rubro 3', 3, 2);

-- Inserción de datos en la tabla RegistroDeNotas
INSERT INTO RegistroDeNotas (IdRubro, IdProyecto, Comentario, Calificacion)
VALUES 
    (1, 1, 'Buen trabajo', 5),
    (2, 2, 'Necesita mejorar', 3),
    (3, 3, 'Excelente avance', 4);

-- Inserción de datos en la tabla ProfesorRol
INSERT INTO ProfesorRol (IdRol, IdProfesor, IdEstado)
VALUES 
    (1, 1, 1), -- Prof. Juan Pérez como Tutor activo
    (2, 2, 1), -- Prof. Ana Rodríguez como Metodologo activo
    (1, 3, 2); -- Prof. Carlos Gómez como Tutor inactivo
