CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    codigo_cliente VARCHAR(50) NOT NULL,
    cliente_primer_nombre VARCHAR(100),
    cliente_segundo_nombre VARCHAR(100),
    cliente_tercer_nombre VARCHAR(100),
    cliente_primer_apellido VARCHAR(100),
    cliente_segundo_apellido VARCHAR(100),
    apellido_casada VARCHAR(100),
    genero CHAR(1),
    cui VARCHAR(20),
    depto_nacimiento VARCHAR(50),
    muni_nacimiento VARCHAR(50),
    vecindad VARCHAR(100),
    estado_civil VARCHAR(50),
    nacionalidad VARCHAR(50),
    ocupacion VARCHAR(100),
    fecha_nacimiento DATE,
    fecha_vencimiento_dpi DATE,
    prestamo_id SERIAL,
    codigo_prestamo VARCHAR(50),
    monto_solicitado MONEY,
    cuotas_pactadas INT,
    porcentaje_interes DECIMAL(5, 2),
    prestamo_iva MONEY,
    prestamo_cargos_administrativos MONEY,
    prestamo_total MONEY,
    motivo_prestamo TEXT,
    prestamo_estatus VARCHAR(50),

    referencia1_primer_nombre VARCHAR(100),
    referencia1_segundo_nombre VARCHAR(100),
    referencia1_tercer_nombre VARCHAR(100),
    referencia1_primer_apellido VARCHAR(100),
    referencia1_segundo_apellido VARCHAR(100),
    referencia1_telefono VARCHAR(20),

    referencia2_primer_nombre VARCHAR(100),
    referencia2_segundo_nombre VARCHAR(100),
    referencia2_tercer_nombre VARCHAR(100),
    referencia2_primer_apellido VARCHAR(100),
    referencia2_segundo_apellido VARCHAR(100),
    referencia2_telefono VARCHAR(20),

    referencia3_primer_nombre VARCHAR(100),
    referencia3_segundo_nombre VARCHAR(100),
    referencia3_tercer_nombre VARCHAR(100),
    referencia3_primer_apellido VARCHAR(100),
    referencia3_segundo_apellido VARCHAR(100),
    referencia3_telefono VARCHAR(20),

    referencia4_primer_nombre VARCHAR(100),
    referencia4_segundo_nombre VARCHAR(100),
    referencia4_tercer_nombre VARCHAR(100),
    referencia4_primer_apellido VARCHAR(100),
    referencia4_segundo_apellido VARCHAR(100),
    referencia4_telefono VARCHAR(20),

    pago1_fecha_esperada DATE,
    pago2_fecha_esperada DATE,
    pago3_fecha_esperada DATE,
    pago4_fecha_esperada DATE,
    pago5_fecha_esperada DATE,
    pago6_fecha_esperada DATE,
    pago7_fecha_esperada DATE,
    pago8_fecha_esperada DATE,
    pago9_fecha_esperada DATE,
    pago10_fecha_esperada DATE,
    pago11_fecha_esperada DATE,
    pago12_fecha_esperada DATE
);

COPY clientes FROM '/tmp/prestamosdatos.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE pagos_realizados (
    pago_realizado_id SERIAL PRIMARY KEY,
    pago_realizado_fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pago_realizado_fecha_pago TIMESTAMP,
    pago_realizado_monto_pagado MONEY NOT NULL,
    pago_realizado_correlativo VARCHAR(50) NOT NULL,

    validacion1_fecha_creacion TIMESTAMP,
    validacion1_estatus VARCHAR(20),
    validacion1_validado_por VARCHAR(100),

    validacion2_fecha_creacion TIMESTAMP,
    validacion2_estatus VARCHAR(20),
    validacion2_validado_por VARCHAR(100),

    validacion3_fecha_creacion TIMESTAMP,
    validacion3_estatus VARCHAR(20),
    validacion3_validado_por VARCHAR(100),

    validacion4_fecha_creacion TIMESTAMP,
    validacion4_estatus VARCHAR(20),
    validacion4_validado_por VARCHAR(100)
);

COPY pagos_realizados FROM '/tmp/pagosdatos.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE roles (
    rol_id SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

INSERT INTO roles (nombre_rol, descripcion) VALUES
('Validador', 'Valida'),
('Cliente', 'Clientes');



