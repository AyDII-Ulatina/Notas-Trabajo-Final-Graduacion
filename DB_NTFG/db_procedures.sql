CREATE OR ALTER PROCEDURE SP_AGREGAR_PROFESOR
    @NOMBRE NVARCHAR(255),
    @TUTOR BIT,
    @METODOLOGO BIT,
    @RESULTADO BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;

    BEGIN TRY

        INSERT INTO Profesor (Nombre)
        VALUES (@NOMBRE);

        DECLARE @ID_PROFESOR INT;
        SET @ID_PROFESOR = SCOPE_IDENTITY();


        IF (@ID_PROFESOR IS NULL)
        BEGIN
            THROW 50000, 'Error al obtener el Id del profesor.', 1;
        END

        IF (@TUTOR = 1)
        BEGIN
            INSERT INTO ProfesorRol (IdRol, IdProfesor, IdEstado)
            VALUES (1, @ID_PROFESOR, 1);
        END

        IF (@METODOLOGO = 1)
        BEGIN
            INSERT INTO ProfesorRol (IdRol, IdProfesor, IdEstado)
            VALUES (2, @ID_PROFESOR, 1);
        END

        COMMIT;
        SET @RESULTADO = 1;
    END TRY
    BEGIN CATCH
        SET @RESULTADO = 0;
        ROLLBACK;

        DECLARE @ERROR_MESSAGE NVARCHAR(4000);
        DECLARE @ERROR_SEVERITY INT;
        DECLARE @ERROR_STATE INT;

        SELECT 
            @ERROR_MESSAGE = ERROR_MESSAGE(),
            @ERROR_SEVERITY = ERROR_SEVERITY(),
            @ERROR_STATE = ERROR_STATE();

        RAISERROR (@ERROR_MESSAGE, @ERROR_SEVERITY, @ERROR_STATE);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE SP_AGREGAR_PROYECTO
    @NOMBRE_PROYECTO NVARCHAR(255),
    @NOMBRE_ESTUDIANTE NVARCHAR(255),
    @CEDULA_ESTUDIANTE NVARCHAR(20),
    @NOMBRE_METODOLOGO NVARCHAR(255),
    @NOMBRE_TUTOR NVARCHAR(255),
    @RESULTADO BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @ID_ESTUDIANTE INT;
        DECLARE @ID_METODOLOGO INT;
        DECLARE @ID_TUTOR INT;

        INSERT INTO Estudiante (Nombre, Cedula)
        VALUES (@NOMBRE_ESTUDIANTE, @CEDULA_ESTUDIANTE);
        SET @ID_ESTUDIANTE = SCOPE_IDENTITY();

        SELECT @ID_METODOLOGO = IdProfesor FROM Profesor WHERE Nombre = @NOMBRE_METODOLOGO;
        SELECT @ID_TUTOR = IdProfesor FROM Profesor WHERE Nombre = @NOMBRE_TUTOR;

        IF (@ID_ESTUDIANTE IS NULL)
        BEGIN
            THROW 50001, 'Error: No se pudo obtener el ID del Estudiante.', 1;
        END

        IF (@ID_METODOLOGO IS NULL)
        BEGIN
            THROW 50002, 'Error: No se encontró el Metodólogo especificado.', 1;
        END

        IF (@ID_TUTOR IS NULL)
        BEGIN
            THROW 50003, 'Error: No se encontró el Tutor especificado.', 1;
        END

        INSERT INTO Proyecto (Nombre, Fecha, IdProfesor_Tutor, IdProfesor_Metodologo, IdEstado, IdEstudiante)
        VALUES (@NOMBRE_PROYECTO, GETDATE(), @ID_TUTOR, @ID_METODOLOGO, 3, @ID_ESTUDIANTE);

        COMMIT;
        SET @RESULTADO = 1;
    END TRY
    BEGIN CATCH
        SET @RESULTADO = 0;
        ROLLBACK;

        DECLARE @ERROR_MESSAGE NVARCHAR(4000);
        DECLARE @ERROR_SEVERITY INT;
        DECLARE @ERROR_STATE INT;

        SELECT 
            @ERROR_MESSAGE = ERROR_MESSAGE(),
            @ERROR_SEVERITY = ERROR_SEVERITY(),
            @ERROR_STATE = ERROR_STATE();

        RAISERROR (@ERROR_MESSAGE, @ERROR_SEVERITY, @ERROR_STATE);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE SP_OBTENER_PROYECTOS_PENDIENTES
AS
BEGIN
    SELECT 
        p.IdProyecto AS ID_PROYECTO,
        p.Nombre AS NOMBRE_PROYECTO,
        p.Fecha AS FECHA,
        ProfesorTutor.Nombre AS NOMBRE_TUTOR,
        ProfesorMetodologo.Nombre AS NOMBRE_METODOLOGO,
        e.Nombre AS NOMBRE_ESTUDIANTE
    FROM Proyecto p
    LEFT JOIN Profesor ProfesorTutor ON p.IdProfesor_Tutor = ProfesorTutor.IdProfesor
    LEFT JOIN Profesor ProfesorMetodologo ON p.IdProfesor_Metodologo = ProfesorMetodologo.IdProfesor
    LEFT JOIN Estudiante e ON p.IdEstudiante = e.IdEstudiante
    WHERE p.IdEstado = 3;
