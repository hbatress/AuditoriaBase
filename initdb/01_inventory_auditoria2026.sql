-- =========================================
-- INVENTARIO INFORMÁTICO MASIVO - AUDITORIA2026
-- DATOS 100% REALISTAS PARA EMPRESA CORPORATIVA
-- =========================================

-- =========================================
-- SCRIPT COMPLETO: ELIMINA Y RECREA TODO
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

-- También eliminar secuencias (por si acaso)
DROP SEQUENCE IF EXISTS departamentos_id_seq CASCADE;
DROP SEQUENCE IF EXISTS empleados_id_seq CASCADE;
DROP SEQUENCE IF EXISTS equipos_id_seq CASCADE;
DROP SEQUENCE IF EXISTS software_id_seq CASCADE;
DROP SEQUENCE IF EXISTS equipo_software_id_seq CASCADE;
DROP SEQUENCE IF EXISTS direcciones_ip_id_seq CASCADE;
DROP SEQUENCE IF EXISTS mantenimientos_id_seq CASCADE;
DROP SEQUENCE IF EXISTS tickets_id_seq CASCADE;
DROP SEQUENCE IF EXISTS compras_id_seq CASCADE;

SELECT setseed(0.2026);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================
-- DEPARTAMENTOS REALES
-- =============================
CREATE TABLE departamentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150),
    descripcion TEXT,
    centro_costo VARCHAR(50),
    ubicacion VARCHAR(100)
);

INSERT INTO departamentos (nombre, descripcion, centro_costo, ubicacion) VALUES
('Dirección General', 'Alta dirección y estrategia corporativa', 'CC-1000', 'Piso 15 Torre Ejecutiva'),
('Finanzas', 'Gestión contable, tesorería y reporting financiero', 'CC-2000', 'Piso 12 Torre Ejecutiva'),
('Recursos Humanos', 'Gestión del talento, nómina y desarrollo organizacional', 'CC-2100', 'Piso 10 Torre Ejecutiva'),
('Tecnologías de la Información', 'Infraestructura, soporte y desarrollo de sistemas', 'CC-3000', 'Piso 8 Torre Tecnológica'),
('Operaciones', 'Gestión de procesos operativos y logística interna', 'CC-4000', 'Planta Baja Edificio Central'),
('Marketing', 'Publicidad, redes sociales y comunicación corporativa', 'CC-5000', 'Piso 5 Torre Ejecutiva'),
('Ventas', 'Fuerza de ventas y atención a clientes', 'CC-5100', 'Piso 3 Torre Ejecutiva'),
('Compras', 'Adquisiciones y proveedores', 'CC-2200', 'Piso 7 Torre Logística'),
('Legal', 'Asesoría jurídica y cumplimiento normativo', 'CC-1100', 'Piso 14 Torre Ejecutiva'),
('Investigación y Desarrollo', 'Innovación y nuevos productos', 'CC-6000', 'Piso 2 Torre Tecnológica'),
('Atención al Cliente', 'Soporte post-venta y call center', 'CC-5200', 'Piso 1 Edificio Central'),
('Logística', 'Almacenes y distribución', 'CC-4100', 'Nave 3 Parque Industrial'),
('Calidad', 'Control de calidad y mejora continua', 'CC-4200', 'Laboratorio Planta'),
('Seguridad', 'Seguridad física y patrimonial', 'CC-7000', 'Módulo de Seguridad Principal'),
('Mantenimiento', 'Mantenimiento de instalaciones', 'CC-4300', 'Taller General'),
('Sistemas', 'Desarrollo de software y bases de datos', 'CC-3100', 'Piso 9 Torre Tecnológica'),
('Redes y Comunicaciones', 'Infraestructura de red y telecomunicaciones', 'CC-3200', 'Data Center Principal'),
('Ciberseguridad', 'Seguridad informática y protección de datos', 'CC-3300', 'Piso 8 Torre Tecnológica'),
('Business Intelligence', 'Análisis de datos y reporting', 'CC-3400', 'Piso 6 Torre Tecnológica'),
('Proyectos', 'Gestión de proyectos estratégicos', 'CC-8000', 'Piso 4 Torre Ejecutiva');

