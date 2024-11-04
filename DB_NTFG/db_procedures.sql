CREATE PROCEDURE SP_AGREGAR_PROFESOR
    @Nombre NVARCHAR(255),
    @Tutor BIT,
    @Metodologo BIT
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
    END TRY
    BEGIN CATCH

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


CREATE PROCEDURE SP_AGREGAR_PROYECTO
    @NOMBRE_PROYECTO NVARCHAR(255),
    @NOMBRE_ESTUDIANTE NVARCHAR(255),
    @CEDULA_ESTUDIANTE NVARCHAR(20),
    @NOMBRE_METODOLOGO NVARCHAR(255),
    @NOMBRE_TUTOR NVARCHAR(255),

AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    BEGIN TRY

    END TRY
    BEGIN CATCH
    END CATCH
END