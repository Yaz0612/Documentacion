-- Procedimiento almacenado para realizar backups de bases de datos.
-- Genera archivos de backup con timestamp
-- Parámetros:
--   @DatabaseName
--   @BackupType:(FULL, DIFFERENTIAL, LOG)

CREATE PROCEDURE sp_BackupDatabase
    @DatabaseName NVARCHAR(128),  -- Nombre de la base de datos
    @BackupType NVARCHAR(20)      -- Tipo de backup
AS
BEGIN
    -- Evita el envío de mensajes DONEINPROC al cliente para cada instrucción del procedimiento almacenado
    -- Asi mismo puede proporcionar un aumento en el rendimiento, ya que el tráfico de red se reduce considerablemente
    SET NOCOUNT ON;

    -- Declaración de variables
    DECLARE @BackupPath NVARCHAR(500);   -- Ruta base de los backups
    DECLARE @BackupFolder NVARCHAR(500); -- Ruta específica del tipo de backup
    DECLARE @FileName NVARCHAR(500);     -- Nombre del archivo de backup
    DECLARE @Timestamp NVARCHAR(20);     -- Para el nombre del archivo
    DECLARE @SQL NVARCHAR(MAX);          -- Comando SQL dinámico
    DECLARE @FileExists INT;             -- Para verificar si una carpeta existe

    BEGIN TRY
        -- Validar si la base de datos existe
        IF DB_ID(@DatabaseName) IS NULL
        BEGIN
            -- Si la base de datos no existe, mostrar un error y terminar la ejecucion
            RAISERROR('La base de datos especificada no existe.', 16, 1);
            RETURN;
        END;

        -- Convierte a mayúsculas para determinar el tipo de backup a realizar (FULL, DIFFERENTIAL, LOG) evitando errores en las comparaciones
        SET @BackupType = UPPER(@BackupType);

        -- Construir la ruta de los backups
        SET @BackupPath = '\\SERVER-BACKUPS\Backups\' 
                        + @DatabaseName  -- Usa el nombre de la base de datos
                        + '\';

        -- Verificar si la carpeta de backups existe mediante un procedimiento almacenado (xp_fileexist)
        -- xp_fileexist devuelve 1 si la carpeta existe y 0 cuando no existe
        EXEC master.dbo.xp_fileexist @BackupPath, @FileExists OUTPUT;
        IF @FileExists = 0
        BEGIN
            -- Si la carpeta no existe, la crea usando xp_cmdshell
            SET @SQL = N'EXEC xp_cmdshell ''mkdir ' + @BackupPath + '''';
            EXEC sp_executesql @SQL;
        END;

        -- Se construye la ruta específica del tipo de backup
        -- La primera letra del tipo de backup se convierte a mayúscula, el resto a minúscula
        SET @BackupFolder = @BackupPath 
                            + UPPER(LEFT(@BackupType, 1)) 
                            + LOWER(SUBSTRING(@BackupType, 2, LEN(@BackupType))) 
                            + '\';

        -- Verificar si la carpeta específica del tipo de backup existe
        EXEC master.dbo.xp_fileexist @BackupFolder, @FileExists OUTPUT;
        IF @FileExists = 0
        BEGIN
            -- Si la carpeta no existe, crearla usando xp_cmdshell
            SET @SQL = N'EXEC xp_cmdshell ''mkdir ' + @BackupFolder + '''';
            EXEC sp_executesql @SQL;
        END;

        -- Generar un timestamp en formato yyyyMMdd_HHmmss
        -- FORMAT convierte la fecha y hora actual a una cadena con el formato especificado
        SET @Timestamp = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');

        -- Construir el nombre del archivo de backup
        -- Formato: [NombreDeLaBaseDeDatos]_[TipoBackup]_[Timestamp].bak
        SET @FileName = @BackupFolder 
                        + @DatabaseName
                        + '_' 
                        + UPPER(LEFT(@BackupType, 1)) 
                        + LOWER(SUBSTRING(@BackupType, 2, LEN(@BackupType))) 
                        + '_' 
                        + @Timestamp 
                        + '.bak';

        -- Construir el comando de backup dinámico
        -- BACKUP DATABASE realiza el backup de la base de datos especificada
        -- WITH INIT sobrescribe el archivo de backup si ya existe
        -- NAME y DESCRIPTION agregan metadatos al backup
        SET @SQL = N'BACKUP DATABASE [' + @DatabaseName + N'] TO DISK = N''' + @FileName + N''' 
                    WITH INIT, NAME = N''' + @DatabaseName + N' Backup'', DESCRIPTION = N''Backup generado automáticamente'';';
        
        -- Ejecutar el comando de backup
        EXEC sp_executesql @SQL;

        -- Mostrar un mensaje de éxito con la ruta del backup generado
        PRINT 'Backup completado exitosamente en: ' + @FileName;
    END TRY
    BEGIN CATCH
        -- Capturar y mostrar cualquier error que ocurra durante el proceso de backup
        PRINT 'Error en el proceso de backup: ' + ERROR_MESSAGE();
    END CATCH;
END;