-- =============================
-- EMPLEADOS REALES
-- =============================
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150),
    apellidos VARCHAR(150),
    email VARCHAR(150) UNIQUE,
    departamento_id INT REFERENCES departamentos(id),
    puesto VARCHAR(100),
    telefono VARCHAR(20),
    extension VARCHAR(10),
    fecha_ingreso DATE,
    fecha_nacimiento DATE,
    genero CHAR(1),
    nss VARCHAR(20),
    rfc VARCHAR(20),
    curp VARCHAR(25),
    calle VARCHAR(100),
    ciudad VARCHAR(50),
    estado VARCHAR(50),
    codigo_postal VARCHAR(10),
    observaciones TEXT
);

-- Generamos 1.5 millones de empleados con datos realistas
WITH nombres AS (
    SELECT unnest(ARRAY[
        'Carlos', 'María', 'José', 'Ana', 'Juan', 'Laura', 'Jorge', 'Patricia', 'Luis', 'Sofía',
        'Miguel', 'Isabel', 'Alejandro', 'Carmen', 'Francisco', 'Teresa', 'Javier', 'Marta',
        'Antonio', 'Elena', 'David', 'Cristina', 'Jesús', 'Sara', 'Rafael', 'Rosa', 'Manuel',
        'Paula', 'Pedro', 'Andrea', 'Ángel', 'Claudia', 'Óscar', 'Verónica', 'Rubén', 'Silvia',
        'Sergio', 'Natalia', 'Pablo', 'Raquel', 'Fernando', 'Eva', 'Andrés', 'Irene', 'Adrián',
        'Beatriz', 'Héctor', 'Alicia', 'Iván', 'Olga'
    ]) AS nombre
),
apellidos AS (
    SELECT unnest(ARRAY[
        'García', 'Rodríguez', 'Martínez', 'Hernández', 'López', 'González', 'Pérez', 'Sánchez',
        'Ramírez', 'Torres', 'Flores', 'Rivera', 'Gómez', 'Díaz', 'Reyes', 'Morales', 'Cruz',
        'Ortiz', 'Gutiérrez', 'Chávez', 'Romero', 'Álvarez', 'Castillo', 'Jiménez', 'Vargas',
        'Moreno', 'Rojas', 'Herrera', 'Medina', 'Aguilar', 'Castro', 'Suárez', 'Mendoza',
        'Vega', 'Ruiz', 'Domínguez', 'Delgado', 'Silva', 'Cabrera', 'Velázquez', 'Montoya',
        'Espinoza', 'Valdez', 'Cortés', 'Ríos', 'Guzmán', 'Núñez', 'Salazar', 'Ponce', 'Acosta'
    ]) AS apellido
),
puestos AS (
    SELECT unnest(ARRAY[
        'Director', 'Gerente', 'Subgerente', 'Coordinador', 'Analista Senior', 'Analista',
        'Asistente', 'Técnico', 'Especialista', 'Consultor', 'Desarrollador', 'Programador',
        'Administrador', 'Supervisor', 'Jefe de Departamento', 'Líder de Proyecto', 'Arquitecto',
        'Ingeniero', 'Diseñador', 'Contador', 'Abogado', 'Médico', 'Enfermero', 'Psicólogo',
        'Capacitador', 'Reclutador', 'Vendedor', 'Ejecutivo de Cuenta', 'Representante',
        'Soporte Técnico', 'Auditor', 'Secretario', 'Recepcionista', 'Mensajero', 'Chofer'
    ]) AS puesto
)
INSERT INTO empleados (nombre, apellidos, email, departamento_id, puesto, telefono, extension, fecha_ingreso, fecha_nacimiento, genero, nss, rfc, curp, calle, ciudad, estado, codigo_postal, observaciones)
SELECT
    (SELECT nombre FROM nombres ORDER BY random() LIMIT 1),
    (SELECT apellido FROM apellidos ORDER BY random() LIMIT 1) || ' ' || (SELECT apellido FROM apellidos ORDER BY random() LIMIT 1),
    lower(empleado_nombre) || '.' || lower(empleado_apellido1) || g || '@empresacorporativa.com',
    (g % 20) + 1,
    (SELECT puesto FROM puestos ORDER BY random() LIMIT 1),
    '55' || LPAD((g % 10000000)::text, 8, '0'),
    LPAD((g % 500)::text, 3, '0'),
    DATE '2010-01-01' + (random() * 5000)::int,
    DATE '1960-01-01' + (random() * 15000)::int,
    CASE WHEN random() > 0.5 THEN 'M' ELSE 'F' END,
    LPAD((g % 1000000000)::text, 11, '0'),
    'RFC' || LPAD((g % 10000000000)::text, 10, '0') || 'ABC',
    'CURP' || LPAD((g % 10000000000)::text, 18, '0'),
    'Calle ' || (random() * 1000)::int || ' #' || (random() * 100)::int,
    (ARRAY['Ciudad de México', 'Monterrey', 'Guadalajara', 'Puebla', 'Querétaro', 'Toluca', 'León'])[(g % 7) + 1],
    (ARRAY['CDMX', 'Nuevo León', 'Jalisco', 'Puebla', 'Querétaro', 'Estado de México', 'Guanajuato'])[(g % 7) + 1],
    LPAD((g % 100000)::text, 5, '0'),
    'Empleado con perfil ' || CASE (g % 5)
        WHEN 0 THEN 'administrativo'
        WHEN 1 THEN 'técnico'
        WHEN 2 THEN 'operativo'
        WHEN 3 THEN 'gerencial'
        ELSE 'especializado'
    END || '. ' || repeat('Descripción detallada del perfil laboral y observaciones relevantes sobre su desempeño y habilidades. ', 50)
