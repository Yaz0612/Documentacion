## Codigo Fuente

### Backend (ASP.NET Core)
**Modelo**
```c#

namespace GestionBasesDeDatos.Server.Models
{
    public class BaseDatos
    {
        public string NombreDB { get; set; }
        public string RutaMDF { get; set; }
        public int TamanioInicialMDF { get; set; }
        public int CrecimientoMDF { get; set; }
        public string RutaLDF { get; set; }
        public int TamanioInicialLDF { get; set; }
        public int CrecimientoLDF { get; set; }
        public string RutaSecundaria { get; set; } 
        public int TamanioInicialSecundario { get; set; }
        public int CrecimientoSecundario { get; set; }

    }
}

```
**Controller**
```c#
using GestionBasesDeDatos.Server.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.IO;

namespace GestionBasesDeDatos.Server.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BaseDatosController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<BaseDatosController> _logger;

        public BaseDatosController(IConfiguration configuration, ILogger<BaseDatosController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        [HttpPost("crear")]
        public IActionResult CrearBaseDeDatos([FromBody] BaseDatos model)
        {
            try
            {
                if (string.IsNullOrEmpty(model.NombreDB) || string.IsNullOrEmpty(model.RutaMDF) || string.IsNullOrEmpty(model.RutaLDF))
                {
                    return BadRequest(new { mensaje = "Todos los campos son obligatorios." });
                }

                if (model.TamanioInicialMDF <= 0 || model.CrecimientoMDF <= 0 || model.TamanioInicialLDF <= 0 || model.CrecimientoLDF <= 0)
                {
                    return BadRequest(new { mensaje = "Los tamaños y crecimientos deben ser valores positivos." });
                }

                string rutaCompletaMDF = Path.Combine(model.RutaMDF, $"{model.NombreDB}.mdf");
                string rutaCompletaLDF = Path.Combine(model.RutaLDF, $"{model.NombreDB}_log.ldf");
                string rutaCompletaSec = Path.Combine(model.RutaSecundaria, $"{model.NombreDB}_secundario.ndf");

                if (System.IO.File.Exists(rutaCompletaMDF) || System.IO.File.Exists(rutaCompletaLDF))
                {
                    return BadRequest(new { mensaje = "Uno o más archivos ya existen. Elimínalos manualmente o cambia el nombre de la base de datos." });
                }

                if (!Directory.Exists(model.RutaMDF) || !Directory.Exists(model.RutaLDF))
                {
                    return BadRequest(new { mensaje = "Una o más rutas de carpetas no existen. Verifica las rutas e intenta nuevamente." });
                }

                string connectionString = _configuration.GetConnectionString("DefaultConnection");

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    using (SqlCommand command = new SqlCommand("CrearBaseDeDatos", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@NombreDB", model.NombreDB);
                        command.Parameters.AddWithValue("@RutaMDF", rutaCompletaMDF);
                        command.Parameters.AddWithValue("@TamanioInicialMDF", model.TamanioInicialMDF);
                        command.Parameters.AddWithValue("@CrecimientoMDF", model.CrecimientoMDF);
                        command.Parameters.AddWithValue("@RutaLDF", rutaCompletaLDF);
                        command.Parameters.AddWithValue("@TamanioInicialLDF", model.TamanioInicialLDF);
                        command.Parameters.AddWithValue("@CrecimientoLDF", model.CrecimientoLDF);

                        // (opcionales)
                        command.Parameters.AddWithValue("@RutaSecundaria", (object)model.RutaSecundaria ?? DBNull.Value);
                        command.Parameters.AddWithValue("@TamanioInicialSecundario", (object)model.TamanioInicialSecundario ?? DBNull.Value);
                        command.Parameters.AddWithValue("@CrecimientoSecundario", (object)model.CrecimientoSecundario ?? DBNull.Value);

                        command.ExecuteNonQuery();
                    }
                }

                _logger.LogInformation($"Base de datos {model.NombreDB} creada exitosamente.");
                return Ok(new { mensaje = "Base de datos creada exitosamente." });
            }
            catch (SqlException ex)
            {
                _logger.LogError(ex, "Error de SQL al crear la base de datos.");
                return StatusCode(500, new { mensaje = "Ocurrió un error al crear la base de datos. Por favor, verifica los datos e inténtalo de nuevo." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado al crear la base de datos.");
                return StatusCode(500, new { mensaje = "Error: " + ex.Message });
            }
        }

        [HttpGet("listar")]
        public IActionResult ListarBasesDeDatos()
        {
            try
            {
                string connectionString = _configuration.GetConnectionString("DefaultConnection");
                List<string> basesDeDatos = new List<string>();

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    string query = "SELECT name FROM sys.databases WHERE database_id > 4";
                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                basesDeDatos.Add(reader["name"].ToString());
                            }
                        }
                    }
                }

                return Ok(basesDeDatos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al listar las bases de datos.");
                return StatusCode(500, new { mensaje = "Error: " + ex.Message });
            }
        }
    }
}
```

