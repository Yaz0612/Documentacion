# **INFORME TÉCNICO**
## Creación Dinámica de Bases de Datos y Aplicación Web de Gestión

### Universidad Tecnologica de Tula-Tepeji
### Asignatura: Administración de Base de Datos
### Unidad I 

### Administración de base de Datos Relacionales

**Nombre:** Yazmin Acosta Jimenez


**Tecnologías Utilizadas:**  
- SQL Server (Stored Procedure)
- ASP.NET Core (Backend)
- React (Frontend)

---

## Indice

1. **Introducción**
2. **Objetivos**
3. **Desarrollo del Stored Procedure**
   - 3.1. Diseño del Stored Procedure
   - 3.2. Validaciones y Manejo de Errores
   - 3.3. Pruebas del Stored Procedure
4. **Desarrollo de la Aplicación Web**
   - 4.1. Arquitectura de la Aplicación
   - 4.2. Backend (ASP.NET Core)
   - 4.3. Frontend (React)
   - 4.4. Integración Backend-Frontend
5. **Dificultades y Soluciones**
6. **Conclusiones**

---

## 📌 **Introducción**
En este informe se describe el desarrollo de un procedimiento almacenado en SQL Server para la creación dinámica de bases de datos, así como la implementación de una aplicación web para gestionar estas bases de datos mediante una interfaz gráfica. Asi mismo se describen los objetivos, la implementación y los desafíos encontrados en el proceso asi como su solución.

---

## 🎯 **Objetivos**
✔ Implementar un procedimiento almacenado en SQL Server para la creación de bases de datos con parámetros personalizados con configuraciones específicas, como ubicación de archivos, tamaño inicial, crecimiento y filegroups.  
✔ Desarrollar una aplicación web que permita la gestión de bases de datos a través de una interfaz gráfica.  
✔ Aplicar buenas prácticas en seguridad y validación de datos.  

---

## 📃 **Desarrollo del Stored Procedure**
###  3.1. Creación del Procedimiento Almacenado en SQL Server
Se diseñó un stored procedure que permite la creación dinámica de bases de datos con los siguientes parámetros:
- **Nombre de la base de datos:** Nombre para la nueva base de datos(unico).
- **Rutas de archivos MDF y LDF:** Ubicación de los archivos de datos y logs.
- **Tamaño inicial y crecimiento:** Configuración del tamaño inicial y crecimiento de los archivos MDF y LDF.
- **Filegroup secundario:** Opcional, permite agregar un filegroup secundario con su respectivo archivo NDF.

### 3.2. Validaciones y Manejo de Errores

El procedimiento incluye validaciones para:

- **Evitar duplicados:** Verifica si la base de datos ya existe.
- **Rutas válidas:** Asegura que las rutas de los archivos MDF y LDF no estén vacías.
- **Valores positivos:** Valida que los tamaños iniciales y crecimientos sean valores positivos.

El manejo de errores se realiza mediante bloques `TRY...CATCH`, capturando y mostrando mensajes de error detallados en caso de fallos.

### 3.3. Pruebas del Stored Procedure

El procedimiento almacenado fue probado en SQL Server Management Studio con diferentes combinaciones de parámetros, verificando que:

- Se crean correctamente las bases de datos con los datos especificados.
- Se manejan adecuadamente los errores, como rutas inválidas o nombres duplicados.

---

## 🌐 Desarrollo de la Aplicación Web

### 4.1. Arquitectura de la Aplicación
La aplicación web sigue una arquitectura cliente-servidor:

- **Backend:** Desarrollado en ASP.NET Core, expone endpoints para crear y listar bases de datos.
- **Frontend:** Desarrollado en React, proporciona una interfaz gráfica que sirvio para interactuar con el backend.

### 4.2. Backend (ASP.NET Core)

El backend consta de:

- **Modelo `BaseDatos`:** Representa los datos necesarios para crear la base de datos.
- **Controlador `BaseDatosController`:** Expone dos endpoints:
  - `POST /api/BaseDatos/crear`: Crea una nueva base de datos.
  - `GET /api/BaseDatos/listar`: Lista las bases de datos existentes.

Se implementaron validaciones en el backend para asegurar que los datos enviados por el frontend sean correctos.

### 4.3. Frontend (React)

El frontend consta de dos vistas principales:

- **Crear Base de Datos:** Permite al usuario ingresar los parámetros necesarios para crear una nueva base de datos.
- **Listar Bases de Datos:** Muestra las bases de datos existentes en el servidor.

Se utilizó la librería `axios` para realizar las solicitudes HTTP al backend y `SweetAlert2` para mostrar mensajes de éxito o error.

### 4.4. Integración Backend-Frontend

La integración se realizó mediante solicitudes HTTP (POST y GET) desde el frontend al backend. El backend ejecuta el stored procedure en SQL Server y devuelve una respuesta al frontend, que muestra el resultado al usuario.

---
## ❗💡Dificultades y Soluciones

### 5.1. Validación de Rutas de Archivos

**Dificultad:**  
Asegurar que las rutas de los archivos MDF y LDF sean válidas y que no existan archivos con el mismo nombre.

**Solución:**  
Se implementaron validaciones en el backend para verificar la existencia de las rutas y archivos antes de ejecutar el stored procedure.

### 5.2. Manejo de Errores en el Frontend

**Dificultad:**  
Mostrar mensajes de error claros y amigables al usuario en caso de fallos.

**Solución:**  
Se utilizó la librería `SweetAlert2` para mostrar mensajes de error detallados y estilizados.

---

## ✏️ Conclusiones

El proyecto cumplió con los objetivos establecidos, permitiendo la creación dinámica de bases de datos en SQL Server y proporcionando una interfaz web para su gestión. Se aplicaron buenas prácticas en seguridad y validación de datos, asegurando un sistema funcional y confiable.

---