CREATE TABLE usuarios (
    usuario_id SERIAL PRIMARY KEY,
    codigo_cliente VARCHAR(50) NOT NULL,
    rol_id INT NOT NULL,
    genero CHAR(1),
    cui VARCHAR(20),
    fecha_nacimiento DATE,
    estado_civil VARCHAR(50),
    nacionalidad VARCHAR(50),
    primer_nombre VARCHAR(100),
    segundo_nombre VARCHAR(100),
    tercer_nombre VARCHAR(100),
    primer_apellido VARCHAR(100),
    segundo_apellido VARCHAR(100),
    apellido_casada VARCHAR(100),

    FOREIGN KEY (rol_id) REFERENCES roles(rol_id)
);

CREATE TABLE direccion_usuario (
    direccion_usuario_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    depto_nacimiento VARCHAR(100) NOT NULL,
    muni_nacimiento VARCHAR(100) NOT NULL,
    vecindad VARCHAR(100),

    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);

INSERT INTO usuarios (codigo_cliente, rol_id, genero, cui, fecha_nacimiento, estado_civil, nacionalidad,
                      primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, apellido_casada)
SELECT codigo_cliente,
       2 AS rol_id,  
       genero,
       cui,
       fecha_nacimiento,
       estado_civil,
       nacionalidad,
       cliente_primer_nombre AS primer_nombre,
       cliente_segundo_nombre AS segundo_nombre,
       cliente_tercer_nombre AS tercer_nombre,
       cliente_primer_apellido AS primer_apellido,
       cliente_segundo_apellido AS segundo_apellido,
       apellido_casada
FROM clientes;

INSERT INTO direccion_usuario (usuario_id, depto_nacimiento, muni_nacimiento, vecindad)
SELECT u.usuario_id,
       c.depto_nacimiento,
       c.muni_nacimiento,
       c.vecindad
FROM clientes c
JOIN usuarios u ON c.codigo_cliente = u.codigo_cliente;

