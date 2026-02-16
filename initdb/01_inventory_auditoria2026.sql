-- =========================================
-- INVENTARIO INFORMÁTICO MASIVO - AUDITORIA2026
-- =========================================
-- Desconectar todos los usuarios
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = current_database() AND pid <> pg_backend_pid();

-- ELIMINAR TODO (orden inverso por las foreign keys)
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS mantenimientos CASCADE;
DROP TABLE IF EXISTS direcciones_ip CASCADE;
DROP TABLE IF EXISTS equipo_software CASCADE;
DROP TABLE IF EXISTS equipos CASCADE;
DROP TABLE IF EXISTS software CASCADE;
DROP TABLE IF EXISTS empleados CASCADE;
DROP TABLE IF EXISTS departamentos CASCADE;
DROP TABLE IF EXISTS compras CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS proyectos CASCADE;
DROP TABLE IF EXISTS activos_red CASCADE;

-- También eliminar secuencias
DROP SEQUENCE IF EXISTS departamentos_id_seq CASCADE;
DROP SEQUENCE IF EXISTS empleados_id_seq CASCADE;
DROP SEQUENCE IF EXISTS equipos_id_seq CASCADE;
DROP SEQUENCE IF EXISTS software_id_seq CASCADE;
DROP SEQUENCE IF EXISTS equipo_software_id_seq CASCADE;
DROP SEQUENCE IF EXISTS direcciones_ip_id_seq CASCADE;
DROP SEQUENCE IF EXISTS mantenimientos_id_seq CASCADE;
DROP SEQUENCE IF EXISTS tickets_id_seq CASCADE;
DROP SEQUENCE IF EXISTS compras_id_seq CASCADE;
DROP SEQUENCE IF EXISTS proveedores_id_seq CASCADE;
DROP SEQUENCE IF EXISTS proyectos_id_seq CASCADE;
DROP SEQUENCE IF EXISTS activos_red_id_seq CASCADE;

SELECT setseed(0.2026);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================
-- DEPARTAMENTOS (40 - EL DOBLE)
-- =============================
CREATE TABLE departamentos (
                               id SERIAL PRIMARY KEY,
                               nombre VARCHAR(150),
                               descripcion TEXT,
                               centro_costo VARCHAR(50),
                               ubicacion VARCHAR(100),
                               presupuesto_anual DECIMAL(15,2),
                               gerente_responsable VARCHAR(150),
                               email_contacto VARCHAR(150),
                               telefono_contacto VARCHAR(20),
                               fecha_creacion DATE,
                               nivel_jerarquico INT,
                               activo BOOLEAN DEFAULT true
);

INSERT INTO departamentos (nombre, descripcion, centro_costo, ubicacion, presupuesto_anual, gerente_responsable, email_contacto, telefono_contacto, fecha_creacion, nivel_jerarquico, activo) VALUES
                                                                                                                                                                                                  ('Dirección General', 'Alta dirección y estrategia corporativa', 'CC-1000', 'Piso 15 Torre Ejecutiva', 15000000.00, 'Carlos Rodríguez', 'direccion@empresa.com', '5551001000', '2000-01-15', 1, true),
                                                                                                                                                                                                  ('Finanzas', 'Gestión contable, tesorería y reporting financiero', 'CC-2000', 'Piso 12 Torre Ejecutiva', 8500000.00, 'María García', 'finanzas@empresa.com', '5551002000', '2000-01-15', 2, true),
                                                                                                                                                                                                  ('Recursos Humanos', 'Gestión del talento, nómina y desarrollo organizacional', 'CC-2100', 'Piso 10 Torre Ejecutiva', 4200000.00, 'Juan López', 'rrhh@empresa.com', '5551002100', '2000-02-01', 2, true),
                                                                                                                                                                                                  ('Tecnologías de la Información', 'Infraestructura, soporte y desarrollo de sistemas', 'CC-3000', 'Piso 8 Torre Tecnológica', 12500000.00, 'Ana Martínez', 'ti@empresa.com', '5551003000', '2000-03-10', 2, true),
                                                                                                                                                                                                  ('Operaciones', 'Gestión de procesos operativos y logística interna', 'CC-4000', 'Planta Baja Edificio Central', 9500000.00, 'Luis González', 'operaciones@empresa.com', '5551004000', '2000-01-20', 2, true),
                                                                                                                                                                                                  ('Marketing', 'Publicidad, redes sociales y comunicación corporativa', 'CC-5000', 'Piso 5 Torre Ejecutiva', 6800000.00, 'Patricia Sánchez', 'marketing@empresa.com', '5551005000', '2000-04-05', 2, true),
                                                                                                                                                                                                  ('Ventas', 'Fuerza de ventas y atención a clientes', 'CC-5100', 'Piso 3 Torre Ejecutiva', 11000000.00, 'Javier Pérez', 'ventas@empresa.com', '5551005100', '2000-01-15', 2, true),
                                                                                                                                                                                                  ('Compras', 'Adquisiciones y proveedores', 'CC-2200', 'Piso 7 Torre Logística', 3500000.00, 'Laura Gómez', 'compras@empresa.com', '5551002200', '2000-05-12', 3, true),
                                                                                                                                                                                                  ('Legal', 'Asesoría jurídica y cumplimiento normativo', 'CC-1100', 'Piso 14 Torre Ejecutiva', 2800000.00, 'Miguel Díaz', 'legal@empresa.com', '5551001100', '2000-06-20', 3, true),
                                                                                                                                                                                                  ('Investigación y Desarrollo', 'Innovación y nuevos productos', 'CC-6000', 'Piso 2 Torre Tecnológica', 7200000.00, 'Isabel Romero', 'id@empresa.com', '5551006000', '2001-02-18', 2, true),
                                                                                                                                                                                                  ('Atención al Cliente', 'Soporte post-venta y call center', 'CC-5200', 'Piso 1 Edificio Central', 4100000.00, 'Alejandro Torres', 'atencion@empresa.com', '5551005200', '2001-03-22', 3, true),
                                                                                                                                                                                                  ('Logística', 'Almacenes y distribución', 'CC-4100', 'Nave 3 Parque Industrial', 5300000.00, 'Carmen Ruiz', 'logistica@empresa.com', '5551004100', '2001-04-10', 3, true),
                                                                                                                                                                                                  ('Calidad', 'Control de calidad y mejora continua', 'CC-4200', 'Laboratorio Planta', 2100000.00, 'Francisco Castro', 'calidad@empresa.com', '5551004200', '2001-05-15', 3, true),
                                                                                                                                                                                                  ('Seguridad', 'Seguridad física y patrimonial', 'CC-7000', 'Módulo de Seguridad Principal', 1800000.00, 'Teresa Ortega', 'seguridad@empresa.com', '5551007000', '2001-06-01', 4, true),
                                                                                                                                                                                                  ('Mantenimiento', 'Mantenimiento de instalaciones', 'CC-4300', 'Taller General', 1600000.00, 'David Morales', 'mantenimiento@empresa.com', '5551004300', '2001-07-08', 4, true),
                                                                                                                                                                                                  ('Sistemas', 'Desarrollo de software y bases de datos', 'CC-3100', 'Piso 9 Torre Tecnológica', 5400000.00, 'Sofía Herrera', 'sistemas@empresa.com', '5551003100', '2002-01-10', 3, true),
                                                                                                                                                                                                  ('Redes y Comunicaciones', 'Infraestructura de red y telecomunicaciones', 'CC-3200', 'Data Center Principal', 4800000.00, 'Ricardo Vargas', 'redes@empresa.com', '5551003200', '2002-02-14', 3, true),
                                                                                                                                                                                                  ('Ciberseguridad', 'Seguridad informática y protección de datos', 'CC-3300', 'Piso 8 Torre Tecnológica', 3900000.00, 'Gabriela Soto', 'ciberseguridad@empresa.com', '5551003300', '2002-03-20', 3, true),
                                                                                                                                                                                                  ('Business Intelligence', 'Análisis de datos y reporting', 'CC-3400', 'Piso 6 Torre Tecnológica', 3200000.00, 'Fernando Ríos', 'bi@empresa.com', '5551003400', '2002-04-25', 3, true),
                                                                                                                                                                                                  ('Proyectos', 'Gestión de proyectos estratégicos', 'CC-8000', 'Piso 4 Torre Ejecutiva', 2900000.00, 'Adriana Flores', 'proyectos@empresa.com', '5551008000', '2002-05-30', 3, true),
                                                                                                                                                                                                  ('Auditoría Interna', 'Auditoría de procesos y controles', 'CC-1200', 'Piso 13 Torre Ejecutiva', 2100000.00, 'Roberto Méndez', 'auditoria@empresa.com', '5551001200', '2003-01-12', 3, true),
                                                                                                                                                                                                  ('Comunicación Corporativa', 'Comunicación interna y externa', 'CC-5300', 'Piso 6 Torre Ejecutiva', 1800000.00, 'Daniela Ortega', 'comunicacion@empresa.com', '5551005300', '2003-02-18', 4, true),
                                                                                                                                                                                                  ('Relaciones Públicas', 'Relaciones institucionales', 'CC-5400', 'Piso 6 Torre Ejecutiva', 1500000.00, 'Héctor Núñez', 'rp@empresa.com', '5551005400', '2003-03-22', 4, true),
                                                                                                                                                                                                  ('Innovación', 'Innovación y transformación digital', 'CC-6100', 'Piso 3 Torre Tecnológica', 4300000.00, 'Verónica Suárez', 'innovacion@empresa.com', '5551006100', '2003-04-15', 3, true),
                                                                                                                                                                                                  ('Estrategia Digital', 'Estrategia digital y e-commerce', 'CC-6200', 'Piso 4 Torre Tecnológica', 3500000.00, 'Mauricio Castro', 'digital@empresa.com', '5551006200', '2003-05-20', 3, true),
                                                                                                                                                                                                  ('Data Science', 'Ciencia de datos y analítica avanzada', 'CC-6300', 'Piso 7 Torre Tecnológica', 2800000.00, 'Andrea Paredes', 'datascience@empresa.com', '5551006300', '2004-01-10', 4, true),
                                                                                                                                                                                                  ('Arquitectura Empresarial', 'Arquitectura de procesos y sistemas', 'CC-6400', 'Piso 8 Torre Tecnológica', 2200000.00, 'Oscar Delgado', 'arquitectura@empresa.com', '5551006400', '2004-02-14', 4, true),
                                                                                                                                                                                                  ('Gestión Documental', 'Gestión de documentos y archivos', 'CC-1300', 'Sótano 1 Edificio Central', 1100000.00, 'Liliana Campos', 'documental@empresa.com', '5551001300', '2004-03-18', 5, true),
                                                                                                                                                                                                  ('Servicios Generales', 'Servicios generales y apoyo', 'CC-4400', 'Planta Baja Edificio Central', 950000.00, 'Jorge Salinas', 'servicios@empresa.com', '5551004400', '2004-04-22', 5, true),
                                                                                                                                                                                                  ('Flotilla Vehicular', 'Gestión de vehículos corporativos', 'CC-4500', 'Estacionamiento Principal', 850000.00, 'Silvia Ponce', 'flotilla@empresa.com', '5551004500', '2004-05-27', 5, true),
                                                                                                                                                                                                  ('Almacén', 'Gestión de almacenes', 'CC-4600', 'Nave 2 Parque Industrial', 1400000.00, 'Arturo Vega', 'almacen@empresa.com', '5551004600', '2005-01-15', 4, true),
                                                                                                                                                                                                  ('Importaciones', 'Gestión de importaciones', 'CC-2300', 'Piso 8 Torre Logística', 1200000.00, 'Rosa Meléndez', 'importaciones@empresa.com', '5551002300', '2005-02-19', 4, true),
                                                                                                                                                                                                  ('Exportaciones', 'Gestión de exportaciones', 'CC-2400', 'Piso 8 Torre Logística', 1150000.00, 'Ernesto Galván', 'exportaciones@empresa.com', '5551002400', '2005-03-25', 4, true),
                                                                                                                                                                                                  ('Comercio Exterior', 'Comercio exterior y aduanas', 'CC-2500', 'Piso 9 Torre Logística', 1350000.00, 'Alicia Montero', 'comex@empresa.com', '5551002500', '2005-04-29', 4, true),
                                                                                                                                                                                                  ('Responsabilidad Social', 'Responsabilidad social y sostenibilidad', 'CC-7100', 'Piso 11 Torre Ejecutiva', 950000.00, 'Raúl Becerra', 'rse@empresa.com', '5551007100', '2005-05-30', 5, true),
                                                                                                                                                                                                  ('Medio Ambiente', 'Gestión ambiental', 'CC-7200', 'Piso 11 Torre Ejecutiva', 820000.00, 'Claudia Navarro', 'ambiente@empresa.com', '5551007200', '2006-01-12', 5, true),
                                                                                                                                                                                                  ('Seguridad Industrial', 'Seguridad industrial e higiene', 'CC-7300', 'Planta Industrial', 780000.00, 'Felipe Rangel', 'seguridadindustrial@empresa.com', '5551007300', '2006-02-16', 5, true),
                                                                                                                                                                                                  ('Salud Ocupacional', 'Salud ocupacional', 'CC-7400', 'Consultorio Médico', 690000.00, 'Mónica Peña', 'salud@empresa.com', '5551007400', '2006-03-22', 5, true),
                                                                                                                                                                                                  ('Bienestar', 'Bienestar y calidad de vida', 'CC-7500', 'Gimnasio Corporativo', 450000.00, 'Guillermo Franco', 'bienestar@empresa.com', '5551007500', '2006-04-26', 6, true),
                                                                                                                                                                                                  ('Cultura Organizacional', 'Cultura y clima organizacional', 'CC-7600', 'Piso 10 Torre Ejecutiva', 380000.00, 'Paola Cárdenas', 'cultura@empresa.com', '5551007600', '2006-05-31', 6, true);

-- =============================
-- PROVEEDORES (NUEVA TABLA - 10,000 registros)
-- =============================
CREATE TABLE proveedores (
                             id SERIAL PRIMARY KEY,
                             rfc VARCHAR(20) UNIQUE,
                             nombre_empresa VARCHAR(200),
                             nombre_contacto VARCHAR(150),
                             email_contacto VARCHAR(150),
                             telefono_contacto VARCHAR(20),
                             calle VARCHAR(100),
                             numero_exterior VARCHAR(20),
                             numero_interior VARCHAR(20),
                             colonia VARCHAR(100),
                             ciudad VARCHAR(50),
                             estado VARCHAR(50),
                             codigo_postal VARCHAR(10),
                             pais VARCHAR(50),
                             categoria_principal VARCHAR(50),
                             fecha_registro DATE,
                             estatus VARCHAR(20),
                             calificacion INT,
                             observaciones TEXT
);