FROM generate_series(1, 1500000) g
CROSS JOIN LATERAL (
    SELECT 
        (SELECT nombre FROM nombres ORDER BY random() LIMIT 1) AS empleado_nombre,
        (SELECT apellido FROM apellidos ORDER BY random() LIMIT 1) AS empleado_apellido1
) sub;

-- =============================
-- EQUIPOS INFORMÁTICOS REALES
-- =============================
CREATE TABLE equipos (
    id SERIAL PRIMARY KEY,
    codigo_activo VARCHAR(50) UNIQUE,
    tipo_equipo VARCHAR(30),
    marca VARCHAR(50),
    modelo VARCHAR(100),
    numero_serie VARCHAR(100),
    procesador VARCHAR(100),
    velocidad_ghz DECIMAL(3,1),
    nucleos INT,
    ram_gb INT,
    ram_tipo VARCHAR(20),
    almacenamiento_principal_gb INT,
    almacenamiento_principal_tipo VARCHAR(20),
    almacenamiento_secundario_gb INT,
    almacenamiento_secundario_tipo VARCHAR(20),
    sistema_operativo VARCHAR(100),
    sistema_operativo_version VARCHAR(30),
    office_version VARCHAR(50),
    empleado_id INT REFERENCES empleados(id),
    fecha_compra DATE,
    fecha_asignacion DATE,
    garantia_meses INT,
    proveedor VARCHAR(100),
    numero_factura VARCHAR(50),
    costo_compra DECIMAL(10,2),
    estado VARCHAR(20),
    observaciones TEXT
);

