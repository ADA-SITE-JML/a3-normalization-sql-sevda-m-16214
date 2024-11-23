CREATE TABLE courses(
	CRN INTEGER,
	ISBN BIGINT,
	Title VARCHAR(255),
	Authors VARCHAR(255), 
	Edition INTEGER,
	Publisher VARCHAR(255),
	Publisheraddress VARCHAR(255),
	Pages INTEGER,
	PublicationYear INTEGER,
	Coursename VARCHAR(255)
)

CREATE TABLE AuthorsList(
	author_id SERIAL PRIMARY KEY,
	tem VARCHAR(255),
	ISBN BIGINT
)

INSERT INTO AuthorsList (tem, ISBN)
SELECT
	TRIM(unnested_author) AS tem, isbn
FROM(
	SELECT
		ISBN,
		unnest(string_to_array(Authors, ','))
AS unnested_author
	FROM courses
) subquery

ALTER TABLE AuthorsList 
	ADD COLUMN Author_Surname VARCHAR(255),
	ADD COLUMN Author_Name VARCHAR (255)

UPDATE AuthorsList
SET 
	Author_Name = TRIM(SPLIT_PART(tem, ' ',1)),
	Author_Surname = TRIM(SPLIT_PART(tem,' ',2))

DELETE FROM AuthorsList 
WHERE author_id IN (10,11)

ALTER TABLE AuthorsList DROP COLUMN tem


ALTER TABLE courses RENAME TO Textbooks
ALTER TABLE Textbooks ADD COLUMN material_id SERIAL
ALTER TABLE Textbooks ADD CONSTRAINT pk_textbooks PRIMARY KEY(material_id)

CREATE TABLE Courses(
	CRN INTEGER PRIMARY KEY,
	Coursename VARCHAR(255)
)

INSERT INTO Courses(CRN, Coursename)
SELECT DISTINCT CRN, Coursename
FROM Textbooks


CREATE TABLE Course_textbooks(
	CRN INTEGER,
	ISBN BIGINT
)

INSERT INTO Course_textbooks(CRN, ISBN)
SELECT DISTINCT CRN, ISBN
FROM Textbooks