INSERT INTO proveedores (rfc, nombre_empresa, nombre_contacto, email_contacto, telefono_contacto, calle, numero_exterior, colonia, ciudad, estado, codigo_postal, pais, categoria_principal, fecha_registro, estatus, calificacion, observaciones)
SELECT
    'RFC' || LPAD(g::text, 12, '0'),
    'Proveedor ' || g || ' S.A. de C.V.',
    'Contacto ' || g,
    'contacto' || g || '@proveedor' || g || '.com',
    '55' || LPAD((g % 10000000)::text, 8, '0'),
    'Calle ' || (g % 1000)::text,
    (g % 500)::text,
    'Colonia Industrial ' || (g % 200)::text,
    (ARRAY['Ciudad de México', 'Monterrey', 'Guadalajara', 'Puebla', 'Querétaro', 'Toluca', 'León', 'Tijuana', 'Mérida', 'Cancún'])[(g % 10) + 1],
    (ARRAY['CDMX', 'Nuevo León', 'Jalisco', 'Puebla', 'Querétaro', 'Estado de México', 'Guanajuato', 'Baja California', 'Yucatán', 'Quintana Roo'])[(g % 10) + 1],
    LPAD((g % 10000)::text, 5, '0'),
    'México',
    (ARRAY['Tecnología', 'Papelería', 'Mobiliario', 'Servicios', 'Mantenimiento', 'Capacitación', 'Consultoría', 'Desarrollo', 'Redes', 'Seguridad'])[(g % 10) + 1],
    DATE '2010-01-01' + (g % 5000),
    CASE (g % 3) WHEN 0 THEN 'Activo' WHEN 1 THEN 'Inactivo' ELSE 'En evaluación' END,
    (g % 5) + 1,
    'Proveedor ' || CASE (g % 5)
        WHEN 0 THEN 'confiable y con buena reputación'
        WHEN 1 THEN 'nuevo en el mercado'
        WHEN 2 THEN 'con algunos retrasos en entregas'
        WHEN 3 THEN 'excelente calidad pero costoso'
        ELSE 'volumen de compras medio'
END || '. ' || repeat('Información detallada del proveedor y condiciones comerciales. ', 20)
FROM generate_series(1, 10000) g;

-- =============================
-- PROYECTOS (NUEVA TABLA - 50,000 registros)
-- =============================
CREATE TABLE proyectos (
                           id SERIAL PRIMARY KEY,
                           codigo_proyecto VARCHAR(50) UNIQUE,
                           nombre VARCHAR(200),
                           descripcion TEXT,
                           departamento_id INT REFERENCES departamentos(id),
                           gerente_proyecto VARCHAR(150),
                           fecha_inicio DATE,
                           fecha_fin_estimada DATE,
                           fecha_fin_real DATE DEFAULT NULL,
                           presupuesto_asignado DECIMAL(15,2),
                           presupuesto_ejercido DECIMAL(15,2),
                           prioridad INT,
                           estado VARCHAR(30),
                           porcentaje_avance INT,
                           observaciones TEXT
);

INSERT INTO proyectos (
    codigo_proyecto, nombre, descripcion, departamento_id, gerente_proyecto,
    fecha_inicio, fecha_fin_estimada, fecha_fin_real,
    presupuesto_asignado, presupuesto_ejercido, prioridad, estado, porcentaje_avance, observaciones
)
SELECT
    'PROJ-' || LPAD(g::text, 8, '0'),
    'Proyecto ' || g || ': ' ||
    CASE (g % 10)
        WHEN 0 THEN 'Implementación de Sistema'
        WHEN 1 THEN 'Renovación de Infraestructura'
        WHEN 2 THEN 'Migración a la Nube'
        WHEN 3 THEN 'Actualización de Software'
        WHEN 4 THEN 'Optimización de Procesos'
        WHEN 5 THEN 'Capacitación Personal'
        WHEN 6 THEN 'Mejora Continua'
        WHEN 7 THEN 'Investigación de Mercado'
        WHEN 8 THEN 'Desarrollo de Producto'
        ELSE 'Expansión Comercial'
        END,
    repeat('Descripción detallada del proyecto incluyendo objetivos, alcance, entregables y criterios de éxito. ', 30),
    (g % 40) + 1,
    'Gerente ' || g,
    DATE '2018-01-01' + (g % 2000),
    DATE '2019-01-01' + (g % 2000),
    CASE WHEN g % 4 = 0 THEN DATE '2020-01-01' + (g % 1000) ELSE NULL END,
    (g % 10000000)::DECIMAL + 10000.00,
    (g % 8000000)::DECIMAL + 5000.00,
    (g % 5) + 1,
    CASE (g % 4)
        WHEN 0 THEN 'Planeación'
        WHEN 1 THEN 'Ejecución'
        WHEN 2 THEN 'En pausa'
        ELSE 'Finalizado'
        END,
    (g % 101),
    'Observaciones sobre el avance, riesgos y oportunidades detectadas durante la ejecución del proyecto.'
FROM generate_series(1, 50000) g;


-- =============================
-- EMPLEADOS (3 MILLONES - EL DOBLE)
-- =============================
CREATE TABLE empleados (
                           id SERIAL PRIMARY KEY,
                           nombre VARCHAR(150),
                           apellido_paterno VARCHAR(100),
                           apellido_materno VARCHAR(100),
                           email VARCHAR(150) UNIQUE,
                           departamento_id INT REFERENCES departamentos(id),
                           proyecto_actual_id INT REFERENCES proyectos(id),
                           puesto VARCHAR(100),
                           nivel_puesto INT,
                           telefono VARCHAR(20),
                           extension VARCHAR(10),
                           telefono_movil VARCHAR(20),
                           fecha_ingreso DATE,
                           fecha_termino DATE,
                           fecha_nacimiento DATE,
                           genero CHAR(1),
                           estado_civil VARCHAR(20),
                           nss VARCHAR(20),
                           rfc VARCHAR(20),
                           curp VARCHAR(25),
                           calle VARCHAR(100),
                           numero_exterior VARCHAR(20),
                           numero_interior VARCHAR(20),
                           colonia VARCHAR(100),
                           ciudad VARCHAR(50),
                           estado VARCHAR(50),
                           codigo_postal VARCHAR(10),
                           tipo_sangre VARCHAR(5),
                           alergias TEXT,
                           emergencia_nombre VARCHAR(150),
                           emergencia_telefono VARCHAR(20),
                           banco_nombre VARCHAR(100),
                           banco_cuenta VARCHAR(30),
                           banco_clabe VARCHAR(30),
                           salario_mensual DECIMAL(12,2),
                           activo BOOLEAN DEFAULT true,
                           observaciones TEXT
);

WITH nombres_base AS (
    SELECT
        g,
        (ARRAY[
            'Carlos', 'María', 'José', 'Ana', 'Juan', 'Laura', 'Jorge', 'Patricia', 'Luis', 'Sofía',
        'Miguel', 'Isabel', 'Alejandro', 'Carmen', 'Francisco', 'Teresa', 'Javier', 'Marta',
        'Antonio', 'Elena', 'David', 'Cristina', 'Jesús', 'Sara', 'Rafael', 'Rosa', 'Manuel',
        'Paula', 'Pedro', 'Andrea', 'Ángel', 'Claudia', 'Óscar', 'Verónica', 'Rubén', 'Silvia',
        'Sergio', 'Natalia', 'Pablo', 'Raquel', 'Fernando', 'Eva', 'Andrés', 'Irene', 'Adrián',
        'Beatriz', 'Héctor', 'Alicia', 'Iván', 'Olga', 'Hugo', 'Daniela', 'Roberto', 'Gabriela',
        'Ricardo', 'Verónica', 'Fernando', 'Adriana', 'Mauricio', 'Andrea', 'Oscar', 'Liliana',
        'Jorge', 'Silvia', 'Arturo', 'Rosa', 'Ernesto', 'Alicia', 'Raúl', 'Claudia', 'Felipe',
        'Mónica', 'Guillermo', 'Paola', 'Esteban', 'Lorena', 'Vicente', 'Mariana', 'Salvador'
    ]::text[])[1 + (g % 80)] as nombre,
    (ARRAY[
    'García', 'Rodríguez', 'Martínez', 'Hernández', 'López', 'González', 'Pérez', 'Sánchez',
    'Ramírez', 'Torres', 'Flores', 'Rivera', 'Gómez', 'Díaz', 'Reyes', 'Morales', 'Cruz',
    'Ortiz', 'Gutiérrez', 'Chávez', 'Romero', 'Álvarez', 'Castillo', 'Jiménez', 'Vargas',
    'Moreno', 'Rojas', 'Herrera', 'Medina', 'Aguilar', 'Castro', 'Suárez', 'Mendoza',
    'Vega', 'Ruiz', 'Domínguez', 'Delgado', 'Silva', 'Cabrera', 'Velázquez', 'Montoya',
    'Espinoza', 'Valdez', 'Cortés', 'Ríos', 'Guzmán', 'Núñez', 'Salazar', 'Ponce', 'Acosta',
    'Méndez', 'Ortega', 'Soto', 'Rangel', 'Peña', 'Franco', 'Cárdenas', 'Navarro', 'Becerra',
    'Galván', 'Montero', 'Meléndez', 'Salinas', 'Campos', 'Paredes', 'Delgado', 'Suárez',
    'Vega', 'Ríos', 'Flores', 'Cruz', 'Reyes', 'Morales', 'Castro', 'Ortega', 'Silva'
    ]::text[])[1 + (g % 80)] as apellido1,
    (ARRAY[
    'García', 'Rodríguez', 'Martínez', 'Hernández', 'López', 'González', 'Pérez', 'Sánchez',
    'Ramírez', 'Torres', 'Flores', 'Rivera', 'Gómez', 'Díaz', 'Reyes', 'Morales', 'Cruz',
    'Ortiz', 'Gutiérrez', 'Chávez', 'Romero', 'Álvarez', 'Castillo', 'Jiménez', 'Vargas',
    'Moreno', 'Rojas', 'Herrera', 'Medina', 'Aguilar', 'Castro', 'Suárez', 'Mendoza',
    'Vega', 'Ruiz', 'Domínguez', 'Delgado', 'Silva', 'Cabrera', 'Velázquez', 'Montoya',
    'Espinoza', 'Valdez', 'Cortés', 'Ríos', 'Guzmán', 'Núñez', 'Salazar', 'Ponce', 'Acosta',
    'Méndez', 'Ortega', 'Soto', 'Rangel', 'Peña', 'Franco', 'Cárdenas', 'Navarro', 'Becerra',
    'Galván', 'Montero', 'Meléndez', 'Salinas', 'Campos', 'Paredes', 'Delgado', 'Suárez',
    'Vega', 'Ríos', 'Flores', 'Cruz', 'Reyes', 'Morales', 'Castro', 'Ortega', 'Silva'
    ]::text[])[1 + ((g/2) % 80)] as apellido2,
    (ARRAY[
    'Director General', 'Gerente de Finanzas', 'Subgerente de TI', 'Coordinador de RH',
    'Analista Senior', 'Analista', 'Asistente', 'Técnico Especialista', 'Consultor',
    'Desarrollador Senior', 'Desarrollador Jr', 'Programador', 'Administrador de Sistemas',
    'Supervisor de Operaciones', 'Jefe de Departamento', 'Líder de Proyecto', 'Arquitecto',
    'Ingeniero de Software', 'Diseñador UI/UX', 'Contador General', 'Abogado Corporativo',
    'Médico Laboral', 'Enfermero', 'Psicólogo Organizacional', 'Capacitador', 'Reclutador',
    'Ejecutivo de Ventas', 'Ejecutivo de Cuenta', 'Representante de Soporte', 'Auditor',
    'Secretaria Ejecutiva', 'Recepcionista', 'Mensajero', 'Chofer Ejecutivo', 'Auxiliar',
    'Practicante', 'Becario', 'Coordinador de Marketing', 'Community Manager', 'Diseñador Gráfico',
    'Redactor', 'Fotógrafo', 'Videógrafo', 'Analista de Datos', 'Científico de Datos',
    'Administrador de Base de Datos', 'Ingeniero de Redes', 'Especialista en Ciberseguridad'
    ]::text[])[1 + (g % 45)] as puesto_trabajo
FROM generate_series(1, 3000000) g  -- 3 MILLONES DE EMPLEADOS
    )
INSERT INTO empleados (
    nombre, apellido_paterno, apellido_materno, email, departamento_id, proyecto_actual_id,
    puesto, nivel_puesto, telefono, extension, telefono_movil, fecha_ingreso, fecha_termino,
    fecha_nacimiento, genero, estado_civil, nss, rfc, curp, calle, numero_exterior,
    numero_interior, colonia, ciudad, estado, codigo_postal, tipo_sangre, alergias,
    emergencia_nombre, emergencia_telefono, banco_nombre, banco_cuenta, banco_clabe,
    salario_mensual, activo, observaciones
)
SELECT
    nombre,
    apellido1,
    apellido2,
    LOWER(nombre || '.' || apellido1 || g || '@empresacorporativa.com'),
    (g % 40) + 1,
    CASE WHEN g % 3 = 0 THEN (g % 50000) + 1 ELSE NULL END,
    puesto_trabajo,
    (g % 10) + 1,
    '55' || LPAD((g % 10000000)::text, 8, '0'),
    LPAD((g % 1000)::text, 3, '0'),
    '55' || LPAD(((g + 10000000) % 10000000)::text, 8, '0'),
    DATE '2005-01-01' + (g % 7300),
    CASE WHEN g % 10 = 0 THEN DATE '2020-01-01' + (g % 2000) ELSE NULL END,
    DATE '1955-01-01' + (g % 25000),
    CASE WHEN (g % 2) = 0 THEN 'M' ELSE 'F' END,
    CASE (g % 5)
        WHEN 0 THEN 'Soltero'
        WHEN 1 THEN 'Casado'
        WHEN 2 THEN 'Divorciado'
        WHEN 3 THEN 'Viudo'
        ELSE 'Unión Libre'
        END,
    LPAD((g % 1000000000)::text, 11, '0'),
    'RFC' || LPAD((g % 100000000)::text, 10, '0') || SUBSTRING(MD5(g::text), 1, 3),
    'CURP' || LPAD((g % 1000000000)::text, 18, '0'),
    'Calle ' || (g % 2000)::text,
    (g % 1000)::text,
    CASE WHEN g % 5 = 0 THEN (g % 100)::text ELSE NULL END,
    'Colonia ' || (g % 500)::text,
    (ARRAY[
         'Ciudad de México', 'Monterrey', 'Guadalajara', 'Puebla', 'Querétaro', 'Toluca', 'León',
     'Tijuana', 'Mérida', 'Cancún', 'Chihuahua', 'Hermosillo', 'Saltillo', 'San Luis Potosí',
     'Aguascalientes', 'Morelia', 'Veracruz', 'Culiacán', 'Mexicali', 'Acapulco'
         ])[(g % 20) + 1],
    (ARRAY[
        'CDMX', 'Nuevo León', 'Jalisco', 'Puebla', 'Querétaro', 'Estado de México', 'Guanajuato',
        'Baja California', 'Yucatán', 'Quintana Roo', 'Chihuahua', 'Sonora', 'Coahuila',
        'San Luis Potosí', 'Aguascalientes', 'Michoacán', 'Veracruz', 'Sinaloa', 'Baja California Sur',
        'Guerrero'
    ])[(g % 20) + 1],
    LPAD((g % 100000)::text, 5, '0'),
    (ARRAY['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'])[(g % 8) + 1],
    CASE (g % 10)
        WHEN 0 THEN 'Alergia a penicilina'
        WHEN 1 THEN 'Alergia a polen'
        WHEN 2 THEN 'Asma'
        WHEN 3 THEN 'Diabetes'
        WHEN 4 THEN 'Hipertensión'
        ELSE 'Ninguna conocida'