-- Insertamos 1.2 millones de equipos reales
INSERT INTO equipos (codigo_activo, tipo_equipo, marca, modelo, numero_serie, procesador, velocidad_ghz, nucleos, ram_gb, ram_tipo, almacenamiento_principal_gb, almacenamiento_principal_tipo, almacenamiento_secundario_gb, almacenamiento_secundario_tipo, sistema_operativo, sistema_operativo_version, office_version, empleado_id, fecha_compra, fecha_asignacion, garantia_meses, proveedor, numero_factura, costo_compra, estado, observaciones)
SELECT
    'ACT-' || LPAD(g::text, 8, '0'),
    CASE (g % 7)
        WHEN 0 THEN 'Laptop Ejecutiva'
        WHEN 1 THEN 'Laptop Profesional'
        WHEN 2 THEN 'Desktop Oficina'
        WHEN 3 THEN 'Workstation'
        WHEN 4 THEN 'Servidor'
        WHEN 5 THEN 'Tablet'
        ELSE 'All-in-One'
    END,
    CASE (g % 5)
        WHEN 0 THEN 'Dell'
        WHEN 1 THEN 'HP'
        WHEN 2 THEN 'Lenovo'
        WHEN 3 THEN 'Apple'
        ELSE 'Microsoft'
    END,
    CASE (g % 20)
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
        ELSE 'EliteOne 800 G6'
    END,
    'SN-' || g || '-' || md5(g::text),
    CASE (g % 8)
        WHEN 0 THEN 'Intel Core i5'
        WHEN 1 THEN 'Intel Core i7'
        WHEN 2 THEN 'Intel Core i9'
        WHEN 3 THEN 'AMD Ryzen 5'
        WHEN 4 THEN 'AMD Ryzen 7'
        WHEN 5 THEN 'AMD Ryzen 9'
        WHEN 6 THEN 'Apple M1'
        ELSE 'Apple M2'
    END,
    (ARRAY[2.1, 2.5, 2.9, 3.2, 3.6, 4.0, 4.4])[(g % 7) + 1],
    (ARRAY[4, 6, 8, 10, 12, 16, 24])[(g % 7) + 1],
    (ARRAY[8, 16, 32, 64, 128, 256])[(g % 6) + 1],
    (ARRAY['DDR3', 'DDR4', 'DDR4', 'DDR5', 'LPDDR4', 'LPDDR5'])[(g % 6) + 1],
    (ARRAY[256, 512, 1024, 2048, 4096])[(g % 5) + 1],
    (ARRAY['SSD NVMe', 'SSD SATA', 'HDD 7200rpm', 'SSD NVMe', 'HDD 5400rpm'])[(g % 5) + 1],
    CASE WHEN g % 3 = 0 THEN (ARRAY[1024, 2048, 4096])[(g % 3) + 1] ELSE NULL END,
    CASE WHEN g % 3 = 0 THEN (ARRAY['HDD 7200rpm', 'SSD SATA', 'HDD 5400rpm'])[(g % 3) + 1] ELSE NULL END,
    CASE (g % 4)
        WHEN 0 THEN 'Windows 10 Pro'
        WHEN 1 THEN 'Windows 11 Pro'
        WHEN 2 THEN 'macOS'
        ELSE 'Ubuntu Linux'
    END,
    CASE (g % 5)
        WHEN 0 THEN '22H2'
        WHEN 1 THEN '23H2'
        WHEN 2 THEN '24H2'
        WHEN 3 THEN 'Ventura'
        ELSE 'Sonoma'
    END,
    CASE (g % 3)
        WHEN 0 THEN 'Microsoft 365'
        WHEN 1 THEN 'Office 2021'
        ELSE 'Office 2019'
    END,
    (g % 1500000) + 1,
    DATE '2020-01-01' + (random() * 1500)::int,
    DATE '2020-02-01' + (random() * 1500)::int,
    (ARRAY[12, 24, 36, 48, 60])[(g % 5) + 1],
    (ARRAY['Dell Technologies', 'HP Inc.', 'Lenovo Group', 'Apple Inc.', 'Microsoft Store', 'CDI Computación', 'Grupo SBF'])[(g % 7) + 1],
    'FAC-' || g || '-' || (2020 + (g % 5))::text,
    (ARRAY[15000, 22000, 35000, 48000, 65000, 85000, 120000])[(g % 7) + 1] + (random() * 5000)::int,
    CASE (g % 4)
        WHEN 0 THEN 'Activo'
        WHEN 1 THEN 'Asignado'
        WHEN 2 THEN 'En reparación'
        ELSE 'Stock'
    END,
    'Equipo ' || CASE (g % 10)
        WHEN 0 THEN 'nuevo adquirido para renovación tecnológica'
        WHEN 1 THEN 'reemplazo por fin de vida útil'
        WHEN 2 THEN 'asignado a nuevo ingreso'
        WHEN 3 THEN 'con mantenimiento preventivo programado'
        WHEN 4 THEN 'en evaluación de rendimiento'
        WHEN 5 THEN 'con extensión de garantía'
        WHEN 6 THEN 'para usuario de alto rendimiento'
        WHEN 7 THEN 'estándar corporativo'
        WHEN 8 THEN 'especializado para diseño'
        ELSE 'configuración básica'
    END || '. ' || repeat('Especificaciones técnicas detalladas y observaciones del ciclo de vida del activo informático. ', 30)