CREATE TABLE IF NOT EXISTS ocupaciones (
    ocupacion_id SERIAL PRIMARY KEY,
    nombre_ocupacion VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO ocupaciones (nombre_ocupacion)
SELECT DISTINCT ocupacion
FROM clientes
WHERE ocupacion IS NOT NULL;  

ALTER TABLE usuarios
ADD COLUMN ocupaciones_id INT;

UPDATE usuarios u
SET ocupaciones_id = o.ocupacion_id
FROM clientes c
JOIN ocupaciones o ON c.ocupacion = o.nombre_ocupacion
WHERE u.codigo_cliente = c.codigo_cliente;


CREATE TABLE prestamo_estatus (
    estatus_id SERIAL PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO prestamo_estatus (descripcion) VALUES
('Approved'),
('Pending'),
('Denied');

CREATE TABLE prestamo (
    prestamo_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    codigo_prestamo VARCHAR(50) NOT NULL,
    motivo_prestamo TEXT,
    prestamo_estatus_id INT NOT NULL,
    monto_solicitado MONEY NOT NULL,
    cuotas_pactadas INT NOT NULL,
    porcentaje_interes DECIMAL(5, 2) NOT NULL,

    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    FOREIGN KEY (prestamo_estatus_id) REFERENCES prestamo_estatus(estatus_id)
);

INSERT INTO prestamo (usuario_id, codigo_prestamo, motivo_prestamo, prestamo_estatus_id, monto_solicitado, cuotas_pactadas, porcentaje_interes)
SELECT u.usuario_id,
       c.codigo_prestamo,  
       c.motivo_prestamo,  
       pe.estatus_id,     
       c.monto_solicitado,  
       c.cuotas_pactadas,   
       c.porcentaje_interes  
FROM clientes c
JOIN usuarios u ON c.codigo_cliente = u.codigo_cliente  
JOIN prestamo_estatus pe ON pe.descripcion = c.prestamo_estatus;  


CREATE TABLE cargos_administrativos (
    cargos_id SERIAL PRIMARY KEY,
    prestamo_id INT NOT NULL,
    prestamo_iva MONEY NOT NULL,
    prestamo_cargos_administrativos MONEY NOT NULL,
    prestamo_total MONEY NOT NULL,

    FOREIGN KEY (prestamo_id) REFERENCES prestamo(prestamo_id)
);

INSERT INTO cargos_administrativos (prestamo_id, prestamo_iva, prestamo_cargos_administrativos, prestamo_total)
SELECT p.prestamo_id,
       c.prestamo_iva,  
       c.prestamo_cargos_administrativos,  
       c.prestamo_total 
FROM clientes c
JOIN prestamo p ON c.codigo_prestamo = p.codigo_prestamo;  

CREATE TABLE referencias (
    referencia_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    referencia1_primer_nombre VARCHAR(100),
    referencia1_segundo_nombre VARCHAR(100),
    referencia1_tercer_nombre VARCHAR(100),
    referencia1_primer_apellido VARCHAR(100),
    referencia1_segundo_apellido VARCHAR(100),
    referencia1_telefono VARCHAR(20),

    referencia2_primer_nombre VARCHAR(100),
    referencia2_segundo_nombre VARCHAR(100),
    referencia2_tercer_nombre VARCHAR(100),
    referencia2_primer_apellido VARCHAR(100),
    referencia2_segundo_apellido VARCHAR(100),
    referencia2_telefono VARCHAR(20),

    referencia3_primer_nombre VARCHAR(100),
    referencia3_segundo_nombre VARCHAR(100),
    referencia3_tercer_nombre VARCHAR(100),
    referencia3_primer_apellido VARCHAR(100),
    referencia3_segundo_apellido VARCHAR(100),
    referencia3_telefono VARCHAR(20),

    referencia4_primer_nombre VARCHAR(100),
    referencia4_segundo_nombre VARCHAR(100),
    referencia4_tercer_nombre VARCHAR(100),
    referencia4_primer_apellido VARCHAR(100),
    referencia4_segundo_apellido VARCHAR(100),
    referencia4_telefono VARCHAR(20),

    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);

INSERT INTO referencias (usuario_id,
                         referencia1_primer_nombre, referencia1_segundo_nombre,
                         referencia1_tercer_nombre,  referencia1_primer_apellido,
                         referencia1_segundo_apellido,  referencia1_telefono,
                         referencia2_primer_nombre,  referencia2_segundo_nombre,
                         referencia2_tercer_nombre,  referencia2_primer_apellido,
                         referencia2_segundo_apellido,  referencia2_telefono,
                         referencia3_primer_nombre,  referencia3_segundo_nombre,
                         referencia3_tercer_nombre,  referencia3_primer_apellido,
                         referencia3_segundo_apellido,  referencia3_telefono,
                         referencia4_primer_nombre,  referencia4_segundo_nombre,
                         referencia4_tercer_nombre,  referencia4_primer_apellido,
                         referencia4_segundo_apellido,  referencia4_telefono)
SELECT u.usuario_id,
       c.referencia1_primer_nombre,
       c.referencia1_segundo_nombre,
       c.referencia1_tercer_nombre,
       c.referencia1_primer_apellido,
       c.referencia1_segundo_apellido,
       c.referencia1_telefono,
       c.referencia2_primer_nombre,
       c.referencia2_segundo_nombre,
       c.referencia2_tercer_nombre,
       c.referencia2_primer_apellido,
       c.referencia2_segundo_apellido,
       c.referencia2_telefono,
       c.referencia3_primer_nombre,
       c.referencia3_segundo_nombre,
       c.referencia3_tercer_nombre,
       c.referencia3_primer_apellido,
       c.referencia3_segundo_apellido,
       c.referencia3_telefono,
       c.referencia4_primer_nombre,
       c.referencia4_segundo_nombre,
       c.referencia4_tercer_nombre,
       c.referencia4_primer_apellido,
       c.referencia4_segundo_apellido,
       c.referencia4_telefono
FROM clientes c
JOIN usuarios u ON c.codigo_cliente = u.codigo_cliente;  


CREATE TABLE validadores (
    validador_id SERIAL PRIMARY KEY,
    validador_nombre VARCHAR(100) NOT NULL UNIQUE
);


INSERT INTO validadores (validador_nombre)
SELECT DISTINCT validacion1_validado_por
FROM pagos_realizados
WHERE validacion1_validado_por IS NOT NULL;  

ALTER TABLE usuarios
ALTER COLUMN codigo_cliente DROP NOT NULL;

CREATE TABLE pagos (
    pago_realizado_id SERIAL PRIMARY KEY,
    prestamo_id INT NOT NULL,
    pago_realizado_fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pago_realizado_fecha_pago TIMESTAMP,
    pago_realizado_monto_pagado MONEY NOT NULL,
    pago_realizado_correlativo VARCHAR(50) NOT NULL UNIQUE,

    FOREIGN KEY (prestamo_id) REFERENCES prestamo(prestamo_id)
);












