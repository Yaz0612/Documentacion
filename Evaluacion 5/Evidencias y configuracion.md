## Evidencias de la Ejecución de Backups y Recuperación de Datos

Se presentan las evidencias de la ejecución del stored procedure para la generación de backups, así como las pruebas de recuperación de datos realizadas.

---

### Ejecución de Backups

#### Ejecución Manual del Stored Procedure
A continuación se muestra la ejecución manual del stored procedure `sp_BackupDatabase` desde SQL Server

![Ejecución del Stored Procedure](../Images/1.png)


> El backup se generó correctamente.

![Creacion](../Images/2.png)



### SQL Server Agent

#### Configuración de Jobs
Se configuraron jobs en SQL Server Agent para ejecutar el stored procedure automaticamente:

![DB Jobs](../Images/SBD.png)

![Jobs](../Images/Jobs.png)

#### Ejemplo de job para la creacion de un backup completo de la base de datos Northwind

![Configuración del Job 1](../Images/BCN.png)
![Configuración del Job 2](../Images/BCN2.png)
![Configuración del Job 3](../Images/BCN3.png)


> **Descripción:** El job `FullBackup_Northwind_Weekly` fue programado para ejecutarse cada semana.

#### Ejemplo de job para la creacion de un backup diferencial de la base de datos AdventureWorks

![Configuración del Job 2.1](../Images/BDAW.png)
![Configuración del Job 2.2](../Images/BDAW2.png)
![Configuración del Job 2.3](../Images/BDAW3.png)


> **Descripción:** El job `DifferentialBackup_AdventureWorks_Daily` fue programado para ejecutarse cada 24 horas (Diario).

#### Ejemplo de job para la creacion de un backup de log  de la base de datos AdventureWorks

![Configuración del Job 3.1](../Images/BLAW.png)
![Configuración del Job 3.2](../Images/BLAW2.png)
![Configuración del Job 3.3](../Images/BLAW3.png)


> **Descripción:** El job `logBackup_AdventureWorks` fue programado para ejecutarse cada 15 minutos.

---

#### Estructura de Carpetas y Archivos Generados
Se muestra la estructura de carpetas y los archivos de backup generados:

![Carpeta de Backups](../Images/CB.png)

![Carpeta de Backups](../Images/CBD.png)

![Carpeta de Backups](../Images/CBAW.png)

![Carpeta de Backups](../Images/AB.png)


> **Descripción:** Archivos de backup almacenados en la ruta correspondiente. Los nombres de los archivos incluyen un timestamp para evitar sobrescrituras.


### Pruebas de Recuperación de Datos

#### Recuperación mediante un Backup Completo (FULL)
Se realizó la restauración de un backup completo utilizando el archivo generado:

![Restauración Completa](../Images/RF.png)

> Posterior a la restauracion de ejecuto una consulta para verificar que los datos se restauraron correctamente.


![Restauración Completa](../Images/RF2.png)


---

#### Conclusion
- El stored procedure `sp_BackupDatabase` genera backups de manera correcta y organizada , ademas La automatización con SQL Server Agent garantiza que los backups se ejecuten según la programación definida y las pruebas de recuperación confirman que los backups son utilizables en caso de alguna problematica.