### Frontend (React)
**Crear base de datos**
```jsx
import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";

const CrearBaseDeDatos = () => {
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        NombreDB: "",
        RutaMDF: "",
        TamanioInicialMDF: 0,
        CrecimientoMDF: 0,
        RutaLDF: "",
        TamanioInicialLDF: 0,
        CrecimientoLDF: 0,
        RutaSecundaria: "",
        TamanioInicialSecundario: 0,
        CrecimientoSecundario: 0,
    });
    const [mostrarFilegroup, setMostrarFilegroup] = useState(false); 

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({ ...formData, [name]: value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (
            !formData.NombreDB ||
            !formData.RutaMDF ||
            !formData.RutaLDF ||
            formData.TamanioInicialMDF <= 0 ||
            formData.CrecimientoMDF <= 0 ||
            formData.TamanioInicialLDF <= 0 ||
            formData.CrecimientoLDF <= 0
        ) {
            Swal.fire({
                icon: "error",
                title: "Error",
                text: "Todos los campos son obligatorios y los valores deben ser positivos.",
            });
            return;
        }

        try {
            const response = await axios.post("https://localhost:7077/api/BaseDatos/crear", formData);

            Swal.fire({
                icon: "success",
                title: "¡Exito!",
                text: response.data.mensaje,
            });

            setFormData({
                NombreDB: "",
                RutaMDF: "",
                TamanioInicialMDF: 0,
                CrecimientoMDF: 0,
                RutaLDF: "",
                TamanioInicialLDF: 0,
                CrecimientoLDF: 0,
                RutaSecundaria: "",
                TamanioInicialSecundario: 0,
                CrecimientoSecundario: 0,
            });
            setMostrarFilegroup(false); 
        } catch (err) {
            Swal.fire({
                icon: "error",
                title: "Error",
                text: err.response?.data?.mensaje || "Error al crear la base de datos. Por favor, verifica los datos e inténtalo de nuevo.",
            });
        }
    };

    return (
        <div className="container-fluid d-flex justify-content-center align-items-center pt-5 mt-5" style={{ width: '1468px' }}>
            <div className="col-12 col-md-10 col-lg-8 col-xl-6">
                <h2 className="text-center mb-4">Crear Base de Datos</h2>
                <form onSubmit={handleSubmit} className="card p-4 shadow">
                    <div className="mb-3">
                        <label className="form-label">Nombre de la Base de Datos</label>
                        <input
                            type="text"
                            name="NombreDB"
                            value={formData.NombreDB}
                            onChange={handleChange}
                            className="form-control"
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Ruta del Archivo MDF</label>
                        <input
                            type="text"
                            name="RutaMDF"
                            value={formData.RutaMDF}
                            onChange={handleChange}
                            className="form-control"
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Tamanio Inicial MDF</label>
                        <input
                            type="number"
                            name="TamanioInicialMDF"
                            value={formData.TamanioInicialMDF}
                            onChange={handleChange}
                            className="form-control"
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Crecimiento MDF </label>
                        <input
                            type="number"
                            name="CrecimientoMDF"
                            value={formData.CrecimientoMDF}
                            onChange={handleChange}
                            className="form-control"
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Ruta del Archivo LDF</label>
                        <input
                            type="text"
                            name="RutaLDF"
                            value={formData.RutaLDF}
                            onChange={handleChange}
                            className="form-control"
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Tamanio Inicial LDF</label>
                        <input
                            type="number"
                            name="TamanioInicialLDF"
                            value={formData.TamanioInicialLDF}
                            onChange={handleChange}
                            className="form-control"
                            required
                        />
                    </div>
                    <div className="mb-3">
                        <label className="form-label">Crecimiento LDF</label>
                        <input
                            type="number"
                            name="CrecimientoLDF"
                            value={formData.CrecimientoLDF}
                            onChange={handleChange}
                            className="form-control"
                            required
                        />
                    </div>

                    <div className="mb-3 form-check">
                        <input
                            type="checkbox"
                            className="form-check-input"
                            id="mostrarFilegroup"
                            checked={mostrarFilegroup}
                            onChange={() => setMostrarFilegroup(!mostrarFilegroup)}
                        />
                        <label className="form-check-label" htmlFor="mostrarFilegroup">
                           Agregar un filegroup secundario
                        </label>
                    </div>


                    {mostrarFilegroup && (
                        <>
                            <div className="mb-3">
                                <label className="form-label">Ruta del Filegroup Secundario</label>
                                <input
                                    type="text"
                                    name="RutaSecundaria"
                                    value={formData.RutaSecundaria}
                                    onChange={handleChange}
                                    className="form-control"
                                />
                            </div>
                            <div className="mb-3">
                                <label className="form-label">Tamanio Inicial del Filegroup Secundario</label>
                                <input
                                    type="number"
                                    name="TamanioInicialSecundario"
                                    value={formData.TamanioInicialSecundario}
                                    onChange={handleChange}
                                    className="form-control"
                                />
                            </div>
                            <div className="mb-3">
                                <label className="form-label">Crecimiento del Filegroup Secundario</label>
                                <input
                                    type="number"
                                    name="CrecimientoSecundario"
                                    value={formData.CrecimientoSecundario}
                                    onChange={handleChange}
                                    className="form-control"
                                />
                            </div>
                        </>
                    )}

                    <div className="d-flex justify-content-center align-items-center mt-4">
                        <button
                            className="btn"
                            style={{
                                backgroundColor: "#C8D9E6",
                                color: "#000000",
                                width: "300px",
                            }}
                        >
                            Crear Base de Datos
                        </button>
                    </div>
                </form>
                <div className="d-flex justify-content-center align-items-center mt-4">
                    <button
                        className="btn"
                        style={{
                            backgroundColor: "#F5EFEB",
                            color: "#000000",
                            width: "300px",
                            margin: "50px"
                        }}
                        onClick={() => navigate("/listar-bases-de-datos")}
                    >
                        Ver Bases de Datos Existentes
                    </button>
                </div>
            </div>
        </div>
    );
};

export default CrearBaseDeDatos;
```
**Listar bases de datos**
```jsx
import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import BD from "../../assets/base-de-datos.png";

const ListarBasesDeDatos = () => {
    const navigate = useNavigate();
    const [basesDeDatos, setBasesDeDatos] = useState([]);
    const [error, setError] = useState("");

    const fetchBasesDeDatos = async () => {
        try {
            const response = await axios.get("https://localhost:7077/api/BaseDatos/listar");
            setBasesDeDatos(response.data);
        } catch (err) {
            setError("Error al obtener las bases de datos.");
        }
    };

    useEffect(() => {
        fetchBasesDeDatos();
    }, []);

    return (
        <div className="container-fluid d-flex justify-content-center align-items-center pt-5 mt-5">
            <div className="col-10">
                <h2 className="text-center mb-4">Bases de Datos Existentes</h2>
                {error && <div className="alert alert-danger">{error}</div>}
                <div className="row row-cols-1 row-cols-md-6 g-4">
                    {basesDeDatos.map((db, index) => (
                        <div key={index} className="col">
                            <div className="card h-100 shadow">
                                <div className="d-flex justify-content-center align-items-center p-3">
                                    <img
                                        src={BD}
                                        style={{ width: "45%", height: "auto" }}
                                        className="card-img-top"
                                        alt="Base de datos"
                                    />
                                </div>
                                <div className="card-body text-center">
                                    <h5 className="card-title">{db}</h5>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                <div className="d-flex justify-content-center align-items-center mt-4">
                    <button
                        className="btn"
                        style={{
                            backgroundColor: "#C8D9E6",
                            color: "#000000",
                            width: "300px", 
                            margin: "50px"

                        }}
                        onClick={() => navigate("/crear-base-de-datos")}
                    >
                        Crear Nueva Base de Datos
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ListarBasesDeDatos;

```

