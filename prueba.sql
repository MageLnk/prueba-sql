-- Create DB
CREATE DATABASE desafio_latam;

-- Conectando
\c desafio_latam;

--- Creando tablas

--- Crea el modelo (revisa bien cuál es el tipo de relación antes de crearlo), respeta las
--- claves primarias, foráneas y tipos de datos.

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

---Inserta 5 películas y 5 tags, la primera película tiene que tener 3 tags asociados, la
---segunda película debe tener dos tags asociados
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

INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (1, 1);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (1, 2);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (1, 3);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (2, 1);
INSERT INTO peliculas_tags(peliculas_id, tags_id) VALUES (2, 4);

-- Checkin Info again
SELECT * FROM peliculas;
SELECT * FROM tags;
SELECT * FROM peliculas_tags;

--- Cuenta la cantidad de tags que tiene cada película. Si una película no tiene tags debe
--- mostrar 0.
SELECT peliculas.nombre, COUNT(tags) AS tags FROM peliculas 
LEFT JOIN peliculas_tags USING (peliculas_id)
LEFT JOIN tags USING (tags_id)
GROUP BY peliculas.nombre;

--- Crear un nuevo modelo
-- Para hacerlo más "realista", lo haremos con UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--- Crea las tablas respetando los nombres, tipos, claves primarias y foráneas y tipos de datos.
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

-- Agrega datos, 5 usuarios y 5 preguntas, la primera pregunta debe estar contestada
-- dos veces correctamente por distintos usuarios, la pregunta 2 debe estar contestada
-- correctamente sólo por un usuario, y las otras 2 respuestas deben estar incorrectas.

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

--- Insertando respuestas
-- 1. Primera pregunta debe estar contestada dos veces por distintos usuarios.
-- 2. Segunda pregunta debe estar contestada solo por un usuario.
-- 3. Las otras dos incorrectas
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '7137661c-72e5-4327-b85d-8fdafabbd439', 'aad65716-621d-4ab1-9f83-ccecf8ec0014', 'Si pueden'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '307eb749-9d74-4abc-91b1-9d53cdc40581', 'aad65716-621d-4ab1-9f83-ccecf8ec0014', 'Si pueden'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '4a82a12a-fb78-419c-b2ac-3bcbb8ddc29e', '82a4c665-1c72-4ffb-9080-382c1237c046', 'Entre sus partículas, si tienen'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '9ebb1315-dd4f-441c-9b6a-f7de40014f2d', '2ce9f11d-66d4-4f62-8134-ad791c38345c', 'No lo sé'
);
INSERT INTO answers(answers_uid, users_uid, questions_uid, answer) VALUES (
    uuid_generate_v4(), '3b45bd68-b32a-4e7d-8745-f8c6cec7ba73', '9c69b2bd-93a7-4c9f-809b-35b4f22acba9', 'No sé :c'
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

-- No podremos, pero hay que hacer la comparativa para el test
DELETE FROM users WHERE users_uid = '7137661c-72e5-4327-b85d-8fdafabbd439';

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