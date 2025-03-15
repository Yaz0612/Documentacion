--
-- Stored procedure para crear una base de datos con archivos de datos y logs configurados
-- Este procedimiento crea una base de datos en SQL Server con parámetros personalizados para 
-- los archivos de datos (MDF) y de log (LDF). También permite agregar un filegroup secundario (NDF).
--
CREATE PROCEDURE CrearBaseDeDatos
    @NombreDB NVARCHAR(128),  -- Nombre de la base de datos a crear.
    @RutaMDF NVARCHAR(260),   -- Ruta completa del archivo de datos(MDF).
    @TamanioInicialMDF INT,    -- Tamaño inicial del archivo de datos en MB.
    @CrecimientoMDF INT,       -- Tamaño de crecimiento del archivo de datos en MB.
    @RutaLDF NVARCHAR(260),    -- Ruta completa del archivo de logs (LDF).
    @TamanioInicialLDF INT,    -- Tamaño inicial del archivo de registro en MB.
    @CrecimientoLDF INT,       -- Tamaño de crecimiento del archivo de registro en MB.
    @RutaSecundaria NVARCHAR(260) = NULL,  -- Ruta opcional para el archivo de datos secundario (NDF).
    @TamanioInicialSecundario INT = NULL,  -- Tamaño inicial del archivo secundario en MB.
    @CrecimientoSecundario INT = NULL      -- Tamaño de crecimiento del archivo secundario en MB.
AS
BEGIN
    -- Bloque TRY para manejar errores durante la ejecución.
    BEGIN TRY
        -- Verificar si la base de datos ya existe en el servidor.
        IF DB_ID(@NombreDB) IS NOT NULL
        BEGIN
            PRINT 'La base de datos ' + @NombreDB + ' ya existe.';
            RETURN;  -- Salir del procedimiento si la base de datos ya existe.
        END

        -- Validar que las rutas de los archivos MDF y LDF no estén vacías.
        IF @RutaMDF IS NULL OR @RutaLDF IS NULL
        BEGIN
            PRINT 'Las rutas de los archivos MDF y LDF no pueden estar vacías.';
            RETURN;  -- Salir del procedimiento si las rutas no son válidas.
        END

        -- Validar que los tamaños iniciales y crecimientos sean valores positivos.
        IF @TamanioInicialMDF <= 0 OR @CrecimientoMDF <= 0 OR @TamanioInicialLDF <= 0 OR @CrecimientoLDF <= 0
        BEGIN
            PRINT 'Los tamaños y crecimientos deben ser valores positivos.';
            RETURN;  -- Salir del procedimiento si los valores no son válidos.
        END

        -- Construir la sentencia SQL dinámica para crear la base de datos.
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = 'CREATE DATABASE ' + QUOTENAME(@NombreDB) + ' 
        ON PRIMARY 
        (NAME = ' + QUOTENAME(@NombreDB + '_Data') + ', 
        FILENAME = ' + QUOTENAME(@RutaMDF, '''') + ', 
        SIZE = ' + CAST(@TamanioInicialMDF AS NVARCHAR) + 'MB, 
        FILEGROWTH = ' + CAST(@CrecimientoMDF AS NVARCHAR) + 'MB)
        LOG ON 
        (NAME = ' + QUOTENAME(@NombreDB + '_Log') + ', 
        FILENAME = ' + QUOTENAME(@RutaLDF, '''') + ', 
        SIZE = ' + CAST(@TamanioInicialLDF AS NVARCHAR) + 'MB, 
        FILEGROWTH = ' + CAST(@CrecimientoLDF AS NVARCHAR) + 'MB)';

        -- Ejecutar la sentencia SQL dinámica para crear la base de datos.
        EXEC sp_executesql @SQL;

        -- Verificar si se proporciona una ruta secundaria para crear un filegroup secundario.
        IF @RutaSecundaria IS NOT NULL AND @TamanioInicialSecundario > 0 AND @CrecimientoSecundario > 0
        BEGIN
            -- Nombre del filegroup secundario.
            DECLARE @FilegroupSecundario NVARCHAR(128);
            SET @FilegroupSecundario = @NombreDB + '_Secundario';

            -- Construir la ruta completa del archivo secundario (NDF).
            DECLARE @RutaCompletaSecundaria NVARCHAR(260);
            SET @RutaCompletaSecundaria = @RutaSecundaria + '\' + @NombreDB + '_Secundario.ndf';

            -- Agregar el filegroup secundario a la base de datos.
            SET @SQL = 'ALTER DATABASE ' + QUOTENAME(@NombreDB) + '
            ADD FILEGROUP ' + QUOTENAME(@FilegroupSecundario) + ';';

            EXEC sp_executesql @SQL;

            -- Agregar el archivo de datos secundario (NDF) al filegroup secundario.
            SET @SQL = 'ALTER DATABASE ' + QUOTENAME(@NombreDB) + '
            ADD FILE 
            (NAME = ' + QUOTENAME(@FilegroupSecundario + '_Data') + ', 
            FILENAME = ' + QUOTENAME(@RutaCompletaSecundaria, '''') + ', 
            SIZE = ' + CAST(@TamanioInicialSecundario AS NVARCHAR) + 'MB, 
            FILEGROWTH = ' + CAST(@CrecimientoSecundario AS NVARCHAR) + 'MB)
            TO FILEGROUP ' + QUOTENAME(@FilegroupSecundario) + ';';

            EXEC sp_executesql @SQL;
        END

        -- Mostrar un mensaje de éxito si la base de datos se crea correctamente.
        PRINT 'Base de datos ' + @NombreDB + ' creada exitosamente.';
    END TRY
    -- Bloque CATCH para manejar errores durante la ejecución.
    BEGIN CATCH
        -- Capturar detalles del error.
        DECLARE @ErrorMessage NVARCHAR(4000);  -- Mensaje de error.
        DECLARE @ErrorSeverity INT;           -- Severidad del error.
        DECLARE @ErrorState INT;              -- Estado del error.

        -- Obtener los detalles del error.
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),  -- Mensaje de error.
            @ErrorSeverity = ERROR_SEVERITY(),  -- Nivel de severidad del error.
            @ErrorState = ERROR_STATE();      -- Estado del error.

        -- Mostrar los detalles del error.
        PRINT 'Error: ' + @ErrorMessage;
        PRINT 'Severidad: ' + CAST(@ErrorSeverity AS NVARCHAR);
        PRINT 'Estado: ' + CAST(@ErrorState AS NVARCHAR);
    END CATCH
END;