END;
GO
CREATE OR ALTER PROCEDURE SP_OBTENER_PROYECTOS_FINALIZADOS
AS
BEGIN
    SELECT 
        p.IdProyecto AS ID_PROYECTO,
        p.Nombre AS NOMBRE_PROYECTO,
        p.Fecha AS FECHA,
        ProfesorTutor.Nombre AS NOMBRE_TUTOR,
        ProfesorMetodologo.Nombre AS NOMBRE_METODOLOGO,
        e.Nombre AS NOMBRE_ESTUDIANTE
    FROM Proyecto p
    LEFT JOIN Profesor ProfesorTutor ON p.IdProfesor_Tutor = ProfesorTutor.IdProfesor
    LEFT JOIN Profesor ProfesorMetodologo ON p.IdProfesor_Metodologo = ProfesorMetodologo.IdProfesor
    LEFT JOIN Estudiante e ON p.IdEstudiante = e.IdEstudiante
    WHERE p.IdEstado = 4;
END;
GO

CREATE OR ALTER PROCEDURE SP_OBTENER_PROFESORES_ACTIVOS
AS
BEGIN
    SELECT 
        p.IdProfesor AS ID_PROFESOR,
        p.Nombre AS NOMBRE_PROFESOR,
        CAST(COALESCE(MAX(CASE WHEN prl.IdRol = 1 AND prl.IdEstado = 1 THEN 1 ELSE 0 END), 0) AS BIT) AS Tutor,
        CAST(COALESCE(MAX(CASE WHEN prl.IdRol = 2 AND prl.IdEstado = 1 THEN 1 ELSE 0 END), 0) AS BIT) AS Metodologo
    FROM Profesor p
    LEFT JOIN ProfesorRol prl ON p.IdProfesor = prl.IdProfesor
    GROUP BY p.IdProfesor, p.Nombre
    HAVING MAX(CASE WHEN prl.IdEstado = 1 THEN 1 ELSE 0 END) = 1;
END;
GO

CREATE OR ALTER PROCEDURE SP_OBTENER_ESTADO_PROFESORES
AS
BEGIN
    SELECT 
        p.IdProfesor AS ID_PROFESOR,
        p.Nombre AS NOMBRE_PROFESOR,
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM ProfesorRol prl 
                WHERE prl.IdProfesor = p.IdProfesor AND prl.IdEstado = 1
            ) THEN CAST(1 AS BIT)  -- Profesor tiene al menos un rol activo
            ELSE CAST(0 AS BIT)     -- Profesor no tiene roles activos
        END AS ESTADO
    FROM Profesor p;
END;
GO

CREATE OR ALTER PROCEDURE SP_EDITAR_PROFESOR
    @ID_PROFESOR INT,
    @NUEVO_NOMBRE NVARCHAR(255) = NULL,
    @NUEVO_ESTADO_TUTOR INT = NULL,
    @NUEVO_ESTADO_METODOLOGO INT = NULL
    @RESULTADO BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Profesor WHERE IdProfesor = @ID_PROFESOR)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50004, 'El profesor con el ID especificado no existe.', 1;
            RETURN;
        END

        IF @NUEVO_NOMBRE IS NOT NULL
        BEGIN
            UPDATE Profesor
            SET Nombre = @NUEVO_NOMBRE
            WHERE IdProfesor = @ID_PROFESOR;
        END

        IF @NUEVO_ESTADO_TUTOR IS NOT NULL AND (@NUEVO_ESTADO_TUTOR NOT IN (1, 2))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50005, 'El valor del nuevo estado de Tutor debe ser 1 (Activo) o 2 (Inactivo).', 1;
            RETURN;
        END

        IF @NUEVO_ESTADO_METODOLOGO IS NOT NULL AND (@NUEVO_ESTADO_METODOLOGO NOT IN (1, 2))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50006, 'El valor del nuevo estado de Metodólogo debe ser 1 (Activo) o 2 (Inactivo).', 1;
            RETURN;
        END

        IF @NUEVO_ESTADO_TUTOR IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM ProfesorRol WHERE IdProfesor = @ID_PROFESOR AND IdRol = 1)
            BEGIN
                UPDATE ProfesorRol
                SET IdEstado = @NUEVO_ESTADO_TUTOR
                WHERE IdProfesor = @ID_PROFESOR AND IdRol = 1;
            END
            ELSE
            BEGIN

                INSERT INTO ProfesorRol (IdProfesor, IdRol, IdEstado)
                VALUES (@ID_PROFESOR, 1, @NUEVO_ESTADO_TUTOR);
            END
        END

        IF @NUEVO_ESTADO_METODOLOGO IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM ProfesorRol WHERE IdProfesor = @ID_PROFESOR AND IdRol = 2)
            BEGIN
                UPDATE ProfesorRol
                SET IdEstado = @NUEVO_ESTADO_METODOLOGO
                WHERE IdProfesor = @ID_PROFESOR AND IdRol = 2;
            END
            ELSE
            BEGIN
                INSERT INTO ProfesorRol (IdProfesor, IdRol, IdEstado)
                VALUES (@ID_PROFESOR, 2, @NUEVO_ESTADO_METODOLOGO);
            END
        END

        COMMIT TRANSACTION;
        SET @RESULTADO = 1;
    END TRY
    BEGIN CATCH
        SET @RESULTADO = 0;
        ROLLBACK;

        DECLARE @ERROR_MESSAGE NVARCHAR(4000);
        DECLARE @ERROR_SEVERITY INT;
        DECLARE @ERROR_STATE INT;

        SELECT 
            @ERROR_MESSAGE = ERROR_MESSAGE(),
            @ERROR_SEVERITY = ERROR_SEVERITY(),
            @ERROR_STATE = ERROR_STATE();

        RAISERROR (@ERROR_MESSAGE, @ERROR_SEVERITY, @ERROR_STATE);
    END CATCH
END;
GO