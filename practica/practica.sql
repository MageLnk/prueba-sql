-- Creando DB
CREATE DATABASE practica;
-- Conectando
\c practica;

-- Probando el cascade 
CREATE TABLE posts (
"id" Integer,
"title" Varchar(255),
"content" text,
PRIMARY KEY ("id")
);

CREATE TABLE comments (
"id" Integer,
"content" Varchar(255),
"post_id" Integer,
PRIMARY KEY ("id"),
FOREIGN KEY ("post_id")
REFERENCES posts ("id")
ON DELETE CASCADE /* Con esto los datos se borrarán en cascada automáticamente */
);

INSERT INTO posts VALUES (1, 'Post1', 'Lorem Ipsum');
INSERT INTO comments VALUES (1, 'Comentario 1', 1),
(2, 'Comentario 2' ,1),
(3, 'Comentario 3', 1);

DELETE FROM posts WHERE id = 1;