FROM generate_series(1, 1200000) g;

-- =============================
-- SOFTWARE CORPORATIVO REAL
-- =============================
CREATE TABLE software (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150),
    version VARCHAR(30),
    fabricante VARCHAR(100),
    categoria VARCHAR(50),
    tipo_licencia VARCHAR(50),
    precio_licencia DECIMAL(10,2),
    numero_licencias_contratadas INT,
    fecha_vencimiento_licencia DATE,
    descripcion TEXT
);

INSERT INTO software (nombre, version, fabricante, categoria, tipo_licencia, precio_licencia, numero_licencias_contratadas, fecha_vencimiento_licencia, descripcion) VALUES
('Microsoft Windows 11 Pro', '24H2', 'Microsoft Corporation', 'Sistema Operativo', 'Volumen', 2500.00, 5000, '2025-12-31', 'Sistema operativo estándar corporativo con características de seguridad avanzadas y gestión centralizada.'),
('Microsoft Windows 10 Pro', '22H2', 'Microsoft Corporation', 'Sistema Operativo', 'Volumen', 2200.00, 3000, '2025-10-31', 'Versión anterior del sistema operativo para equipos compatibles.'),
('Microsoft Office 365 E3', '2025', 'Microsoft Corporation', 'Suite Ofimática', 'Suscripción Anual', 1800.00, 8000, '2025-11-30', 'Suite completa de productividad con aplicaciones de escritorio y servicios en la nube.'),
('Microsoft Office 2021 Pro', '2021', 'Microsoft Corporation', 'Suite Ofimática', 'Perpetua', 4500.00, 1500, NULL, 'Versión perpetua de Office para estaciones de trabajo especializadas.'),
('Adobe Creative Cloud', '2025', 'Adobe Inc.', 'Diseño Gráfico', 'Suscripción Anual', 8500.00, 250, '2025-08-31', 'Suite completa para diseño gráfico, edición de video y fotografía.'),
('Adobe Acrobat Pro DC', '2024', 'Adobe Inc.', 'PDF', 'Suscripción Anual', 1800.00, 2000, '2025-09-30', 'Editor y gestor de documentos PDF profesional.'),
('AutoCAD', '2025', 'Autodesk', 'Diseño Técnico', 'Suscripción Anual', 12000.00, 80, '2025-07-31', 'Software de diseño asistido por computadora para ingeniería y arquitectura.'),
('SolidWorks', '2024', 'Dassault Systèmes', 'Diseño Mecánico', 'Suscripción Anual', 25000.00, 45, '2025-06-30', 'Diseño paramétrico 3D para ingeniería mecánica.'),
('MATLAB', 'R2024b', 'MathWorks', 'Cálculo Técnico', 'Suscripción Anual', 15000.00, 60, '2025-05-31', 'Entorno de programación y cálculo numérico para ingeniería.'),
('SAP Business One', '10.0', 'SAP SE', 'ERP', 'Perpetua + Mantenimiento', 45000.00, 1, '2025-12-31', 'Sistema de planificación de recursos empresariales.'),
('Oracle Database', '19c', 'Oracle Corporation', 'Base de Datos', 'Enterprise', 350000.00, 1, '2025-10-31', 'Sistema gestor de base de datos empresarial.'),
('SQL Server Standard', '2022', 'Microsoft Corporation', 'Base de Datos', 'Licencia por Core', 150000.00, 4, '2025-09-30', 'Base de datos relacional para aplicaciones corporativas.'),
('Visual Studio Enterprise', '2022', 'Microsoft Corporation', 'Desarrollo', 'Suscripción Anual', 12000.00, 120, '2025-08-31', 'Entorno de desarrollo integrado para aplicaciones empresariales.'),
('Visual Studio Code', '1.95', 'Microsoft Corporation', 'Desarrollo', 'Gratuito', 0.00, NULL, NULL, 'Editor de código gratuito y multiplataforma.'),
('GitHub Enterprise', '3.12', 'GitHub Inc.', 'Control Versiones', 'Suscripción Anual', 4500.00, 150, '2025-11-30', 'Plataforma de control de versiones y colaboración.'),
('Jira Software', '9.12', 'Atlassian', 'Gestión Proyectos', 'Suscripción Anual', 3200.00, 300, '2025-07-31', 'Software de seguimiento de proyectos y gestión ágil.'),
('Confluence', '8.9', 'Atlassian', 'Colaboración', 'Suscripción Anual', 1800.00, 500, '2025-07-31', 'Wiki corporativa y gestión de conocimiento.'),
('Slack', 'Enterprise Grid', 'Slack Technologies', 'Comunicación', 'Suscripción Anual', 1500.00, 2000, '2025-12-31', 'Plataforma de comunicación y colaboración en equipo.'),
('Zoom', '6.2', 'Zoom Video Communications', 'Videoconferencia', 'Suscripción Anual', 1200.00, 3000, '2025-10-31', 'Plataforma de videoconferencias y reuniones virtuales.'),
('Cisco Webex', '44.11', 'Cisco Systems', 'Videoconferencia', 'Suscripción Anual', 1300.00, 1500, '2025-09-30', 'Soluciones de colaboración unificada.'),
('Symantec Endpoint Protection', '14.3', 'Broadcom', 'Antivirus', 'Suscripción Anual', 350.00, 8000, '2025-12-31', 'Protección antivirus y antimalware corporativo.'),
('CrowdStrike Falcon', '7.15', 'CrowdStrike', 'Seguridad', 'Suscripción Anual', 800.00, 4000, '2025-11-30', 'Protección de endpoints basada en IA.'),
('VMware vSphere', '8.0', 'VMware Inc.', 'Virtualización', 'Enterprise Plus', 85000.00, 20, '2025-08-31', 'Plataforma de virtualización de servidores.'),
('Veeam Backup', '12.1', 'Veeam Software', 'Respaldo', 'Suscripción Anual', 45000.00, 5, '2025-10-31', 'Software de respaldo y recuperación.'),
('Tableau Desktop', '2024.3', 'Salesforce', 'BI', 'Suscripción Anual', 3200.00, 200, '2025-07-31', 'Herramienta de visualización de datos.'),
('Power BI Pro', '2.130', 'Microsoft Corporation', 'BI', 'Suscripción Anual', 950.00, 600, '2025-09-30', 'Plataforma de business intelligence y análisis.'),
('SAP SuccessFactors', 'Q4 2024', 'SAP SE', 'RRHH', 'Suscripción Anual', 1200.00, 1500, '2025-12-31', 'Gestión de capital humano en la nube.'),
('Workday', '2024 R2', 'Workday Inc.', 'RRHH', 'Suscripción Anual', 1500.00, 1500, '2025-11-30', 'Suite de gestión de recursos humanos y financiera.'),
('Salesforce Sales Cloud', 'Winter 25', 'Salesforce', 'CRM', 'Suscripción Anual', 2500.00, 400, '2025-10-31', 'Gestión de relaciones con clientes.'),
('HubSpot', 'Enterprise', 'HubSpot', 'Marketing', 'Suscripción Anual', 2800.00, 150, '2025-08-31', 'Plataforma de inbound marketing y ventas.'),
('Zendesk', 'Suite 2025', 'Zendesk', 'Soporte', 'Suscripción Anual', 1100.00, 300, '2025-09-30', 'Plataforma de atención al cliente.'),
('ServiceNow', 'Washington DC', 'ServiceNow', 'ITSM', 'Suscripción Anual', 7500.00, 200, '2025-07-31', 'Gestión de servicios de TI.'),
('Norton Ghost', '15.0', 'Symantec', 'Respaldo', 'Perpetua', 800.00, 100, NULL, 'Software de imagen de disco y respaldo.'),
('WinRAR', '7.01', 'RARLAB', 'Compresión', 'Shareware', 350.00, 2000, NULL, 'Compresor de archivos.'),
('7-Zip', '24.08', 'Igor Pavlov', 'Compresión', 'Gratuito', 0.00, NULL, NULL, 'Compresor de archivos de código abierto.'),
('Google Chrome', '120', 'Google LLC', 'Navegador', 'Gratuito', 0.00, NULL, NULL, 'Navegador web.'),
('Mozilla Firefox', '115', 'Mozilla Foundation', 'Navegador', 'Gratuito', 0.00, NULL, NULL, 'Navegador web de código abierto.'),
('FileZilla', '3.66', 'FileZilla Project', 'FTP', 'Gratuito', 0.00, NULL, NULL, 'Cliente FTP.'),
('Putty', '0.80', 'Simon Tatham', 'SSH', 'Gratuito', 0.00, NULL, NULL, 'Cliente SSH y telnet.'),
('Postman', '11.10', 'Postman Inc.', 'API', 'Gratuito', 0.00, NULL, NULL, 'Plataforma para desarrollo de APIs.'),
('Docker Desktop', '4.34', 'Docker Inc.', 'Contenedores', 'Suscripción Anual', 2500.00, 80, '2025-12-31', 'Plataforma de contenedores.'),
('Kubernetes', '1.30', 'CNCF', 'Orquestación', 'Gratuito', 0.00, NULL, NULL, 'Orquestación de contenedores.'),
('Ansible', '9.4', 'Red Hat', 'Automatización', 'Gratuito', 0.00, NULL, NULL, 'Automatización de TI.'),
('Terraform', '1.9', 'HashiCorp', 'Infraestructura', 'Gratuito', 0.00, NULL, NULL, 'Infraestructura como código.'),
('Python', '3.12', 'Python Software Foundation', 'Lenguaje', 'Gratuito', 0.00, NULL, NULL, 'Lenguaje de programación.'),
('Java JDK', '21 LTS', 'Oracle Corporation', 'Lenguaje', 'Gratuito', 0.00, NULL, NULL, 'Kit de desarrollo Java.'),
('Node.js', '20.18', 'OpenJS Foundation', 'Lenguaje', 'Gratuito', 0.00, NULL, NULL, 'Entorno de ejecución JavaScript.'),
('Git', '2.46', 'Git Project', 'Control Versiones', 'Gratuito', 0.00, NULL, NULL, 'Sistema de control de versiones.');