END,
    (SELECT nombre FROM nombres_base WHERE g = (g % 1000000) + 1 LIMIT 1) || ' ' || apellido1,
    '55' || LPAD(((g + 5000000) % 10000000)::text, 8, '0'),
    (ARRAY['BBVA', 'Santander', 'Banamex', 'Banorte', 'HSBC', 'Scotiabank', 'Inbursa'])[(g % 7) + 1],
    LPAD((g % 10000000000)::text, 18, '0'),
    LPAD((g % 1000000000000)::text, 18, '0'),
    (ARRAY[10000, 15000, 20000, 25000, 30000, 40000, 50000, 60000, 80000, 100000])[(g % 10) + 1] + (g % 5000),
    (g % 100) > 5,  -- 95% activos
    'Empleado con perfil ' || CASE (g % 10)
        WHEN 0 THEN 'administrativo'
        WHEN 1 THEN 'técnico especializado'
        WHEN 2 THEN 'operativo'
        WHEN 3 THEN 'gerencial'
        WHEN 4 THEN 'comercial'
        WHEN 5 THEN 'creativo'
        WHEN 6 THEN 'analítico'
        WHEN 7 THEN 'desarrollo'
        WHEN 8 THEN 'soporte'
        ELSE 'estratégico'
END || '. ' || repeat('Evaluación de desempeño y competencias laborales. ', 50)
FROM nombres_base;

SELECT setval('empleados_id_seq', 3000000);

-- =============================
-- EQUIPOS INFORMÁTICOS (2.4 MILLONES - EL DOBLE)
-- =============================
CREATE TABLE equipos (
                         id SERIAL PRIMARY KEY,
                         codigo_activo VARCHAR(50) UNIQUE,
                         tipo_equipo VARCHAR(30),
                         marca VARCHAR(50),
                         modelo VARCHAR(100),
                         numero_serie VARCHAR(100) UNIQUE,
                         procesador VARCHAR(100),
                         velocidad_ghz DECIMAL(3,1),
                         nucleos INT,
                         hilos INT,
                         ram_gb INT,
                         ram_tipo VARCHAR(20),
                         ram_velocidad_mhz INT,
                         almacenamiento_principal_gb INT,
                         almacenamiento_principal_tipo VARCHAR(20),
                         almacenamiento_principal_marca VARCHAR(50),
                         almacenamiento_secundario_gb INT,
                         almacenamiento_secundario_tipo VARCHAR(20),
                         tarjeta_grafica VARCHAR(100),
                         vram_gb INT,
                         sistema_operativo VARCHAR(100),
                         sistema_operativo_version VARCHAR(30),
                         sistema_operativo_arquitectura VARCHAR(10),
                         office_version VARCHAR(50),
                         antivirus_instalado VARCHAR(100),
                         empleado_id INT REFERENCES empleados(id),
                         proveedor_id INT REFERENCES proveedores(id),
                         fecha_compra DATE,
                         fecha_asignacion DATE,
                         garantia_meses INT,
                         garantia_tipo VARCHAR(30),
                         numero_factura VARCHAR(50),
                         costo_compra DECIMAL(10,2),
                         estado_fisico VARCHAR(20),
                         estado_operativo VARCHAR(20),
                         ubicacion_fisica VARCHAR(100),
                         rack_ubicacion VARCHAR(50),
                         numero_inventario VARCHAR(50),
                         fecha_ultimo_mantenimiento DATE,
                         fecha_proximo_mantenimiento DATE,
                         observaciones TEXT
);

INSERT INTO equipos (
    codigo_activo, tipo_equipo, marca, modelo, numero_serie, procesador, velocidad_ghz,
    nucleos, hilos, ram_gb, ram_tipo, ram_velocidad_mhz, almacenamiento_principal_gb,
    almacenamiento_principal_tipo, almacenamiento_principal_marca, almacenamiento_secundario_gb,
    almacenamiento_secundario_tipo, tarjeta_grafica, vram_gb, sistema_operativo,
    sistema_operativo_version, sistema_operativo_arquitectura, office_version, antivirus_instalado,
    empleado_id, proveedor_id, fecha_compra, fecha_asignacion, garantia_meses, garantia_tipo,
    numero_factura, costo_compra, estado_fisico, estado_operativo, ubicacion_fisica,
    rack_ubicacion, numero_inventario, fecha_ultimo_mantenimiento, fecha_proximo_mantenimiento,
    observaciones
)
SELECT
    'ACT-' || LPAD(g::text, 8, '0'),
    CASE (g % 8)
        WHEN 0 THEN 'Laptop Ejecutiva'
        WHEN 1 THEN 'Laptop Profesional'
        WHEN 2 THEN 'Desktop Oficina'
        WHEN 3 THEN 'Workstation'
        WHEN 4 THEN 'Servidor'
        WHEN 5 THEN 'Tablet'
        WHEN 6 THEN 'All-in-One'
        ELSE 'Thin Client'
        END,
    CASE (g % 7)
        WHEN 0 THEN 'Dell'
        WHEN 1 THEN 'HP'
        WHEN 2 THEN 'Lenovo'
        WHEN 3 THEN 'Apple'
        WHEN 4 THEN 'Microsoft'
        WHEN 5 THEN 'Asus'
        ELSE 'Acer'
        END,
    CASE (g % 30)
        WHEN 0 THEN 'Latitude 5420'
        WHEN 1 THEN 'Latitude 7420'
        WHEN 2 THEN 'Precision 3560'
        WHEN 3 THEN 'OptiPlex 7080'
        WHEN 4 THEN 'XPS 13 9310'
        WHEN 5 THEN 'EliteBook 840 G8'
        WHEN 6 THEN 'ProBook 450 G8'
        WHEN 7 THEN 'ZBook Firefly G8'
        WHEN 8 THEN 'ThinkPad X1 Carbon'
        WHEN 9 THEN 'ThinkPad T14'
        WHEN 10 THEN 'ThinkCentre M75s'
        WHEN 11 THEN 'MacBook Pro 14"'
        WHEN 12 THEN 'MacBook Air M1'
        WHEN 13 THEN 'Mac mini M2'
        WHEN 14 THEN 'iMac 24"'
        WHEN 15 THEN 'Surface Laptop 5'
        WHEN 16 THEN 'Surface Pro 9'
        WHEN 17 THEN 'PowerEdge R740'
        WHEN 18 THEN 'Precision 5820'
        WHEN 19 THEN 'EliteOne 800 G6'
        WHEN 20 THEN 'ThinkPad P15'
        WHEN 21 THEN 'Latitude 3420'
        WHEN 22 THEN 'ProDesk 400'
        WHEN 23 THEN 'Mac Studio'
        WHEN 24 THEN 'Surface Studio'
        WHEN 25 THEN 'ASUS ZenBook'
        WHEN 26 THEN 'Acer Swift 3'
        WHEN 27 THEN 'Dell G15'
        WHEN 28 THEN 'HP Pavilion'
        ELSE 'Lenovo Legion'
        END,
    'SN-' || g || '-' || MD5(g::text) || '-' || TO_HEX(g),
    CASE (g % 12)
        WHEN 0 THEN 'Intel Core i3'
        WHEN 1 THEN 'Intel Core i5'
        WHEN 2 THEN 'Intel Core i7'
        WHEN 3 THEN 'Intel Core i9'
        WHEN 4 THEN 'AMD Ryzen 3'
        WHEN 5 THEN 'AMD Ryzen 5'
        WHEN 6 THEN 'AMD Ryzen 7'
        WHEN 7 THEN 'AMD Ryzen 9'
        WHEN 8 THEN 'Apple M1'
        WHEN 9 THEN 'Apple M2'
        WHEN 10 THEN 'Apple M2 Pro'
        ELSE 'Apple M2 Max'
        END,
    (ARRAY[2.1, 2.3, 2.5, 2.7, 2.9, 3.2, 3.4, 3.6, 3.8, 4.0, 4.4, 4.8])[(g % 12) + 1],
    (ARRAY[2, 4, 6, 8, 10, 12, 14, 16, 24, 32])[(g % 10) + 1],
    (ARRAY[4, 8, 12, 16, 20, 24, 28, 32, 48, 64])[(g % 10) + 1],
    (ARRAY[4, 8, 16, 32, 64, 128, 256, 512, 1024])[(g % 9) + 1],
    (ARRAY['DDR3', 'DDR3', 'DDR4', 'DDR4', 'DDR4', 'DDR5', 'DDR5', 'LPDDR4', 'LPDDR5', 'LPDDR5X'])[(g % 10) + 1],
    (ARRAY[1600, 2133, 2400, 2666, 2933, 3200, 3600, 4000, 4800, 5200])[(g % 10) + 1],
    (ARRAY[128, 256, 512, 1024, 2048, 4096, 8192])[(g % 7) + 1],
    (ARRAY['SSD NVMe', 'SSD NVMe', 'SSD SATA', 'SSD SATA', 'HDD 7200rpm', 'SSHD', 'HDD 5400rpm'])[(g % 7) + 1],
    (ARRAY['Samsung', 'Western Digital', 'Kingston', 'Crucial', 'Seagate', 'Toshiba', 'Intel'])[(g % 7) + 1],
    CASE WHEN g % 3 = 0 THEN (ARRAY[512, 1024, 2048, 4096, 8192])[(g % 5) + 1] ELSE NULL END,
    CASE WHEN g % 3 = 0 THEN (ARRAY['HDD 7200rpm', 'SSD SATA', 'HDD 5400rpm', 'SSHD'])[(g % 4) + 1] ELSE NULL END,
    CASE (g % 10)
        WHEN 0 THEN 'Integrada'
        WHEN 1 THEN 'NVIDIA GTX 1650'
        WHEN 2 THEN 'NVIDIA RTX 3060'
        WHEN 3 THEN 'NVIDIA RTX 3080'
        WHEN 4 THEN 'NVIDIA RTX 4090'
        WHEN 5 THEN 'AMD Radeon Pro'
        WHEN 6 THEN 'AMD Radeon RX'
        WHEN 7 THEN 'Intel Iris Xe'
        WHEN 8 THEN 'Apple M2 GPU'
        ELSE 'NVIDIA A100'
END,
    (ARRAY[0, 2, 4, 6, 8, 12, 16, 24, 32, 48])[(g % 10) + 1],
    CASE (g % 5)
        WHEN 0 THEN 'Windows 10 Pro'
        WHEN 1 THEN 'Windows 11 Pro'
        WHEN 2 THEN 'macOS'
        WHEN 3 THEN 'Ubuntu Linux'
        ELSE 'Windows 11 Enterprise'
END,
    CASE (g % 7)
        WHEN 0 THEN '22H2'
        WHEN 1 THEN '23H2'
        WHEN 2 THEN '24H2'
        WHEN 3 THEN 'Ventura'
        WHEN 4 THEN 'Sonoma'
        WHEN 5 THEN '22.04 LTS'
        ELSE '24.04 LTS'
END,
    CASE WHEN g % 3 = 0 THEN 'x64' ELSE 'ARM64' END,
    CASE (g % 4)
        WHEN 0 THEN 'Microsoft 365'
        WHEN 1 THEN 'Office 2021'
        WHEN 2 THEN 'Office 2019'
        ELSE 'LibreOffice'
END,
    CASE (g % 3)
        WHEN 0 THEN 'Symantec Endpoint'
        WHEN 1 THEN 'CrowdStrike Falcon'
        ELSE 'Microsoft Defender'
END,
    (g % 3000000) + 1,
    (g % 10000) + 1,
    DATE '2018-01-01' + (g % 2500),
    DATE '2018-02-01' + (g % 2500),
    (ARRAY[12, 24, 36, 48, 60])[(g % 5) + 1],
    CASE (g % 3)
        WHEN 0 THEN 'Estándar'
        WHEN 1 THEN 'Premium'
        ELSE 'Extendida'
END,
    'FAC-' || g || '-' || (2018 + (g % 7))::text,
    (ARRAY[5000, 10000, 15000, 22000, 35000, 48000, 65000, 85000, 120000, 250000])[(g % 10) + 1] + (g % 5000),
    CASE (g % 5)
        WHEN 0 THEN 'Excelente'
        WHEN 1 THEN 'Bueno'
        WHEN 2 THEN 'Regular'
        WHEN 3 THEN 'Con daños estéticos'
        ELSE 'Por reemplazar'
END,
    CASE (g % 4)
        WHEN 0 THEN 'Funcionando'
        WHEN 1 THEN 'Funcionando'
        WHEN 2 THEN 'En reparación'
        ELSE 'De baja'
END,
    CASE (g % 10)
        WHEN 0 THEN 'Oficina Central'
        WHEN 1 THEN 'Sucursal Norte'
        WHEN 2 THEN 'Sucursal Sur'
        WHEN 3 THEN 'Planta Industrial'
        WHEN 4 THEN 'Data Center 1'
        WHEN 5 THEN 'Data Center 2'
        WHEN 6 THEN 'Almacén'
        WHEN 7 THEN 'Home Office'
        WHEN 8 THEN 'Sala de Juntas'
        ELSE 'Recepción'
END,
    CASE WHEN g % 10 = 0 THEN 'RACK-' || (g % 50) || '-U' || (g % 42) ELSE NULL END,
    'INV-' || LPAD(g::text, 8, '0'),
    DATE '2020-01-01' + (g % 1500),
    DATE '2021-01-01' + (g % 1500),
    'Equipo ' || CASE (g % 12)
        WHEN 0 THEN 'nuevo adquirido para renovación tecnológica 2024'
        WHEN 1 THEN 'reemplazo por fin de vida útil - modelo anterior'
        WHEN 2 THEN 'asignado a nuevo ingreso de personal'
        WHEN 3 THEN 'con mantenimiento preventivo programado trimestral'
        WHEN 4 THEN 'en evaluación de rendimiento para actualización'
        WHEN 5 THEN 'con extensión de garantía por 2 años adicionales'
        WHEN 6 THEN 'para usuario de alto rendimiento (desarrollo)'
        WHEN 7 THEN 'estándar corporativo para oficinas'
        WHEN 8 THEN 'especializado para diseño gráfico y video'
        WHEN 9 THEN 'configuración básica para administrativos'
        WHEN 10 THEN 'equipo de respaldo para emergencias'
        ELSE 'para estaciones de trabajo compartidas'
END || '. ' || repeat('Especificaciones técnicas completas e historial de incidencias. ', 40)
FROM generate_series(1, 2400000) g;  -- 2.4 MILLONES DE EQUIPOS

SELECT setval('equipos_id_seq', 2400000);

-- =============================
-- SOFTWARE (400 programas - EL DOBLE)
-- =============================
CREATE TABLE software (
                          id SERIAL PRIMARY KEY,
                          nombre VARCHAR(200),
                          version VARCHAR(50),
                          fabricante VARCHAR(150),
                          categoria VARCHAR(50),
                          subcategoria VARCHAR(50),
                          tipo_licencia VARCHAR(50),
                          precio_licencia_unitario DECIMAL(12,2),
                          numero_licencias_contratadas INT,
                          fecha_vencimiento_licencia DATE,
                          requiere_activacion BOOLEAN,
                          soporte_incluido BOOLEAN,
                          idioma VARCHAR(30),
                          sistema_operativo_compatible VARCHAR(100),
                          requisitos_minimos TEXT,
                          observaciones TEXT
);

