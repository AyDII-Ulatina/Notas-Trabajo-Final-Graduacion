CREATE OR ALTER PROCEDURE SP_AGREGAR_PROFESOR
    @Nombre NVARCHAR(255),
    @Tutor BIT,
    @Metodologo BIT,
    @RESULTADO BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;

    BEGIN TRY

        INSERT INTO Profesor (Nombre)
        VALUES (@Nombre);

        DECLARE @IdProfesor INT;
        SET @IdProfesor = SCOPE_IDENTITY();


        IF (@IdProfesor IS NULL)
        BEGIN
            THROW 50000, 'Error al obtener el Id del profesor.', 1;
        END

        IF (@Tutor = 1)
        BEGIN
            INSERT INTO ProfesorRol (IdRol, IdProfesor, IdEstado)
            VALUES (1, @IdProfesor, 1);
        END

        IF (@Metodologo = 1)
        BEGIN
            INSERT INTO ProfesorRol (IdRol, IdProfesor, IdEstado)
            VALUES (2, @IdProfesor, 1);
        END

        COMMIT;
        SET @RESULTADO = 1;
    END TRY
    BEGIN CATCH
        SET @RESULTADO = 0;
        ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
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

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE SP_PROYECTOS_PENDIENTES
AS
BEGIN
    SELECT *
    FROM Proyecto
    WHERE IdEstado = 3;
END;
GO

CREATE OR ALTER PROCEDURE SP_PROYECTOS_FINALIZADO
AS
BEGIN
    SELECT *
    FROM Proyecto
    WHERE IdEstado = 4;
END;
GO

CREATE OR ALTER PROCEDURE SP_OBTENER_PROFESORES_ACTIVOS
AS
BEGIN
    SELECT p.IdProfesor, p.Nombre, 'Tutor' AS Rol
    FROM Proyecto pr
    INNER JOIN Profesor p ON pr.IdProfesor_Tutor = p.IdProfesor
    INNER JOIN ProfesorRol prl ON p.IdProfesor = prl.IdProfesor
    WHERE prl.IdRol = 1 AND prl.IdEstado = 1

    UNION

    SELECT p.IdProfesor, p.Nombre, 'Metodologo' AS Rol
    FROM Proyecto pr
    INNER JOIN Profesor p ON pr.IdProfesor_Metodologo = p.IdProfesor
    INNER JOIN ProfesorRol prl ON p.IdProfesor = prl.IdProfesor
    WHERE prl.IdRol = 2 AND prl.IdEstado = 1;
END;
GO
