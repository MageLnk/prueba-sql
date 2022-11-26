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
    users_uid UUID NOT NULL,
    questions_uid UUID NOT NULL,
    answer VARCHAR(255) NOT NULL,
    CONSTRAINT FK_users_uid FOREIGN KEY (users_uid) REFERENCES users(users_uid),
    CONSTRAINT FK_questions_uid FOREIGN KEY (questions_uid) REFERENCES questions(questions_uid)
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

-- Checkin para obtener el UUID de las preguntas y los usuarios
SELECT * FROM users;
SELECT * FROM questions;

-- Insertando respuestas
-- 1. Primera pregunta debe estar contestada dos veces por distintos usuarios.
-- 2. Segunda pregunta debe estar contestada solo por un usuario.
-- 3. Las otras dos incorrectas
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '4cd69cff-3851-48dc-b3f9-5e5832d9f389', '31cd6e0b-6268-4446-9403-ee638873323a', 'Si pueden'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), 'dc615714-32d9-481a-98ab-4e60d8f9887c', '31cd6e0b-6268-4446-9403-ee638873323a', 'Si pueden'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '78166d3e-bba4-4d3d-9fe8-f43798ad97da', 'f09e51b7-1944-467d-b891-3a2642942ebb', 'Entre sus partículas, si tienen'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '17d2fc9d-b73f-4b29-a2d3-50c216c741bd', '608b45ff-471b-405d-8298-a5b066117e3f', 'No lo sé'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), 'd08f6034-b60d-46e1-aa67-b9936ffba4ea', 'c8a0439d-3a6d-4a31-9f2b-1dde95803e2a', 'No sé :c'
);

-- Checkin
SELECT * FROM questions;
SELECT * FROM users;
SELECT * FROM answers;

--- Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta).
SELECT users.name, COUNT(*) 
FILTER (WHERE questions.right_answer = answer) AS total_right_answers FROM answers
LEFT JOIN users USING (users_uid)
LEFT JOIN questions USING (questions_uid) 
GROUP BY users.name;

--- Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios tuvieron la respuesta correcta.
SELECT question, COUNT(users.users_uid) 
FILTER(WHERE questions.right_answer = answers.answer) AS Total_users_with_right_answers FROM questions
LEFT JOIN answers ON answers.questions_uid = questions.questions_uid
LEFT JOIN users ON users.users_uid = answers.users_uid
GROUP BY question;

--- Implementa borrado en cascada de las respuestas al borrar un usuario y borrar 
--- el primer usuario para probar la implementación. 
-- CHECK
SELECT * FROM users;

SELECT users.name FROM answers 
LEFT JOIN users USING (users_uid);

DELETE FROM users WHERE users_uid = '4cd69cff-3851-48dc-b3f9-5e5832d9f389';

-- Procedemos

ALTER TABLE answers DROP CONSTRAINT FK_users_uid;
-- Ahora
ALTER TABLE answers 
ADD CONSTRAINT FK_users_uid 
FOREIGN KEY (users_uid) 
REFERENCES users(users_uid)
ON DELETE CASCADE;

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