-- =============================
-- DIRECCIONES IP REALES
-- =============================
CREATE TABLE direcciones_ip (
    id SERIAL PRIMARY KEY,
    equipo_id INT REFERENCES equipos(id),
    ip_direccion INET,
    mac_address MACADDR,
    interfaz VARCHAR(30),
    vlan INT,
    dhcp BOOLEAN,
    dns_servidores TEXT,
    puerta_enlace INET,
    mascara_red CIDR,
    zona_red VARCHAR(50),
    fecha_asignacion TIMESTAMP,
    observaciones TEXT
);

-- Insertamos 800,000 direcciones IP
INSERT INTO direcciones_ip (equipo_id, ip_direccion, mac_address, interfaz, vlan, dhcp, dns_servidores, puerta_enlace, mascara_red, zona_red, fecha_asignacion, observaciones)
SELECT
    (g % 1200000) + 1,
    ('10.' || (g % 256) || '.' || ((g/256) % 256) || '.' || ((g/65536) % 254 + 1))::inet,
    (('02:' || LPAD(TO_HEX((g % 256)), 2, '0') || ':' || LPAD(TO_HEX(((g/256) % 256)), 2, '0') || ':' || LPAD(TO_HEX(((g/65536) % 256)), 2, '0') || ':' || LPAD(TO_HEX(((g/16777216) % 256)), 2, '0') || ':' || LPAD(TO_HEX(((g/4294967296) % 256)), 2, '0'))::macaddr),
    CASE (g % 4)
        WHEN 0 THEN 'eth0'
        WHEN 1 THEN 'wlan0'
        WHEN 2 THEN 'enp0s3'
        ELSE 'en0'
    END,
    (ARRAY[10, 20, 30, 40, 50, 60, 70, 100, 200, 300, 400, 500])[(g % 12) + 1],
    (g % 3 = 0),
    '8.8.8.8, 1.1.1.1, 208.67.222.222',
    ('10.' || (g % 256) || '.' || ((g/256) % 256) || '.1')::inet,
    ('10.' || (g % 256) || '.' || ((g/256) % 256) || '.0/24')::cidr,
    CASE (g % 6)
        WHEN 0 THEN 'Red Administrativa'
        WHEN 1 THEN 'Red Desarrollo'
        WHEN 2 THEN 'Red Producción'
        WHEN 3 THEN 'Red Servidores'
        WHEN 4 THEN 'Red Inalámbrica'
        ELSE 'Red Invitados'
    END,
    TIMESTAMP '2020-01-01' + (random() * 1825 || ' days')::interval,
    'Configuración de red ' || CASE (g % 5)
        WHEN 0 THEN 'estándar corporativa'
        WHEN 1 THEN 'para equipo de desarrollo'
        WHEN 2 THEN 'con acceso restringido'
        WHEN 3 THEN 'en DMZ'
        ELSE 'para pruebas'
    END || '. ' || repeat('Detalles de configuración de red y políticas de seguridad aplicadas. ', 10)
