-- Create DB
CREATE DATABASE desafio_latam;

-- Conectando
\c desafio_latam;

--- Creando tablas

CREATE TABLE peliculas
(
    peliculas_id BIGSERIAL NOT NULL PRIMARY KEY,
    nombre       VARCHAR(255) NOT NULL,
    anno         INT NOT NULL
);

CREATE TABLE tags
(
    tags_id BIGSERIAL NOT NULL PRIMARY KEY,
    tag     VARCHAR(32) NOT NULL
);

CREATE TABLE peliculas_tags
(
    peliculas_id BIGINT REFERENCES peliculas(peliculas_id),
    tags_id BIGINT REFERENCES tags(tags_id)
);

--- Insertando información
INSERT INTO peliculas(nombre, anno) VALUES ('Van Helsing', 2004);
INSERT INTO peliculas(nombre, anno) VALUES ('Inception', 2010);
INSERT INTO peliculas(nombre, anno) VALUES ('Interestellar', 2014);
INSERT INTO peliculas(nombre, anno) VALUES ('Avatar', 2009);
INSERT INTO peliculas(nombre, anno) VALUES ('Dark Waters', 2019);

INSERT INTO tags(tag) VALUES ('Action');
INSERT INTO tags(tag) VALUES ('Fantasy');
INSERT INTO tags(tag) VALUES ('Adventure');
INSERT INTO tags(tag) VALUES ('Sci-Fi');
INSERT INTO tags(tag) VALUES ('Drama');

-- Checkin Info
SELECT * FROM peliculas;
SELECT * FROM tags;

--- Agregando información a peliculas_tags

INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (1, 1);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (1, 2);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (1, 3);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (2, 1);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (2, 4);

-- Checkin Info again
SELECT * FROM peliculas_tags;

--- Tags de cada película
SELECT peliculas.nombre, COUNT(tags) as tags FROM peliculas 
LEFT JOIN peliculas_tags USING (peliculas_id)
LEFT JOIN tags USING (tags_id)
GROUP BY peliculas.nombre;

--- Crear un nuevo modelo
-- Para hacerlo más "realista", lo haremos con UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--- Creando tablas
CREATE TABLE questions
(
    questions_uid UUID NOT NULL PRIMARY KEY,
    question VARCHAR(255) NOT NULL,
    right_answer VARCHAR
);

CREATE TABLE users
(
    users_uid UUID NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT
);

CREATE TABLE answers
(
    answers_uid UUID NOT NULL PRIMARY KEY,
    users_uid UUID REFERENCES users(users_uid),
    questions_uid UUID REFERENCES questions(questions_uid),
    answer VARCHAR(255) NOT NULL
);

-- Insertando datos requeridos. 5 preguntas y 5 usuarios.
INSERT INTO questions(questions_uid, question, right_answer) VALUES (
    uuid_generate_v4(), '¿Los camaleones pueden cambiar de color?', 'Si pueden'
);
INSERT INTO questions(questions_uid, question, right_answer) VALUES (
    uuid_generate_v4(), '¿La lava de los volcanes contiene azufre?', 'Entre sus partículas, si tienen'
);
INSERT INTO questions(questions_uid, question, right_answer) VALUES (
    uuid_generate_v4(), '¿Por qué el mar se ve azul?', 'La luz blanca del sol incide sobre él y el agua absorbe los tonos más cálidos. La luz reflejada, por lo tanto, es azulada'
);
INSERT INTO questions(questions_uid, question, right_answer) VALUES (
    uuid_generate_v4(), 'Escriba el nombre correcto en latin para referirse a los perros', 'Canis familiaris'
);
INSERT INTO questions(questions_uid, question, right_answer) VALUES (
    uuid_generate_v4(), '¿Qué le pasa a lupita?', 'No sé'
);

INSERT INTO users(users_uid, name, age) VALUES (
    uuid_generate_v4(), 'MageLink', 22
);
INSERT INTO users(users_uid, name, age) VALUES (
    uuid_generate_v4(), 'Fernanda', 33
);
INSERT INTO users(users_uid, name, age) VALUES (
    uuid_generate_v4(), 'Marcela', 18
);
INSERT INTO users(users_uid, name, age) VALUES (
    uuid_generate_v4(), 'Juana', 22
);
INSERT INTO users(users_uid, name, age) VALUES (
    uuid_generate_v4(), 'Camila', 35
);

-- Insertando respuestas
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), 'a47e7781-231f-46b8-b92a-7cd8051b39dc', 'c4dc36e4-6fb2-4672-b83d-22c17748d74e', 'Si pueden'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), 'fa9ce993-0b87-4791-9055-deff001bfa39', 'c4dc36e4-6fb2-4672-b83d-22c17748d74e', 'Si pueden'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '0ef39aed-6d26-4a9f-a419-8c477f7e29a3', 'd500fb9a-064b-4d98-8de1-86fa2e84bd23', 'Entre sus partículas, si tienen'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '3e40d471-89e1-4ba2-a0fb-3b3c8fbd8681', 'c2515184-db0a-48b7-8042-6e15830e2f7b', 'No lo sé'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '1bac9f02-5cf9-4816-8847-3e04fb375557', '920f8201-4371-4fed-bd55-d5aa85b93e74', 'No sé :c'
);

-- Checkin
SELECT * FROM questions;
SELECT * FROM users;
SELECT * FROM answers;

--- Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta).
SELECT users.name, questions.right_answer, COUNT(*) FROM answers
LEFT JOIN users USING (users_uid)
LEFT JOIN questions USING (questions_uid) WHERE questions.right_answer = answer
GROUP BY users.name, questions.right_answer;

--- Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios tuvieron la respuesta correcta.
SELECT questions.question, COUNT(*) AS total_rights_answer_users FROM answers
LEFT JOIN users USING (users_uid)
LEFT JOIN questions USING (questions_uid) WHERE questions.right_answer = answer
GROUP BY questions.question;

--- Implementa borrado en cascada de las respuestas al borrar un usuario y borrar 
--- el primer usuario para probar la implementación. 

--- Crea una restricción que impida insertar usuarios menores de 18 años en la base de datos.
ALTER TABLE users ADD CONSTRAINT users_age_contraint CHECK (age > 17);

-- Check
INSERT INTO users(users_uid, name, age) VALUES (
    uuid_generate_v4(), 'Mario', 14
);

--- Altera la tabla existente de usuarios agregando el campo email con la restricción de único.
ALTER TABLE users ADD COLUMN email VARCHAR(255) UNIQUE;

-- Check
SELECT * FROM users;
\d users;