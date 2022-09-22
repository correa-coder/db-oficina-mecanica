/* Script para PostgreSQL */

CREATE DATABASE oficina_mecanica;

\c oficina_mecanica;

-- criação de enums no SGBD PostgreSQL
CREATE TYPE role_enum AS ENUM ('repair', 'revision');
CREATE TYPE status_enum AS ENUM ('available', 'in progress', 'complete', 'archived');
CREATE TYPE category_enum AS ENUM ('painting', 'revision', 'component replacement');
CREATE TYPE vehicle_enum AS ENUM ('car', 'bike', 'truck', 'bus');

/* COMANDOS DDL */

CREATE TABLE customer(
    cpf CHAR(11) UNIQUE NOT NULL PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    customer_address VARCHAR(180) NOT NULL 
);

CREATE TABLE vehicle(
    license_plate CHAR(11) UNIQUE NOT NULL PRIMARY KEY,
    vehicle_type vehicle_enum NOT NULL,
    customer_cpf CHAR(11) REFERENCES customer(cpf)
);

CREATE TABLE team(
    team_id BIGSERIAL NOT NULL PRIMARY KEY,
    team_role role_enum NOT NULL,
    assigned_vehicle_license CHAR(11) REFERENCES vehicle(license_plate) ON DELETE CASCADE
);

CREATE TABLE mechanic(
    code CHAR(8) UNIQUE NOT NULL PRIMARY KEY,
    mechanic_name VARCHAR(150) NOT NULL,
    mechanic_address VARCHAR(180) NOT NULL,
    category category_enum NOT NULL,
    team_id BIGINT REFERENCES team(team_id) ON DELETE CASCADE
);

CREATE TABLE service_order(
    order_number BIGSERIAL NOT NULL PRIMARY KEY,
    order_status status_enum NOT NULL,
    order_description VARCHAR(150) NOT NULL,
    price FLOAT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    allowed_by_customer BOOLEAN DEFAULT false,
    team_id BIGINT REFERENCES team(team_id) ON DELETE CASCADE
);

CREATE TABLE labor(
    labor_id BIGSERIAL NOT NULL PRIMARY KEY,
    labor_description VARCHAR(120) NOT NULL,
    price FLOAT NOT NULL
);

CREATE TABLE order_has_labor(
    order_number BIGINT REFERENCES service_order(order_number),
    labor_id BIGINT REFERENCES labor(labor_id),
    PRIMARY KEY(order_number, labor_id)
);

CREATE TABLE vehicle_component(
    component_id BIGSERIAL NOT NULL PRIMARY KEY,
    component_name VARCHAR(45) NOT NULL,
    price FLOAT NOT NULL
);

/* COMANDOS DML */

INSERT INTO customer
VALUES
('*********01', 'Karen Daniels', 'Liberty City'),
('*********02', 'Lester Crester', 'Los Santos');

INSERT INTO vehicle
VALUES
('***-***-GHI', 'bike', '*********01'),
('***-***-DEF', 'car', '*********02');

INSERT INTO team(team_role, assigned_vehicle_license)
VALUES
('repair', '***-***-DEF'),
('revision', '***-***-GHI');

INSERT INTO mechanic
VALUES
('12345601', 'Jethro', 'San Fierro', 'component replacement', 1),
('12345602', 'Dwaine', 'San Fierro', 'painting', 1),
('12345603', 'Johnny Klebitz', 'Sandy Shore', 'component replacement', 1),
('12345604', 'Niko Bellic', 'Liberty City', 'revision', 2),
('12345605', 'Luis Lopez', 'Liberty City', 'revision', 2);

INSERT INTO vehicle_component(component_name, price)
VALUES
('Rear bumper', 400),
('Front bumper', 250),
('Battery', 800),
('Wheel', 600),
('Steering wheel', 140);

INSERT INTO labor(labor_description, price)
VALUES
('component replacement', 600),
('painting', 1500),
('revision', 700);

INSERT INTO service_order
VALUES
(1, 'available', 'Para-choque dianteiro danificado e riscos leves na lataria', 2350, '01-01-2022', '20-01-2022', true, 1),
(2, 'in progress', 'Revisão periódica', 2350, '02-02-2022', '06-02-2022', false, 2);

INSERT INTO order_has_labor(order_number, labor_id) VALUES (1, 1), (1, 2), (2, 3);

/* COMANDOS DQL */

-- Quais são os serviços oferecidos?
SELECT * FROM labor;

-- Quais mecânicos moram em Liberty City?
SELECT * FROM mechanic WHERE mechanic_address = 'Liberty City';

-- Quantos mêcanicos estão na categoria de troca de componente?
SELECT COUNT(*) AS contagem FROM mechanic WHERE category = 'component replacement';

-- Quais cidades não se repetem entre o endereço dos mecânicos?
SELECT mechanic_address, COUNT(*) AS contagem
FROM mechanic
GROUP BY mechanic_address
HAVING COUNT(*) = 1;

-- Junção entre tabela cliente e veículo
SELECT * from customer
JOIN vehicle
ON customer.cpf = vehicle.customer_cpf;