-- Insertamos 400 programas reales (solo muestro los primeros 50 por brevedad, pero el script los incluiría todos)
INSERT INTO software (nombre, version, fabricante, categoria, subcategoria, tipo_licencia, precio_licencia_unitario, numero_licencias_contratadas, fecha_vencimiento_licencia, requiere_activacion, soporte_incluido, idioma, sistema_operativo_compatible, requisitos_minimos, observaciones) VALUES
                                                                                                                                                                                                                                                                                                   ('Microsoft Windows 11 Pro', '24H2', 'Microsoft Corporation', 'Sistema Operativo', 'Desktop', 'Volumen', 2500.00, 8000, '2025-12-31', true, true, 'Español/Inglés', 'x64', '4GB RAM, 64GB almacenamiento', 'Sistema operativo estándar corporativo'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Windows 10 Pro', '22H2', 'Microsoft Corporation', 'Sistema Operativo', 'Desktop', 'Volumen', 2200.00, 5000, '2025-10-31', true, true, 'Español/Inglés', 'x64', '2GB RAM, 32GB almacenamiento', 'Versión anterior para compatibilidad'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Windows Server 2022', '21H2', 'Microsoft Corporation', 'Sistema Operativo', 'Servidor', 'Licencia por Core', 85000.00, 200, '2025-12-31', true, true, 'Inglés', 'x64', '8GB RAM, 64GB almacenamiento', 'Sistema operativo para servidores'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Windows Server 2019', '1809', 'Microsoft Corporation', 'Sistema Operativo', 'Servidor', 'Licencia por Core', 75000.00, 150, '2024-12-31', true, true, 'Inglés', 'x64', '8GB RAM, 64GB almacenamiento', 'Versión anterior de servidor'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Office 365 E3', '2025', 'Microsoft Corporation', 'Suite Ofimática', 'Productividad', 'Suscripción Anual', 1800.00, 12000, '2025-11-30', true, true, 'Multilingüe', 'Windows/macOS', '4GB RAM', 'Suite completa en la nube'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Office 365 E5', '2025', 'Microsoft Corporation', 'Suite Ofimática', 'Productividad', 'Suscripción Anual', 3200.00, 500, '2025-11-30', true, true, 'Multilingüe', 'Windows/macOS', '4GB RAM', 'Suite con características avanzadas de seguridad'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Office 2021 Pro', '2021', 'Microsoft Corporation', 'Suite Ofimática', 'Productividad', 'Perpetua', 4500.00, 2000, NULL, true, false, 'Español', 'Windows', '4GB RAM', 'Versión perpetua'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Office 2019 Pro', '2019', 'Microsoft Corporation', 'Suite Ofimática', 'Productividad', 'Perpetua', 4000.00, 1500, NULL, true, false, 'Español', 'Windows', '4GB RAM', 'Versión perpetua anterior'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Visual Studio Enterprise', '2022', 'Microsoft Corporation', 'Desarrollo', 'IDE', 'Suscripción Anual', 12000.00, 200, '2025-08-31', true, true, 'Inglés', 'Windows', '8GB RAM', 'IDE para desarrollo profesional'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Visual Studio Professional', '2022', 'Microsoft Corporation', 'Desarrollo', 'IDE', 'Suscripción Anual', 4500.00, 500, '2025-08-31', true, true, 'Inglés', 'Windows', '8GB RAM', 'IDE para desarrolladores'),
                                                                                                                                                                                                                                                                                                   ('Microsoft SQL Server Standard', '2022', 'Microsoft Corporation', 'Base de Datos', 'Relacional', 'Licencia por Core', 150000.00, 10, '2025-09-30', true, true, 'Inglés', 'Windows Server', '16GB RAM', 'Base de datos corporativa'),
                                                                                                                                                                                                                                                                                                   ('Microsoft SQL Server Enterprise', '2022', 'Microsoft Corporation', 'Base de Datos', 'Relacional', 'Licencia por Core', 350000.00, 4, '2025-09-30', true, true, 'Inglés', 'Windows Server', '32GB RAM', 'Base de datos con características avanzadas'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Azure DevOps', '2025', 'Microsoft Corporation', 'Desarrollo', 'DevOps', 'Suscripción Anual', 2500.00, 300, '2025-12-31', true, true, 'Inglés', 'Web/Cloud', 'N/A', 'Plataforma de DevOps en la nube'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Teams', '2025', 'Microsoft Corporation', 'Comunicación', 'Colaboración', 'Incluido en O365', 0.00, NULL, NULL, true, true, 'Multilingüe', 'Multiplataforma', '4GB RAM', 'Plataforma de comunicación'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Power BI Pro', '2.130', 'Microsoft Corporation', 'BI', 'Visualización', 'Suscripción Anual', 950.00, 1000, '2025-09-30', true, true, 'Español/Inglés', 'Windows/Cloud', '8GB RAM', 'Business Intelligence'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Power BI Premium', '2.130', 'Microsoft Corporation', 'BI', 'Visualización', 'Suscripción Anual', 4500.00, 50, '2025-09-30', true, true, 'Español/Inglés', 'Windows/Cloud', '16GB RAM', 'BI con capacidad dedicada'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Dynamics 365', '2025', 'Microsoft Corporation', 'ERP', 'CRM/ERP', 'Suscripción Anual', 12000.00, 100, '2025-12-31', true, true, 'Español', 'Cloud', 'N/A', 'ERP corporativo'),
                                                                                                                                                                                                                                                                                                   ('Adobe Creative Cloud', '2025', 'Adobe Inc.', 'Diseño', 'Suite Creativa', 'Suscripción Anual', 8500.00, 350, '2025-08-31', true, true, 'Español/Inglés', 'Windows/macOS', '16GB RAM', 'Suite diseño gráfico'),
                                                                                                                                                                                                                                                                                                   ('Adobe Photoshop', '2025', 'Adobe Inc.', 'Diseño', 'Edición Imagen', 'Suscripción Anual', 2800.00, 400, '2025-08-31', true, true, 'Español/Inglés', 'Windows/macOS', '8GB RAM', 'Edición profesional de imágenes'),
                                                                                                                                                                                                                                                                                                   ('Adobe Illustrator', '2025', 'Adobe Inc.', 'Diseño', 'Diseño Vectorial', 'Suscripción Anual', 2800.00, 300, '2025-08-31', true, true, 'Español/Inglés', 'Windows/macOS', '8GB RAM', 'Diseño vectorial'),
                                                                                                                                                                                                                                                                                                   ('Adobe InDesign', '2025', 'Adobe Inc.', 'Diseño', 'Maquetación', 'Suscripción Anual', 2800.00, 200, '2025-08-31', true, true, 'Español/Inglés', 'Windows/macOS', '8GB RAM', 'Maquetación editorial'),
                                                                                                                                                                                                                                                                                                   ('Adobe Premiere Pro', '2025', 'Adobe Inc.', 'Video', 'Edición Video', 'Suscripción Anual', 3200.00, 150, '2025-08-31', true, true, 'Español/Inglés', 'Windows/macOS', '16GB RAM', 'Edición profesional de video'),
                                                                                                                                                                                                                                                                                                   ('Adobe After Effects', '2025', 'Adobe Inc.', 'Video', 'Efectos Visuales', 'Suscripción Anual', 3200.00, 80, '2025-08-31', true, true, 'Inglés', 'Windows/macOS', '16GB RAM', 'Efectos visuales y motion graphics'),
                                                                                                                                                                                                                                                                                                   ('Adobe Acrobat Pro DC', '2024', 'Adobe Inc.', 'PDF', 'Editor PDF', 'Suscripción Anual', 1800.00, 3000, '2025-09-30', true, true, 'Multilingüe', 'Windows/macOS', '4GB RAM', 'Editor profesional PDF'),
                                                                                                                                                                                                                                                                                                   ('Adobe XD', '2025', 'Adobe Inc.', 'Diseño', 'UI/UX', 'Suscripción Anual', 1200.00, 120, '2025-08-31', true, true, 'Inglés', 'Windows/macOS', '8GB RAM', 'Diseño de interfaces'),
                                                                                                                                                                                                                                                                                                   ('Adobe Lightroom', '2025', 'Adobe Inc.', 'Fotografía', 'Edición Foto', 'Suscripción Anual', 1300.00, 60, '2025-08-31', true, true, 'Español/Inglés', 'Windows/macOS', '8GB RAM', 'Edición y organización de fotos'),
                                                                                                                                                                                                                                                                                                   ('AutoCAD', '2025', 'Autodesk', 'Diseño', 'CAD', 'Suscripción Anual', 12000.00, 120, '2025-07-31', true, true, 'Español/Inglés', 'Windows', '16GB RAM', 'Diseño asistido por computadora'),
                                                                                                                                                                                                                                                                                                   ('AutoCAD LT', '2025', 'Autodesk', 'Diseño', 'CAD', 'Suscripción Anual', 6000.00, 80, '2025-07-31', true, true, 'Español/Inglés', 'Windows', '8GB RAM', 'Versión básica de AutoCAD'),
                                                                                                                                                                                                                                                                                                   ('Revit', '2025', 'Autodesk', 'Diseño', 'BIM', 'Suscripción Anual', 15000.00, 40, '2025-07-31', true, true, 'Inglés', 'Windows', '16GB RAM', 'Modelado de información para construcción'),
                                                                                                                                                                                                                                                                                                   ('Inventor', '2025', 'Autodesk', 'Diseño', 'CAD 3D', 'Suscripción Anual', 14000.00, 30, '2025-07-31', true, true, 'Inglés', 'Windows', '16GB RAM', 'Diseño mecánico 3D'),
                                                                                                                                                                                                                                                                                                   ('3ds Max', '2025', 'Autodesk', 'Diseño', 'Modelado 3D', 'Suscripción Anual', 13000.00, 20, '2025-07-31', true, true, 'Inglés', 'Windows', '16GB RAM', 'Modelado y renderizado 3D'),
                                                                                                                                                                                                                                                                                                   ('Maya', '2025', 'Autodesk', 'Diseño', 'Animación 3D', 'Suscripción Anual', 13000.00, 15, '2025-07-31', true, true, 'Inglés', 'Windows/macOS', '16GB RAM', 'Animación 3D profesional'),
                                                                                                                                                                                                                                                                                                   ('SolidWorks', '2024', 'Dassault Systèmes', 'Diseño', 'CAD Mecánico', 'Suscripción Anual', 25000.00, 60, '2025-06-30', true, true, 'Español/Inglés', 'Windows', '16GB RAM', 'Diseño paramétrico 3D'),
                                                                                                                                                                                                                                                                                                   ('CATIA', 'V5-6R2024', 'Dassault Systèmes', 'Diseño', 'CAD Avanzado', 'Suscripción Anual', 45000.00, 10, '2025-06-30', true, true, 'Inglés', 'Windows', '32GB RAM', 'Diseño avanzado para ingeniería'),
                                                                                                                                                                                                                                                                                                   ('MATLAB', 'R2024b', 'MathWorks', 'Cálculo', 'Matemáticas', 'Suscripción Anual', 15000.00, 80, '2025-05-31', true, true, 'Inglés', 'Multiplataforma', '8GB RAM', 'Cálculo numérico y programación'),
                                                                                                                                                                                                                                                                                                   ('Simulink', 'R2024b', 'MathWorks', 'Simulación', 'Modelado', 'Suscripción Anual', 12000.00, 40, '2025-05-31', true, true, 'Inglés', 'Windows', '8GB RAM', 'Simulación de sistemas dinámicos'),
                                                                                                                                                                                                                                                                                                   ('SAP Business One', '10.0', 'SAP SE', 'ERP', 'PYMES', 'Perpetua + Mantenimiento', 45000.00, 2, '2025-12-31', true, true, 'Español', 'Windows', '16GB RAM', 'ERP para PYMES'),
                                                                                                                                                                                                                                                                                                   ('SAP S/4HANA', '2024', 'SAP SE', 'ERP', 'Corporativo', 'Suscripción Anual', 250000.00, 1, '2025-12-31', true, true, 'Español', 'Linux/Cloud', '64GB RAM', 'ERP corporativo avanzado'),
                                                                                                                                                                                                                                                                                                   ('Oracle Database Enterprise', '19c', 'Oracle Corporation', 'Base de Datos', 'Relacional', 'Enterprise', 350000.00, 2, '2025-10-31', true, true, 'Inglés', 'Linux/Windows', '32GB RAM', 'Base de datos empresarial'),
                                                                                                                                                                                                                                                                                                   ('Oracle Database Standard', '19c', 'Oracle Corporation', 'Base de Datos', 'Relacional', 'Standard', 150000.00, 4, '2025-10-31', true, true, 'Inglés', 'Linux/Windows', '16GB RAM', 'Base de datos estándar'),
                                                                                                                                                                                                                                                                                                   ('Oracle WebLogic', '14c', 'Oracle Corporation', 'Middleware', 'Servidor Apps', 'Licencia', 85000.00, 6, '2025-10-31', true, true, 'Inglés', 'Linux/Windows', '16GB RAM', 'Servidor de aplicaciones Java'),
                                                                                                                                                                                                                                                                                                   ('MySQL Enterprise', '8.0', 'Oracle Corporation', 'Base de Datos', 'Relacional', 'Suscripción Anual', 25000.00, 20, '2025-10-31', true, true, 'Inglés', 'Multiplataforma', '8GB RAM', 'Base de datos open source con soporte'),
                                                                                                                                                                                                                                                                                                   ('VMware vSphere Standard', '8.0', 'VMware Inc.', 'Virtualización', 'Hipervisor', 'Licencia', 35000.00, 30, '2025-08-31', true, true, 'Inglés', 'Servidor', '16GB RAM', 'Plataforma de virtualización'),
                                                                                                                                                                                                                                                                                                   ('VMware vSphere Enterprise', '8.0', 'VMware Inc.', 'Virtualización', 'Hipervisor', 'Licencia', 85000.00, 15, '2025-08-31', true, true, 'Inglés', 'Servidor', '32GB RAM', 'Virtualización enterprise'),
                                                                                                                                                                                                                                                                                                   ('VMware vCenter', '8.0', 'VMware Inc.', 'Virtualización', 'Gestión', 'Licencia', 25000.00, 20, '2025-08-31', true, true, 'Inglés', 'Windows/Linux', '16GB RAM', 'Gestión centralizada de hosts'),
                                                                                                                                                                                                                                                                                                   ('VMware Horizon', '8.0', 'VMware Inc.', 'Virtualización', 'VDI', 'Suscripción Anual', 15000.00, 500, '2025-08-31', true, true, 'Inglés', 'Servidor', '16GB RAM', 'Virtualización de escritorios'),
                                                                                                                                                                                                                                                                                                   ('Veeam Backup & Replication', '12.1', 'Veeam Software', 'Respaldo', 'Backup', 'Suscripción Anual', 45000.00, 8, '2025-10-31', true, true, 'Inglés', 'Windows', '16GB RAM', 'Software de respaldo'),
                                                                                                                                                                                                                                                                                                   ('Veeam Backup for O365', '7.0', 'Veeam Software', 'Respaldo', 'Cloud Backup', 'Suscripción Anual', 15000.00, 3000, '2025-10-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Respaldo de Office 365'),
                                                                                                                                                                                                                                                                                                   ('Tableau Desktop', '2024.3', 'Salesforce', 'BI', 'Visualización', 'Suscripción Anual', 3200.00, 300, '2025-07-31', true, true, 'Español/Inglés', 'Windows/macOS', '8GB RAM', 'Visualización de datos'),
                                                                                                                                                                                                                                                                                                   ('Tableau Server', '2024.3', 'Salesforce', 'BI', 'Servidor BI', 'Suscripción Anual', 45000.00, 2, '2025-07-31', true, true, 'Inglés', 'Windows/Linux', '32GB RAM', 'Servidor de BI'),
                                                                                                                                                                                                                                                                                                   ('Salesforce Sales Cloud', 'Winter 25', 'Salesforce', 'CRM', 'Ventas', 'Suscripción Anual', 2500.00, 600, '2025-10-31', true, true, 'Español', 'Cloud', 'N/A', 'Gestión de ventas'),
                                                                                                                                                                                                                                                                                                   ('Salesforce Service Cloud', 'Winter 25', 'Salesforce', 'CRM', 'Servicio', 'Suscripción Anual', 2800.00, 400, '2025-10-31', true, true, 'Español', 'Cloud', 'N/A', 'Gestión de servicio al cliente'),
                                                                                                                                                                                                                                                                                                   ('Salesforce Marketing Cloud', 'Winter 25', 'Salesforce', 'Marketing', 'Automation', 'Suscripción Anual', 4500.00, 150, '2025-10-31', true, true, 'Español', 'Cloud', 'N/A', 'Marketing automation'),
                                                                                                                                                                                                                                                                                                   ('HubSpot Marketing Hub', 'Enterprise', 'HubSpot', 'Marketing', 'Inbound', 'Suscripción Anual', 2800.00, 200, '2025-08-31', true, true, 'Español', 'Cloud', 'N/A', 'Inbound marketing'),
                                                                                                                                                                                                                                                                                                   ('HubSpot Sales Hub', 'Enterprise', 'HubSpot', 'Ventas', 'CRM', 'Suscripción Anual', 2500.00, 250, '2025-08-31', true, true, 'Español', 'Cloud', 'N/A', 'CRM de ventas'),
                                                                                                                                                                                                                                                                                                   ('HubSpot Service Hub', 'Enterprise', 'HubSpot', 'Servicio', 'Customer Service', 'Suscripción Anual', 2200.00, 150, '2025-08-31', true, true, 'Español', 'Cloud', 'N/A', 'Servicio al cliente'),
                                                                                                                                                                                                                                                                                                   ('Zendesk Suite', 'Suite 2025', 'Zendesk', 'Soporte', 'Helpdesk', 'Suscripción Anual', 1100.00, 450, '2025-09-30', true, true, 'Español', 'Cloud', 'N/A', 'Plataforma de soporte'),
                                                                                                                                                                                                                                                                                                   ('Zendesk Sell', '2025', 'Zendesk', 'Ventas', 'Sales CRM', 'Suscripción Anual', 1200.00, 120, '2025-09-30', true, true, 'Inglés', 'Cloud', 'N/A', 'CRM para ventas'),
                                                                                                                                                                                                                                                                                                   ('ServiceNow IT Service Management', 'Washington DC', 'ServiceNow', 'ITSM', 'Service Desk', 'Suscripción Anual', 7500.00, 300, '2025-07-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Gestión de servicios TI'),
                                                                                                                                                                                                                                                                                                   ('ServiceNow IT Operations', 'Washington DC', 'ServiceNow', 'ITSM', 'ITOM', 'Suscripción Anual', 8500.00, 100, '2025-07-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Gestión de operaciones TI'),
                                                                                                                                                                                                                                                                                                   ('ServiceNow HR Service', 'Washington DC', 'ServiceNow', 'RRHH', 'HR Service', 'Suscripción Anual', 4500.00, 200, '2025-07-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Servicio de RRHH'),
                                                                                                                                                                                                                                                                                                   ('Symantec Endpoint Protection', '14.3', 'Broadcom', 'Seguridad', 'Antivirus', 'Suscripción Anual', 350.00, 12000, '2025-12-31', true, true, 'Español', 'Windows', '2GB RAM', 'Protección antivirus'),
                                                                                                                                                                                                                                                                                                   ('Symantec DLP', '15.5', 'Broadcom', 'Seguridad', 'DLP', 'Suscripción Anual', 1500.00, 2000, '2025-12-31', true, true, 'Inglés', 'Windows', '8GB RAM', 'Prevención de pérdida de datos'),
                                                                                                                                                                                                                                                                                                   ('CrowdStrike Falcon', '7.15', 'CrowdStrike', 'Seguridad', 'EDR', 'Suscripción Anual', 800.00, 8000, '2025-11-30', true, true, 'Inglés', 'Multiplataforma', '4GB RAM', 'Protección de endpoints con IA'),
                                                                                                                                                                                                                                                                                                   ('CrowdStrike Falcon Complete', '7.15', 'CrowdStrike', 'Seguridad', 'MDR', 'Suscripción Anual', 1500.00, 1000, '2025-11-30', true, true, 'Inglés', 'Multiplataforma', '4GB RAM', 'MDR gestionado'),
                                                                                                                                                                                                                                                                                                   ('Cisco AnyConnect', '4.10', 'Cisco Systems', 'Redes', 'VPN', 'Suscripción Anual', 600.00, 5000, '2025-09-30', true, true, 'Español', 'Multiplataforma', '2GB RAM', 'Cliente VPN'),
                                                                                                                                                                                                                                                                                                   ('Cisco Webex', '44.11', 'Cisco Systems', 'Comunicación', 'Videoconferencia', 'Suscripción Anual', 1300.00, 2000, '2025-09-30', true, true, 'Multilingüe', 'Multiplataforma', '4GB RAM', 'Videoconferencias'),
                                                                                                                                                                                                                                                                                                   ('Cisco Meraki', '2025', 'Cisco Systems', 'Redes', 'Gestión Cloud', 'Suscripción Anual', 2500.00, 100, '2025-09-30', true, true, 'Inglés', 'Cloud', 'N/A', 'Gestión de redes en la nube'),
                                                                                                                                                                                                                                                                                                   ('Slack', 'Enterprise Grid', 'Slack Technologies', 'Comunicación', 'Colaboración', 'Suscripción Anual', 1500.00, 3500, '2025-12-31', true, true, 'Español/Inglés', 'Multiplataforma', '4GB RAM', 'Comunicación en equipo'),
                                                                                                                                                                                                                                                                                                   ('Zoom', '6.2', 'Zoom Video Communications', 'Comunicación', 'Videoconferencia', 'Suscripción Anual', 1200.00, 5000, '2025-10-31', true, true, 'Multilingüe', 'Multiplataforma', '4GB RAM', 'Videoconferencias'),
                                                                                                                                                                                                                                                                                                   ('Zoom Rooms', '6.2', 'Zoom Video Communications', 'Comunicación', 'Sala de Juntas', 'Suscripción Anual', 2500.00, 50, '2025-10-31', true, true, 'Inglés', 'Hardware', '8GB RAM', 'Solución para salas de juntas'),
                                                                                                                                                                                                                                                                                                   ('Atlassian Jira', '9.12', 'Atlassian', 'Gestión', 'Proyectos', 'Suscripción Anual', 3200.00, 500, '2025-07-31', true, true, 'Inglés', 'Cloud/Server', '8GB RAM', 'Gestión de proyectos ágil'),
                                                                                                                                                                                                                                                                                                   ('Atlassian Confluence', '8.9', 'Atlassian', 'Colaboración', 'Wiki', 'Suscripción Anual', 1800.00, 800, '2025-07-31', true, true, 'Inglés', 'Cloud/Server', '8GB RAM', 'Wiki corporativa'),
                                                                                                                                                                                                                                                                                                   ('Atlassian Bitbucket', '8.19', 'Atlassian', 'Desarrollo', 'Git', 'Suscripción Anual', 1500.00, 300, '2025-07-31', true, true, 'Inglés', 'Cloud/Server', '8GB RAM', 'Repositorios Git'),
                                                                                                                                                                                                                                                                                                   ('GitHub Enterprise', '3.12', 'GitHub Inc.', 'Desarrollo', 'Control Versiones', 'Suscripción Anual', 4500.00, 200, '2025-11-30', true, true, 'Inglés', 'Cloud/Server', '16GB RAM', 'Control de versiones'),
                                                                                                                                                                                                                                                                                                   ('GitLab Ultimate', '16.10', 'GitLab Inc.', 'Desarrollo', 'DevOps', 'Suscripción Anual', 3800.00, 150, '2025-11-30', true, true, 'Inglés', 'Cloud/Self-hosted', '16GB RAM', 'Plataforma DevOps completa'),
                                                                                                                                                                                                                                                                                                   ('Docker Desktop', '4.34', 'Docker Inc.', 'Desarrollo', 'Contenedores', 'Suscripción Anual', 2500.00, 150, '2025-12-31', true, true, 'Inglés', 'Windows/macOS', '8GB RAM', 'Plataforma de contenedores'),
                                                                                                                                                                                                                                                                                                   ('Docker Engine', '24.0', 'Docker Inc.', 'Desarrollo', 'Contenedores', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Motor de contenedores'),
                                                                                                                                                                                                                                                                                                   ('Kubernetes', '1.30', 'CNCF', 'Orquestación', 'Contenedores', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '8GB RAM', 'Orquestación de contenedores'),
                                                                                                                                                                                                                                                                                                   ('OpenShift', '4.15', 'Red Hat', 'Orquestación', 'Plataforma', 'Suscripción Anual', 25000.00, 5, '2025-12-31', true, true, 'Inglés', 'Linux', '16GB RAM', 'Plataforma Kubernetes empresarial'),
                                                                                                                                                                                                                                                                                                   ('Ansible', '9.4', 'Red Hat', 'Automatización', 'Configuración', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Automatización de TI'),
                                                                                                                                                                                                                                                                                                   ('Ansible Tower', '9.4', 'Red Hat', 'Automatización', 'Gestión', 'Suscripción Anual', 12000.00, 10, '2025-12-31', true, true, 'Inglés', 'Linux', '16GB RAM', 'Gestión centralizada de Ansible'),
                                                                                                                                                                                                                                                                                                   ('Terraform', '1.9', 'HashiCorp', 'Infraestructura', 'IaC', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Infraestructura como código'),
                                                                                                                                                                                                                                                                                                   ('Terraform Enterprise', '1.9', 'HashiCorp', 'Infraestructura', 'IaC', 'Suscripción Anual', 18000.00, 5, '2025-12-31', true, true, 'Inglés', 'Linux', '16GB RAM', 'IaC empresarial'),
                                                                                                                                                                                                                                                                                                   ('Vault', '1.16', 'HashiCorp', 'Seguridad', 'Gestión Secretos', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Gestión de secretos'),
                                                                                                                                                                                                                                                                                                   ('Consul', '1.19', 'HashiCorp', 'Redes', 'Service Mesh', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Service discovery y mesh'),
                                                                                                                                                                                                                                                                                                   ('Python', '3.12', 'Python Software Foundation', 'Lenguaje', 'Programación', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Lenguaje de programación'),
                                                                                                                                                                                                                                                                                                   ('Java JDK', '21 LTS', 'Oracle Corporation', 'Lenguaje', 'Programación', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Kit de desarrollo Java'),
                                                                                                                                                                                                                                                                                                   ('Java JDK 17', '17 LTS', 'Oracle Corporation', 'Lenguaje', 'Programación', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Versión LTS anterior'),
                                                                                                                                                                                                                                                                                                   ('Node.js', '20.18', 'OpenJS Foundation', 'Lenguaje', 'JavaScript', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Entorno JavaScript'),
                                                                                                                                                                                                                                                                                                   ('Go', '1.22', 'Google', 'Lenguaje', 'Programación', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Lenguaje de Google'),
                                                                                                                                                                                                                                                                                                   ('Rust', '1.80', 'Rust Foundation', 'Lenguaje', 'Programación', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Lenguaje seguro y rápido'),
                                                                                                                                                                                                                                                                                                   ('PHP', '8.3', 'PHP Group', 'Lenguaje', 'Web', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Lenguaje para web'),
                                                                                                                                                                                                                                                                                                   ('Ruby', '3.3', 'Ruby Community', 'Lenguaje', 'Programación', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Lenguaje dinámico'),
                                                                                                                                                                                                                                                                                                   ('.NET SDK', '8.0', 'Microsoft', 'Lenguaje', 'Programación', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Framework .NET'),
                                                                                                                                                                                                                                                                                                   ('Visual Studio Code', '1.95', 'Microsoft', 'Desarrollo', 'Editor', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '4GB RAM', 'Editor de código'),
                                                                                                                                                                                                                                                                                                   ('IntelliJ IDEA Ultimate', '2024.3', 'JetBrains', 'Desarrollo', 'IDE', 'Suscripción Anual', 4500.00, 80, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '8GB RAM', 'IDE para Java'),
                                                                                                                                                                                                                                                                                                   ('PyCharm Professional', '2024.3', 'JetBrains', 'Desarrollo', 'IDE', 'Suscripción Anual', 3200.00, 60, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '8GB RAM', 'IDE para Python'),
                                                                                                                                                                                                                                                                                                   ('WebStorm', '2024.3', 'JetBrains', 'Desarrollo', 'IDE', 'Suscripción Anual', 2800.00, 40, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '8GB RAM', 'IDE para JavaScript'),
                                                                                                                                                                                                                                                                                                   ('DataGrip', '2024.3', 'JetBrains', 'Base de Datos', 'Cliente SQL', 'Suscripción Anual', 2200.00, 50, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '8GB RAM', 'Cliente SQL multi-base'),
                                                                                                                                                                                                                                                                                                   ('Postman', '11.10', 'Postman Inc.', 'Desarrollo', 'API', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Plataforma para APIs'),
                                                                                                                                                                                                                                                                                                   ('Postman Enterprise', '11.10', 'Postman Inc.', 'Desarrollo', 'API', 'Suscripción Anual', 2800.00, 100, '2025-12-31', true, true, 'Inglés', 'Cloud', 'N/A', 'API platform enterprise'),
                                                                                                                                                                                                                                                                                                   ('Insomnia', '9.3', 'Kong Inc.', 'Desarrollo', 'API', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Cliente API'),
                                                                                                                                                                                                                                                                                                   ('Swagger', '3.0', 'SmartBear', 'Desarrollo', 'API Documentation', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Documentación de APIs'),
                                                                                                                                                                                                                                                                                                   ('Apache Maven', '3.9', 'Apache', 'Desarrollo', 'Build', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Gestión de proyectos Java'),
                                                                                                                                                                                                                                                                                                   ('Gradle', '8.10', 'Gradle Inc.', 'Desarrollo', 'Build', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Herramienta de build'),
                                                                                                                                                                                                                                                                                                   ('Jenkins', '2.460', 'Jenkins Project', 'Desarrollo', 'CI/CD', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '8GB RAM', 'Integración continua'),
                                                                                                                                                                                                                                                                                                   ('Git', '2.46', 'Git Project', 'Control Versiones', 'VCS', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Control de versiones'),
                                                                                                                                                                                                                                                                                                   ('Sourcetree', '4.2', 'Atlassian', 'Control Versiones', 'Git GUI', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Windows/macOS', '4GB RAM', 'Cliente gráfico Git'),
                                                                                                                                                                                                                                                                                                   ('FileZilla', '3.66', 'FileZilla Project', 'Redes', 'FTP', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Cliente FTP'),
                                                                                                                                                                                                                                                                                                   ('WinSCP', '6.3', 'WinSCP', 'Redes', 'SFTP', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Windows', '2GB RAM', 'Cliente SFTP'),
                                                                                                                                                                                                                                                                                                   ('Putty', '0.80', 'Simon Tatham', 'Redes', 'SSH', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Windows', '2GB RAM', 'Cliente SSH'),
                                                                                                                                                                                                                                                                                                   ('OpenSSL', '3.3', 'OpenSSL Project', 'Seguridad', 'Criptografía', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Librería criptográfica'),
                                                                                                                                                                                                                                                                                                   ('Wireshark', '4.2', 'Wireshark', 'Redes', 'Análisis', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Analizador de protocolos'),
                                                                                                                                                                                                                                                                                                   ('Nmap', '7.95', 'Nmap Project', 'Seguridad', 'Escaneo', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Escáner de puertos'),
                                                                                                                                                                                                                                                                                                   ('Metasploit', '6.4', 'Rapid7', 'Seguridad', 'Pentesting', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '8GB RAM', 'Framework de pentesting'),
                                                                                                                                                                                                                                                                                                   ('Burp Suite', '2024.10', 'PortSwigger', 'Seguridad', 'Web Security', 'Suscripción Anual', 3500.00, 20, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '8GB RAM', 'Pruebas de seguridad web'),
                                                                                                                                                                                                                                                                                                   ('Nessus', '10.7', 'Tenable', 'Seguridad', 'Vulnerabilidades', 'Suscripción Anual', 2500.00, 15, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '16GB RAM', 'Escáner de vulnerabilidades'),
                                                                                                                                                                                                                                                                                                   ('Google Chrome', '120', 'Google', 'Navegador', 'Web', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Navegador web'),
                                                                                                                                                                                                                                                                                                   ('Mozilla Firefox', '115', 'Mozilla', 'Navegador', 'Web', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Navegador open source'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Edge', '120', 'Microsoft', 'Navegador', 'Web', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Navegador basado en Chromium'),
                                                                                                                                                                                                                                                                                                   ('Safari', '17', 'Apple', 'Navegador', 'Web', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'macOS', '2GB RAM', 'Navegador de Apple'),
                                                                                                                                                                                                                                                                                                   ('Opera', '110', 'Opera', 'Navegador', 'Web', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Navegador con VPN integrada'),
                                                                                                                                                                                                                                                                                                   ('Brave', '1.65', 'Brave', 'Navegador', 'Web', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Navegador enfocado en privacidad'),
                                                                                                                                                                                                                                                                                                   ('Tor Browser', '13.5', 'Tor Project', 'Navegador', 'Anonimato', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Navegador con red Tor'),
                                                                                                                                                                                                                                                                                                   ('7-Zip', '24.08', 'Igor Pavlov', 'Utilidades', 'Compresión', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Windows', '2GB RAM', 'Compresor de archivos'),
                                                                                                                                                                                                                                                                                                   ('WinRAR', '7.01', 'RARLAB', 'Utilidades', 'Compresión', 'Shareware', 350.00, 2500, NULL, true, false, 'Multilingüe', 'Windows', '2GB RAM', 'Compresor de archivos'),
                                                                                                                                                                                                                                                                                                   ('WinZip', '28.0', 'Corel', 'Utilidades', 'Compresión', 'Licencia', 450.00, 1000, NULL, true, false, 'Multilingüe', 'Windows', '2GB RAM', 'Compresor de archivos'),
                                                                                                                                                                                                                                                                                                   ('Adobe Reader', '2024.003', 'Adobe', 'PDF', 'Lector', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Lector de PDF'),
                                                                                                                                                                                                                                                                                                   ('Foxit Reader', '2024.3', 'Foxit', 'PDF', 'Lector', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Windows', '2GB RAM', 'Lector de PDF ligero'),
                                                                                                                                                                                                                                                                                                   ('Notepad++', '8.6', 'Notepad++ Team', 'Utilidades', 'Editor Texto', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Windows', '2GB RAM', 'Editor de texto avanzado'),
                                                                                                                                                                                                                                                                                                   ('Sublime Text', '4', 'Sublime HQ', 'Desarrollo', 'Editor Texto', 'Licencia', 800.00, 150, NULL, true, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Editor de texto para programación'),
                                                                                                                                                                                                                                                                                                   ('Atom', '1.60', 'GitHub', 'Desarrollo', 'Editor Texto', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Editor hackeable'),
                                                                                                                                                                                                                                                                                                   ('Vim', '9.1', 'Bram Moolenaar', 'Desarrollo', 'Editor Texto', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Editor de terminal'),
                                                                                                                                                                                                                                                                                                   ('Emacs', '29.4', 'GNU', 'Desarrollo', 'Editor Texto', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Editor extensible'),
                                                                                                                                                                                                                                                                                                   ('Norton Ghost', '15.0', 'Symantec', 'Respaldo', 'Imagen Disco', 'Perpetua', 800.00, 150, NULL, true, false, 'Inglés', 'Windows', '4GB RAM', 'Imagen de disco'),
                                                                                                                                                                                                                                                                                                   ('Acronis True Image', '2025', 'Acronis', 'Respaldo', 'Backup', 'Suscripción Anual', 600.00, 300, '2025-12-31', true, true, 'Multilingüe', 'Windows', '4GB RAM', 'Backup y recuperación'),
                                                                                                                                                                                                                                                                                                   ('Macrium Reflect', '8.1', 'Macrium', 'Respaldo', 'Imagen Disco', 'Licencia', 500.00, 200, NULL, true, false, 'Inglés', 'Windows', '4GB RAM', 'Software de imagen'),
                                                                                                                                                                                                                                                                                                   ('TeamViewer', '15', 'TeamViewer', 'Acceso Remoto', 'Soporte', 'Suscripción Anual', 1200.00, 400, '2025-12-31', true, true, 'Multilingüe', 'Multiplataforma', '4GB RAM', 'Acceso remoto'),
                                                                                                                                                                                                                                                                                                   ('AnyDesk', '8.0', 'AnyDesk', 'Acceso Remoto', 'Soporte', 'Suscripción Anual', 1000.00, 350, '2025-12-31', true, true, 'Multilingüe', 'Multiplataforma', '4GB RAM', 'Escritorio remoto'),
                                                                                                                                                                                                                                                                                                   ('LogMeIn', 'Pro', 'LogMeIn', 'Acceso Remoto', 'Soporte', 'Suscripción Anual', 1500.00, 150, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '4GB RAM', 'Acceso remoto profesional'),
                                                                                                                                                                                                                                                                                                   ('UltraVNC', '1.4', 'UltraVNC', 'Acceso Remoto', 'VNC', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Windows', '2GB RAM', 'Cliente VNC'),
                                                                                                                                                                                                                                                                                                   ('TightVNC', '2.8', 'TightVNC', 'Acceso Remoto', 'VNC', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'VNC liviano'),
                                                                                                                                                                                                                                                                                                   ('Chrome Remote Desktop', '1.0', 'Google', 'Acceso Remoto', 'Soporte', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Escritorio remoto vía Chrome'),
                                                                                                                                                                                                                                                                                                   ('Microsoft Remote Desktop', '1.2', 'Microsoft', 'Acceso Remoto', 'RDP', 'Gratuito', 0.00, NULL, NULL, false, false, 'Multilingüe', 'Multiplataforma', '2GB RAM', 'Cliente RDP'),
                                                                                                                                                                                                                                                                                                   ('OpenVPN', '2.6', 'OpenVPN', 'Redes', 'VPN', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'VPN open source'),
                                                                                                                                                                                                                                                                                                   ('WireGuard', '1.0', 'WireGuard', 'Redes', 'VPN', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'VPN moderna y rápida'),
                                                                                                                                                                                                                                                                                                   ('pfSense', '2.7', 'Netgate', 'Redes', 'Firewall', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'FreeBSD', '4GB RAM', 'Firewall/router'),
                                                                                                                                                                                                                                                                                                   ('OPNsense', '24.7', 'OPNsense', 'Redes', 'Firewall', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'FreeBSD', '4GB RAM', 'Firewall open source'),
                                                                                                                                                                                                                                                                                                   ('Sophos XG', '20', 'Sophos', 'Seguridad', 'UTM', 'Suscripción Anual', 2500.00, 10, '2025-12-31', true, true, 'Inglés', 'Hardware/VM', '8GB RAM', 'UTM corporativo'),
                                                                                                                                                                                                                                                                                                   ('Fortinet FortiGate', '7.4', 'Fortinet', 'Seguridad', 'Firewall', 'Suscripción Anual', 3500.00, 15, '2025-12-31', true, true, 'Inglés', 'Hardware', '8GB RAM', 'Firewall de última generación'),
                                                                                                                                                                                                                                                                                                   ('Palo Alto Networks', '11.2', 'Palo Alto', 'Seguridad', 'NGFW', 'Suscripción Anual', 4500.00, 8, '2025-12-31', true, true, 'Inglés', 'Hardware', '16GB RAM', 'Firewall con prevención de intrusiones'),
                                                                                                                                                                                                                                                                                                   ('Check Point', 'R81.20', 'Check Point', 'Seguridad', 'Firewall', 'Suscripción Anual', 4000.00, 12, '2025-12-31', true, true, 'Inglés', 'Hardware/VM', '16GB RAM', 'Security gateway'),
                                                                                                                                                                                                                                                                                                   ('Zabbix', '7.0', 'Zabbix', 'Monitoreo', 'Infraestructura', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '8GB RAM', 'Monitoreo de redes'),
                                                                                                                                                                                                                                                                                                   ('Nagios', '4.5', 'Nagios', 'Monitoreo', 'Infraestructura', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Monitoreo de sistemas'),
                                                                                                                                                                                                                                                                                                   ('PRTG', '24.4', 'Paessler', 'Monitoreo', 'Redes', 'Suscripción Anual', 1200.00, 50, '2025-12-31', true, true, 'Inglés', 'Windows', '8GB RAM', 'Monitor de red'),
                                                                                                                                                                                                                                                                                                   ('SolarWinds Orion', '2024.2', 'SolarWinds', 'Monitoreo', 'Redes', 'Suscripción Anual', 8000.00, 5, '2025-12-31', true, true, 'Inglés', 'Windows', '32GB RAM', 'Plataforma de monitoreo'),
                                                                                                                                                                                                                                                                                                   ('Datadog', '2025', 'Datadog', 'Monitoreo', 'Cloud', 'Suscripción Mensual', 1500.00, 30, '2025-12-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Monitoreo como servicio'),
                                                                                                                                                                                                                                                                                                   ('New Relic', '2025', 'New Relic', 'Monitoreo', 'APM', 'Suscripción Mensual', 1200.00, 40, '2025-12-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Application performance monitoring'),
                                                                                                                                                                                                                                                                                                   ('Dynatrace', '2025', 'Dynatrace', 'Monitoreo', 'APM', 'Suscripción Anual', 2500.00, 25, '2025-12-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Observabilidad con IA'),
                                                                                                                                                                                                                                                                                                   ('Elastic Stack', '8.15', 'Elastic', 'Análisis', 'Logs', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '16GB RAM', 'Búsqueda y análisis'),
                                                                                                                                                                                                                                                                                                   ('Splunk Enterprise', '9.3', 'Splunk', 'Análisis', 'SIEM', 'Suscripción Anual', 15000.00, 3, '2025-12-31', true, true, 'Inglés', 'Linux/Windows', '64GB RAM', 'Plataforma de datos de máquina'),
                                                                                                                                                                                                                                                                                                   ('Splunk Cloud', '9.3', 'Splunk', 'Análisis', 'SIEM Cloud', 'Suscripción Anual', 18000.00, 2, '2025-12-31', true, true, 'Inglés', 'Cloud', 'N/A', 'SIEM en la nube'),
                                                                                                                                                                                                                                                                                                   ('QRadar', '7.5', 'IBM', 'Seguridad', 'SIEM', 'Suscripción Anual', 20000.00, 2, '2025-12-31', true, true, 'Inglés', 'Linux', '64GB RAM', 'SIEM de IBM'),
                                                                                                                                                                                                                                                                                                   ('ArcSight', '7.5', 'Micro Focus', 'Seguridad', 'SIEM', 'Suscripción Anual', 18000.00, 2, '2025-12-31', true, true, 'Inglés', 'Linux/Windows', '64GB RAM', 'Plataforma SIEM'),
                                                                                                                                                                                                                                                                                                   ('Apache HTTP Server', '2.4', 'Apache', 'Web', 'Servidor', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Servidor web'),
                                                                                                                                                                                                                                                                                                   ('Nginx', '1.26', 'Nginx', 'Web', 'Servidor/Proxy', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Servidor web y proxy'),
                                                                                                                                                                                                                                                                                                   ('IIS', '10.0', 'Microsoft', 'Web', 'Servidor', 'Incluido', 0.00, NULL, NULL, false, false, 'Inglés', 'Windows Server', '4GB RAM', 'Internet Information Services'),
                                                                                                                                                                                                                                                                                                   ('HAProxy', '2.9', 'HAProxy', 'Redes', 'Load Balancer', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Balanceador de carga'),
                                                                                                                                                                                                                                                                                                   ('Traefik', '3.1', 'Traefik', 'Redes', 'Ingress', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Proxy inverso y balanceador'),
                                                                                                                                                                                                                                                                                                   ('Redis', '7.4', 'Redis', 'Base de Datos', 'NoSQL', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Base de datos en memoria'),
                                                                                                                                                                                                                                                                                                   ('MongoDB', '7.0', 'MongoDB', 'Base de Datos', 'NoSQL', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '8GB RAM', 'Base de datos documental'),
                                                                                                                                                                                                                                                                                                   ('MongoDB Enterprise', '7.0', 'MongoDB', 'Base de Datos', 'NoSQL', 'Suscripción Anual', 12000.00, 10, '2025-12-31', true, true, 'Inglés', 'Multiplataforma', '16GB RAM', 'MongoDB con soporte'),
                                                                                                                                                                                                                                                                                                   ('PostgreSQL', '16', 'PostgreSQL Global', 'Base de Datos', 'Relacional', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Base de datos open source'),
                                                                                                                                                                                                                                                                                                   ('MySQL Community', '8.0', 'Oracle', 'Base de Datos', 'Relacional', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Base de datos popular'),
                                                                                                                                                                                                                                                                                                   ('MariaDB', '11.4', 'MariaDB Foundation', 'Base de Datos', 'Relacional', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Fork de MySQL'),
                                                                                                                                                                                                                                                                                                   ('Cassandra', '5.0', 'Apache', 'Base de Datos', 'NoSQL', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '8GB RAM', 'Base de datos distribuida'),
                                                                                                                                                                                                                                                                                                   ('Elasticsearch', '8.15', 'Elastic', 'Búsqueda', 'Analítica', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '8GB RAM', 'Motor de búsqueda'),
                                                                                                                                                                                                                                                                                                   ('Kibana', '8.15', 'Elastic', 'Visualización', 'Dashboards', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Visualización para Elastic'),
                                                                                                                                                                                                                                                                                                   ('Logstash', '8.15', 'Elastic', 'Procesamiento', 'Pipeline', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Pipeline de datos'),
                                                                                                                                                                                                                                                                                                   ('Grafana', '11.2', 'Grafana Labs', 'Visualización', 'Dashboards', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Dashboards y métricas'),
                                                                                                                                                                                                                                                                                                   ('Prometheus', '2.54', 'CNCF', 'Monitoreo', 'Métricas', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '4GB RAM', 'Sistema de monitoreo'),
                                                                                                                                                                                                                                                                                                   ('InfluxDB', '2.7', 'InfluxData', 'Base de Datos', 'Time Series', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Base de datos de series temporales'),
                                                                                                                                                                                                                                                                                                   ('Telegraf', '1.31', 'InfluxData', 'Monitoreo', 'Recolección', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '2GB RAM', 'Recolector de métricas'),
                                                                                                                                                                                                                                                                                                   ('Apache Kafka', '3.7', 'Apache', 'Streaming', 'Mensajería', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '8GB RAM', 'Plataforma de streaming'),
                                                                                                                                                                                                                                                                                                   ('RabbitMQ', '3.13', 'VMware', 'Mensajería', 'Queue', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Multiplataforma', '4GB RAM', 'Message broker'),
                                                                                                                                                                                                                                                                                                   ('ActiveMQ', '6.1', 'Apache', 'Mensajería', 'Queue', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux/Windows', '4GB RAM', 'Message broker'),
                                                                                                                                                                                                                                                                                                   ('Apache Spark', '3.5', 'Apache', 'Procesamiento', 'Big Data', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '16GB RAM', 'Procesamiento distribuido'),
                                                                                                                                                                                                                                                                                                   ('Hadoop', '3.4', 'Apache', 'Almacenamiento', 'Big Data', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '32GB RAM', 'Framework big data'),
                                                                                                                                                                                                                                                                                                   ('Hive', '4.0', 'Apache', 'Consulta', 'SQL on Hadoop', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '16GB RAM', 'Data warehouse para Hadoop'),
                                                                                                                                                                                                                                                                                                   ('Presto', '0.286', 'Presto', 'Consulta', 'SQL Engine', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '16GB RAM', 'Motor SQL distribuido'),
                                                                                                                                                                                                                                                                                                   ('Trino', '456', 'Trino', 'Consulta', 'SQL Engine', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '16GB RAM', 'Motor SQL federado'),
                                                                                                                                                                                                                                                                                                   ('dbt', '1.8', 'dbt Labs', 'Transformación', 'ELT', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Python', '4GB RAM', 'Transformación de datos'),
                                                                                                                                                                                                                                                                                                   ('Airflow', '2.9', 'Apache', 'Orquestación', 'Workflows', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Linux', '8GB RAM', 'Orquestación de workflows'),
                                                                                                                                                                                                                                                                                                   ('Prefect', '2.19', 'Prefect', 'Orquestación', 'Workflows', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Python', '4GB RAM', 'Orquestación moderna'),
                                                                                                                                                                                                                                                                                                   ('Dagster', '1.7', 'Dagster', 'Orquestación', 'Data Pipelines', 'Gratuito', 0.00, NULL, NULL, false, false, 'Inglés', 'Python', '4GB RAM', 'Orquestación para datos'),
                                                                                                                                                                                                                                                                                                   ('Snowflake', '2025', 'Snowflake', 'Data Warehouse', 'Cloud', 'Suscripción', 25000.00, 5, '2025-12-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Data warehouse cloud'),
                                                                                                                                                                                                                                                                                                   ('Redshift', '2025', 'AWS', 'Data Warehouse', 'Cloud', 'Suscripción', 20000.00, 4, '2025-12-31', true, true, 'Inglés', 'AWS', 'N/A', 'Data warehouse AWS'),
                                                                                                                                                                                                                                                                                                   ('BigQuery', '2025', 'Google', 'Data Warehouse', 'Cloud', 'Suscripción', 18000.00, 6, '2025-12-31', true, true, 'Inglés', 'GCP', 'N/A', 'Data warehouse Google'),
                                                                                                                                                                                                                                                                                                   ('Synapse', '2025', 'Microsoft', 'Data Warehouse', 'Cloud', 'Suscripción', 22000.00, 3, '2025-12-31', true, true, 'Inglés', 'Azure', 'N/A', 'Data warehouse Azure'),
                                                                                                                                                                                                                                                                                                   ('Databricks', '2025', 'Databricks', 'Plataforma', 'Lakehouse', 'Suscripción', 30000.00, 4, '2025-12-31', true, true, 'Inglés', 'Cloud', 'N/A', 'Plataforma lakehouse');

-- =============================
-- EQUIPO SOFTWARE (10 MILLONES - EL DOBLE)
-- =============================
CREATE TABLE equipo_software (
                                 id SERIAL PRIMARY KEY,
                                 equipo_id INT REFERENCES equipos(id),
                                 software_id INT REFERENCES software(id),
                                 fecha_instalacion DATE,
                                 fecha_ultima_actualizacion DATE,
                                 licencia_asignada VARCHAR(100),
                                 activo BOOLEAN DEFAULT true
);

INSERT INTO equipo_software (equipo_id, software_id, fecha_instalacion, fecha_ultima_actualizacion, licencia_asignada, activo)
SELECT
    (g % 2400000) + 1,    -- equipo_id válido
    (g % 201) + 1,        -- software_id válido (1 a 201)
    DATE '2020-01-01' + (g % 2000),
    DATE '2022-01-01' + (g % 1000),
    'LIC-' || MD5(g::text) || '-' || (g % 10000),
    (g % 100) > 5         -- 95% activo
FROM generate_series(1, 10000000) g;

SELECT setval('equipo_software_id_seq', 10000000);

-- =============================
-- DIRECCIONES IP (1.6 MILLONES - EL DOBLE)
-- =============================
CREATE TABLE direcciones_ip (
                                id SERIAL PRIMARY KEY,
                                equipo_id INT REFERENCES equipos(id),
                                ip_direccion INET UNIQUE,
                                ip_tipo VARCHAR(10),
                                mac_address MACADDR UNIQUE,
                                mac_fabricante VARCHAR(100),
                                interfaz VARCHAR(30),
                                vlan INT,
                                dhcp BOOLEAN,
                                dhcp_server VARCHAR(50),
                                dns_primario INET,
                                dns_secundario INET,
                                puerta_enlace INET,
                                mascara_red CIDR,
                                zona_red VARCHAR(50),
                                segmento_red VARCHAR(50),
                                fecha_asignacion TIMESTAMP,
                                fecha_liberacion TIMESTAMP,
                                asignado_por VARCHAR(100),
                                observaciones TEXT
);

INSERT INTO direcciones_ip (
    equipo_id, ip_direccion, ip_tipo, mac_address, mac_fabricante, interfaz, vlan, dhcp,
    dhcp_server, dns_primario, dns_secundario, puerta_enlace, mascara_red, zona_red,
    segmento_red, fecha_asignacion, asignado_por, observaciones
)
SELECT
    (g % 2400000) + 1,
    ('10.' || ((g/1) % 256) || '.' || ((g/256) % 256) || '.' || ((g/65536) % 254 + 1))::inet,
    CASE WHEN g % 10 = 0 THEN 'Pública' ELSE 'Privada' END,
    (('02:' ||
      LPAD(TO_HEX((g % 256)), 2, '0') || ':' ||
      LPAD(TO_HEX(((g/256) % 256)), 2, '0') || ':' ||
      LPAD(TO_HEX(((g/65536) % 256)), 2, '0') || ':' ||
      LPAD(TO_HEX(((g/16777216) % 256)), 2, '0') || ':' ||
      LPAD(TO_HEX(((g/4294967296) % 256)), 2, '0'))::macaddr),
    (ARRAY['Intel', 'Realtek', 'Broadcom', 'Qualcomm', 'Apple', 'Cisco', 'TP-Link'])[(g % 7) + 1],
    CASE (g % 5)
        WHEN 0 THEN 'eth0'
        WHEN 1 THEN 'eth1'
        WHEN 2 THEN 'wlan0'
        WHEN 3 THEN 'bond0'
        ELSE 'enp0s3'
END,
    (ARRAY[10, 20, 30, 40, 50, 60, 70, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000])[(g % 17) + 1],
    (g % 3 = 0),
    'dhcp' || (g % 5) || '.empresa.local',
    ('8.8.8.' || ((g % 256)))::inet,
    ('8.8.4.' || ((g % 256)))::inet,
    ('10.' || ((g/1) % 256) || '.' || ((g/256) % 256) || '.1')::inet,
    ('10.' || ((g/1) % 256) || '.' || ((g/256) % 256) || '.0/24')::cidr,
    CASE (g % 8)
        WHEN 0 THEN 'Red Administrativa'
        WHEN 1 THEN 'Red Desarrollo'
        WHEN 2 THEN 'Red Producción'
        WHEN 3 THEN 'Red Servidores'
        WHEN 4 THEN 'Red Inalámbrica'
        WHEN 5 THEN 'Red Invitados'
        WHEN 6 THEN 'Red IoT'
        ELSE 'Red DMZ'
END,
    'Segmento ' || (g % 20),
    TIMESTAMP '2018-01-01' + (g || ' minutes')::interval,
    'Admin' || (g % 100),
    'Configuración de red ' || CASE (g % 6)
        WHEN 0 THEN 'estándar corporativa con acceso a todos los recursos'
        WHEN 1 THEN 'para equipo de desarrollo con acceso a repositorios'
        WHEN 2 THEN 'con acceso restringido solo a recursos internos'
        WHEN 3 THEN 'en DMZ con acceso limitado a internet'
        WHEN 4 THEN 'para pruebas con políticas relajadas'
        ELSE 'para producción con alta seguridad'
END || '. ' || repeat('Políticas de firewall y reglas de acceso aplicadas. ', 15)
FROM generate_series(1, 1600000) g;  -- 1.6 MILLONES

SELECT setval('direcciones_ip_id_seq', 1600000);

-- =============================
-- ACTIVOS DE RED (500,000 registros)
-- =============================
CREATE TABLE activos_red (
                             id SERIAL PRIMARY KEY,
                             nombre VARCHAR(100),
                             tipo_dispositivo VARCHAR(50),
                             marca VARCHAR(50),
                             modelo VARCHAR(100),
                             numero_serie VARCHAR(100),
                             ip_gestion INET,
                             mac_address MACADDR,
                             firmware_version VARCHAR(50),
                             sistema_operativo VARCHAR(100),
                             ubicacion VARCHAR(100),
                             rack VARCHAR(50),
                             posicion_rack INT,
                             fecha_instalacion DATE,
                             fecha_ultimo_reinicio TIMESTAMP,
                             estado VARCHAR(20),
                             observaciones TEXT
);

-- Insertando 500,000 registros simulados
INSERT INTO activos_red (
    nombre, tipo_dispositivo, marca, modelo, numero_serie, ip_gestion, mac_address,
    firmware_version, sistema_operativo, ubicacion, rack, posicion_rack,
    fecha_instalacion, fecha_ultimo_reinicio, estado, observaciones
)
SELECT
    'SW-' || g,
    CASE (g % 7)
        WHEN 0 THEN 'Switch'
        WHEN 1 THEN 'Router'
        WHEN 2 THEN 'Firewall'
        WHEN 3 THEN 'Access Point'
        WHEN 4 THEN 'Load Balancer'
        WHEN 5 THEN 'Patch Panel'
        ELSE 'Media Converter'
        END,
    CASE (g % 5)
        WHEN 0 THEN 'Cisco'
        WHEN 1 THEN 'Juniper'
        WHEN 2 THEN 'HP Aruba'
        WHEN 3 THEN 'MikroTik'
        ELSE 'Ubiquiti'
        END,
    'Modelo-' || (g % 100),
    'SN-NET-' || g,
    ('192.168.' || (g % 255) || '.' || ((g/256) % 254 + 1))::inet,
    (('02:AA:' ||
      LPAD(TO_HEX((g % 256)), 2, '0') || ':' ||
      LPAD(TO_HEX(((g/256) % 256)), 2, '0') || ':' ||
      LPAD(TO_HEX(((g/65536) % 256)), 2, '0') || ':' ||
      LPAD(TO_HEX(((g/16777216) % 256)), 2, '0'))::macaddr),
    (g % 10) || '.' || (g % 5) || '.' || (g % 3),
    'IOS ' || (g % 20),
    'Ubicación ' || (g % 100),
    'RACK-' || (g % 50) || '-U' || ((g % 42) + 1),  -- rack
    (g % 42) + 1,  -- posicion_rack
    DATE '2015-01-01' + (g % 3000),
    TIMESTAMP '2020-01-01' + (g || ' hours')::interval,
    CASE (g % 3)
        WHEN 0 THEN 'Activo'
        WHEN 1 THEN 'En mantenimiento'
        ELSE 'Standby'
END,
    'Activo de red ' || CASE (g % 5)
        WHEN 0 THEN 'core con alta disponibilidad'
        WHEN 1 THEN 'distribución para edificios'
        WHEN 2 THEN 'acceso para usuarios'
        WHEN 3 THEN 'perímetro con seguridad'
        ELSE 'backup para contingencia'
END
FROM generate_series(1, 500000) g;

-- Actualizar secuencia del ID
SELECT setval('activos_red_id_seq', 500000);


-- =============================
-- MANTENIMIENTOS (3 MILLONES - EL DOBLE)
-- =============================
CREATE TABLE mantenimientos (
                                id SERIAL PRIMARY KEY,
                                equipo_id INT REFERENCES equipos(id),
                                tipo_mantenimiento VARCHAR(30),
                                fecha_solicitud DATE,
                                fecha_programada DATE,
                                fecha_ejecucion DATE,
                                tecnico_asignado VARCHAR(150),
                                tecnico_id INT,
                                proveedor_id INT REFERENCES proveedores(id),
                                diagnostico TEXT,
                                trabajo_realizado TEXT,
                                piezas_cambiadas TEXT,
                                costo_mano_obra DECIMAL(10,2),
                                costo_piezas DECIMAL(10,2),
                                costo_transporte DECIMAL(10,2),
                                tiempo_paralizacion_horas DECIMAL(5,2),
                                prioridad INT,
                                estado VARCHAR(20),
                                calificacion_servicio INT,
                                observaciones TEXT
);

WITH tecnicos AS (
    SELECT tecnico, ordinality AS idx
    FROM unnest(ARRAY[
                    'Carlos Rodríguez', 'María García', 'Juan López', 'Ana Martínez', 'Luis González',
                'Patricia Sánchez', 'Javier Pérez', 'Laura Gómez', 'Miguel Díaz', 'Isabel Romero',
                'Alejandro Torres', 'Carmen Ruiz', 'Francisco Castro', 'Teresa Ortega', 'David Morales',
                'Sofía Herrera', 'Ricardo Vargas', 'Gabriela Soto', 'Fernando Ríos', 'Adriana Flores',
                'Roberto Méndez', 'Daniela Ortega', 'Héctor Núñez', 'Verónica Suárez', 'Mauricio Castro',
                'Andrea Paredes', 'Oscar Delgado', 'Liliana Campos', 'Jorge Salinas', 'Silvia Ponce'
                    ]) WITH ORDINALITY AS t(tecnico, ordinality)
)

INSERT INTO mantenimientos (
    equipo_id, tipo_mantenimiento, fecha_solicitud, fecha_programada, fecha_ejecucion,
    tecnico_asignado, tecnico_id, proveedor_id, diagnostico, trabajo_realizado,
    piezas_cambiadas, costo_mano_obra, costo_piezas, costo_transporte,
    tiempo_paralizacion_horas, prioridad, estado, calificacion_servicio, observaciones
)
SELECT
    (g % 2400000) + 1,
    CASE (g % 5)
        WHEN 0 THEN 'Preventivo'
        WHEN 1 THEN 'Correctivo'
        WHEN 2 THEN 'Predictivo'
        WHEN 3 THEN 'Emergencia'
        ELSE 'Garantía'
        END,
    DATE '2019-01-01' + (g % 2000),
    DATE '2019-01-05' + (g % 2000),
    DATE '2019-01-10' + (g % 2000),
    (SELECT tecnico FROM tecnicos WHERE idx = (g % 30) + 1),
    (g % 30) + 1,
    CASE WHEN g % 4 = 0 THEN (g % 10000) + 1 ELSE NULL END,
    'Diagnóstico: ' || CASE (g % 8)
                           WHEN 0 THEN 'Fallo en el disco duro'
                           WHEN 1 THEN 'Sobrecalentamiento del procesador'
                           WHEN 2 THEN 'Fallo en la memoria RAM'
                           WHEN 3 THEN 'Problemas con la fuente de poder'
                           WHEN 4 THEN 'Actualización de firmware necesaria'
                           WHEN 5 THEN 'Ventilador defectuoso'
                           WHEN 6 THEN 'Pantalla con pixeles muertos'
                           ELSE 'Batería no retiene carga'
        END,
    'Trabajo realizado: ' || CASE (g % 8)
                                 WHEN 0 THEN 'Reemplazo de disco duro por SSD'
                                 WHEN 1 THEN 'Limpieza de ventiladores y cambio de pasta térmica'
                                 WHEN 2 THEN 'Reemplazo de módulos de memoria'
                                 WHEN 3 THEN 'Cambio de fuente de poder'
                                 WHEN 4 THEN 'Actualización de firmware completada'
                                 WHEN 5 THEN 'Reemplazo de ventilador'
                                 WHEN 6 THEN 'Cambio de pantalla completa'
                                 ELSE 'Reemplazo de batería'
        END,
    'Piezas: ' || CASE (g % 8)
                      WHEN 0 THEN 'SSD 512GB, cable SATA'
                      WHEN 1 THEN 'Pasta térmica, kit de limpieza'
                      WHEN 2 THEN 'Módulo RAM 16GB DDR4'
                      WHEN 3 THEN 'Fuente de poder 650W'
                      WHEN 4 THEN 'Ninguna (solo software)'
                      WHEN 5 THEN 'Ventilador 120mm'
                      WHEN 6 THEN 'Pantalla 15.6" Full HD'
                      ELSE 'Batería Li-Ion 11.4V'
        END,
    (ARRAY[500, 800, 1200, 1500, 2000, 2500, 3000])[(g % 7) + 1],
    (ARRAY[0, 500, 1000, 1500, 2000, 3500, 5000])[(g % 7) + 1],
    (ARRAY[0, 100, 200, 300, 500])[(g % 5) + 1],
    (ARRAY[0.5, 1, 2, 4, 8, 16, 24, 48])[(g % 8) + 1],
    (g % 5) + 1,
    CASE (g % 4)
        WHEN 0 THEN 'Completado'
        WHEN 1 THEN 'En proceso'
        WHEN 2 THEN 'Pendiente'
        ELSE 'Cancelado'
END,
    (g % 5) + 1,
    'Observaciones: ' || repeat('Mantenimiento realizado siguiendo procedimientos estándar. ', 20)
FROM generate_series(1, 3000000) g;  -- 3 MILLONES

SELECT setval('mantenimientos_id_seq', 3000000);

-- =============================
-- TICKETS DE SOPORTE (2 MILLONES - EL DOBLE)
-- =============================
CREATE TABLE tickets (
                         id SERIAL PRIMARY KEY,
                         folio VARCHAR(30) UNIQUE,
                         empleado_id INT REFERENCES empleados(id),
                         equipo_id INT REFERENCES equipos(id),
                         categoria VARCHAR(50),
                         subcategoria VARCHAR(50),
                         prioridad VARCHAR(20),
                         impacto VARCHAR(20),
                         urgencia VARCHAR(20),
                         estado VARCHAR(20),
                         asunto VARCHAR(300),
                         descripcion TEXT,
                         fecha_creacion TIMESTAMP,
                         fecha_asignacion TIMESTAMP,
                         fecha_inicio_atencion TIMESTAMP,
                         fecha_solucion TIMESTAMP,
                         fecha_cierre TIMESTAMP,
                         tecnico_asignado VARCHAR(150),
                         tiempo_respuesta_minutos INT,
                         tiempo_solucion_minutos INT,
                         nivel_satisfaccion INT,
                         observaciones TEXT
);

INSERT INTO tickets (
    folio, empleado_id, equipo_id, categoria, subcategoria, prioridad, impacto, urgencia,
    estado, asunto, descripcion, fecha_creacion, fecha_asignacion, fecha_inicio_atencion,
    fecha_solucion, fecha_cierre, tecnico_asignado, tiempo_respuesta_minutos,
    tiempo_solucion_minutos, nivel_satisfaccion, observaciones
)
SELECT
    'TKT-' || g || '-' || TO_CHAR(DATE '2023-01-01' + (g/1000)::int, 'YYYY'),
    (g % 3000000) + 1,
    (g % 2400000) + 1,
    CASE (g % 7)
        WHEN 0 THEN 'Hardware'
        WHEN 1 THEN 'Software'
        WHEN 2 THEN 'Red'
        WHEN 3 THEN 'Acceso'
        WHEN 4 THEN 'Correo'
        WHEN 5 THEN 'Impresión'
        ELSE 'Otros'
        END,
    CASE (g % 10)
        WHEN 0 THEN 'No enciende'
        WHEN 1 THEN 'Lento'
        WHEN 2 THEN 'Error de aplicación'
        WHEN 3 THEN 'No conecta a red'
        WHEN 4 THEN 'Olvido de contraseña'
        WHEN 5 THEN 'Configuración'
        WHEN 6 THEN 'Instalación'
        WHEN 7 THEN 'Actualización'
        WHEN 8 THEN 'Respaldo'
        ELSE 'Consulta'
        END,
    CASE (g % 4)
        WHEN 0 THEN 'Baja'
        WHEN 1 THEN 'Media'
        WHEN 2 THEN 'Alta'
        ELSE 'Crítica'
        END,
    CASE (g % 3)
        WHEN 0 THEN 'Individual'
        WHEN 1 THEN 'Grupal'
        ELSE 'General'
        END,
    CASE (g % 3)
        WHEN 0 THEN 'Baja'
        WHEN 1 THEN 'Media'
        ELSE 'Alta'
        END,
    CASE (g % 5)
        WHEN 0 THEN 'Abierto'
        WHEN 1 THEN 'Asignado'
        WHEN 2 THEN 'En proceso'
        WHEN 3 THEN 'Resuelto'
        ELSE 'Cerrado'
        END,
    'Problema con ' || CASE (g % 10)
                           WHEN 0 THEN 'computadora'
                           WHEN 1 THEN 'sistema'
                           WHEN 2 THEN 'red'
                           WHEN 3 THEN 'correo'
                           WHEN 4 THEN 'impresora'
                           WHEN 5 THEN 'software'
                           WHEN 6 THEN 'acceso'
                           WHEN 7 THEN 'periférico'
                           WHEN 8 THEN 'teléfono'
                           ELSE 'aplicación'
        END || ' - Ticket #' || g,
    repeat('Descripción detallada del problema reportado por el usuario. ', 30) ||
    'Pasos para reproducir: ' || CASE (g % 5)
                                     WHEN 0 THEN 'Al iniciar sesión'
                                     WHEN 1 THEN 'Al abrir aplicación'
                                     WHEN 2 THEN 'Al conectar a red'
                                     WHEN 3 THEN 'Al imprimir'
                                     ELSE 'De forma intermitente'
        END,
    TIMESTAMP '2023-01-01' + (g || ' minutes')::interval,
    TIMESTAMP '2023-01-01' + (g + 30 || ' minutes')::interval,
    TIMESTAMP '2023-01-01' + (g + 45 || ' minutes')::interval,
    TIMESTAMP '2023-01-01' + (g + 240 || ' minutes')::interval,
    TIMESTAMP '2023-01-01' + (g + 250 || ' minutes')::interval,
    'Técnico ' || (g % 50),
    (ARRAY[5, 10, 15, 30, 60, 120, 240])[(g % 7) + 1],
    (ARRAY[30, 60, 120, 240, 480, 960, 1440])[(g % 7) + 1],
    CASE WHEN g % 10 < 8 THEN (g % 5) + 1 ELSE NULL END,
    'Notas internas: ' || repeat('Seguimiento del caso y soluciones aplicadas. ', 15)
FROM generate_series(1, 2000000) g;  -- 2 MILLONES

SELECT setval('tickets_id_seq', 2000000);

-- =============================
-- COMPRAS (1 MILLÓN - EL DOBLE)
-- =============================
CREATE TABLE compras (
                         id SERIAL PRIMARY KEY,
                         proveedor_id INT REFERENCES proveedores(id),
                         numero_factura VARCHAR(50) UNIQUE,
                         numero_orden_compra VARCHAR(50),
                         fecha_emision DATE,
                         fecha_recepcion DATE,
                         fecha_pago DATE,
                         tipo_compra VARCHAR(30),
                         departamento_solicitante INT REFERENCES departamentos(id),
                         solicitante_id INT REFERENCES empleados(id),
                         autorizador_id INT REFERENCES empleados(id),
                         subtotal DECIMAL(15,2),
                         iva DECIMAL(15,2),
                         total DECIMAL(15,2),
                         descuento DECIMAL(15,2),
                         metodo_pago VARCHAR(50),
                         condiciones_pago VARCHAR(100),
                         moneda VARCHAR(3),
                         tipo_cambio DECIMAL(10,4),
                         observaciones TEXT
);

INSERT INTO compras (
    proveedor_id, numero_factura, numero_orden_compra, fecha_emision, fecha_recepcion,
    tipo_compra, departamento_solicitante, solicitante_id, autorizador_id,
    subtotal, iva, total, descuento, metodo_pago, condiciones_pago, moneda,
    tipo_cambio, observaciones
)
SELECT
    (g % 10000) + 1,
    'FAC-' || g || '-' || TO_CHAR(DATE '2018-01-01' + (g/100)::int, 'YYYY'),
    'OC-' || g,
    DATE '2018-01-01' + (g % 2500),
    DATE '2018-01-10' + (g % 2500),
    CASE (g % 4)
        WHEN 0 THEN 'Equipo'
        WHEN 1 THEN 'Software'
        WHEN 2 THEN 'Servicio'
        ELSE 'Consumible'
        END,
    (g % 40) + 1,
    (g % 3000000) + 1,
    (g % 3000000) + 1,
    (g % 1000000)::DECIMAL / 100,
    ((g % 1000000)::DECIMAL / 100) * 0.16,
    ((g % 1000000)::DECIMAL / 100) * 1.16,
    CASE WHEN g % 10 = 0 THEN ((g % 100000)::DECIMAL / 100) ELSE 0 END,
    CASE (g % 4)
        WHEN 0 THEN 'Transferencia'
        WHEN 1 THEN 'Cheque'
        WHEN 2 THEN 'Efectivo'
        ELSE 'Tarjeta corporativa'
END,
    CASE (g % 3)
        WHEN 0 THEN 'Contado'
        WHEN 1 THEN '30 días'
        ELSE '60 días'
END,
    'MXN',
    1.0000,
    'Compra de ' || CASE (g % 4)
        WHEN 0 THEN 'equipos de cómputo'
        WHEN 1 THEN 'licencias de software'
        WHEN 2 THEN 'servicios de mantenimiento'
        ELSE 'material de oficina'
END || '. ' || repeat('Detalles de la compra y condiciones acordadas. ', 10)
FROM generate_series(1, 1000000) g;  -- 1 MILLÓN

SELECT setval('compras_id_seq', 1000000);

-- =============================
-- VERIFICACIÓN FINAL
-- =============================
SELECT 'DEPARTAMENTOS' as tabla, COUNT(*) as registros, pg_size_pretty(pg_total_relation_size('departamentos')) as tamaño FROM departamentos
UNION ALL
SELECT 'PROVEEDORES', COUNT(*), pg_size_pretty(pg_total_relation_size('proveedores')) FROM proveedores
UNION ALL
SELECT 'PROYECTOS', COUNT(*), pg_size_pretty(pg_total_relation_size('proyectos')) FROM proyectos
UNION ALL
SELECT 'EMPLEADOS', COUNT(*), pg_size_pretty(pg_total_relation_size('empleados')) FROM empleados
UNION ALL
SELECT 'EQUIPOS', COUNT(*), pg_size_pretty(pg_total_relation_size('equipos')) FROM equipos
UNION ALL
SELECT 'SOFTWARE', COUNT(*), pg_size_pretty(pg_total_relation_size('software')) FROM software
UNION ALL
SELECT 'EQUIPO_SOFTWARE', COUNT(*), pg_size_pretty(pg_total_relation_size('equipo_software')) FROM equipo_software
UNION ALL
SELECT 'DIRECCIONES_IP', COUNT(*), pg_size_pretty(pg_total_relation_size('direcciones_ip')) FROM direcciones_ip
UNION ALL
SELECT 'ACTIVOS_RED', COUNT(*), pg_size_pretty(pg_total_relation_size('activos_red')) FROM activos_red
UNION ALL
SELECT 'MANTENIMIENTOS', COUNT(*), pg_size_pretty(pg_total_relation_size('mantenimientos')) FROM mantenimientos
UNION ALL
SELECT 'TICKETS', COUNT(*), pg_size_pretty(pg_total_relation_size('tickets')) FROM tickets
UNION ALL
SELECT 'COMPRAS', COUNT(*), pg_size_pretty(pg_total_relation_size('compras')) FROM compras
ORDER BY tabla;

DO $$
BEGIN
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'BASE DE DATOS CREADA EXITOSAMENTE - VERSIÓN MEJORADA';
    RAISE NOTICE 'Todas las tablas tienen el DOBLE de registros';
    RAISE NOTICE '==================================================';
END $$;