FROM generate_series(1, 800000) g;

-- =============================
-- MANTENIMIENTOS REALES
-- =============================
CREATE TABLE mantenimientos (
    id SERIAL PRIMARY KEY,
    equipo_id INT REFERENCES equipos(id),
    tipo_mantenimiento VARCHAR(30),
    fecha_solicitud DATE,
    fecha_programada DATE,
    fecha_ejecucion DATE,
    tecnico_asignado VARCHAR(150),
    proveedor_externo VARCHAR(150),
    diagnostico TEXT,
    trabajo_realizado TEXT,
    piezas_cambiadas TEXT,
    costo_mano_obra DECIMAL(10,2),
    costo_piezas DECIMAL(10,2),
    tiempo_paralizacion_horas DECIMAL(5,2),
    prioridad VARCHAR(20),
    estado VARCHAR(20),
    observaciones TEXT
);

-- Insertamos 1.5 millones de mantenimientos
WITH tecnicos AS (
    SELECT unnest(ARRAY[
        'Carlos Rodríguez', 'María García', 'Juan López', 'Ana Martínez', 'Luis González',
        'Patricia Sánchez', 'Javier Pérez', 'Laura Gómez', 'Miguel Díaz', 'Isabel Romero',
        'Alejandro Torres', 'Carmen Ruiz', 'Francisco Castro', 'Teresa Ortega', 'David Morales'
    ]) AS tecnico
),
proveedores_externos AS (
    SELECT unnest(ARRAY[
        'Dell Servicios México', 'HP Care Pack', 'Lenovo ProSupport', 'AppleCare Enterprise',
        'Grupo Sistel', 'Integradora de Tecnología', 'Servicios Técnicos Profesionales',
        'Mantenimiento Computacional', 'Red de Soporte Técnico', 'Global Support Services'
    ]) AS proveedor
)
INSERT INTO mantenimientos (equipo_id, tipo_mantenimiento, fecha_solicitud, fecha_programada, fecha_ejecucion, tecnico_asignado, proveedor_externo, diagnostico, trabajo_realizado, piezas_cambiadas, costo_mano_obra, costo_piezas, tiempo_paralizacion_horas, prioridad, estado, observaciones)
SELECT
    (g % 1200000) + 1,
    CASE (g % 4)
        WHEN 0 THEN 'Preventivo'
        WHEN 1 THEN 'Correctivo'
        WHEN 2 THEN 'Predictivo'
        ELSE 'Emergencia'
    END,
    DATE '2021-01-01' + (random()