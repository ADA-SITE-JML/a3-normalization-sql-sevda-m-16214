CREATE OR REPLACE PROCEDURE assignmnet3()
LANGUAGE plpgsql
AS $$
BEGIN
	CREATE TABLE unnormal(
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
    );

	--import unnormalized data in csv format with UTF-8 encription
	COPY unnormal(CRN, ISBN, Title, Authors, Edition, Publisher, Publisheraddress, Pages, PublicationYear, Coursename)
	FROM 'E:\Unnormalized1.csv'
	DELIMITER ','
	CSV HEADER;
	
	--primary key added after importing data from csv file 
	ALTER TABLE unnormal ADD COLUMN material_id SERIAL;
	ALTER TABLE unnormal ADD CONSTRAINT pk_textbooks PRIMARY KEY(material_id);

	--first normal form
	CREATE TABLE AuthorsList(
		author_id SERIAL PRIMARY KEY,
		tem VARCHAR(255), --temporary column to copy into unatomized author names from data  
		Author_Surname VARCHAR(255),
		Author_Name VARCHAR (255),
		ISBN BIGINT
	);

	
	--subquery to make values in authors column atomic
	INSERT INTO AuthorsList (tem, ISBN)
	SELECT
		TRIM(unnested_author) AS tem, isbn
	FROM(
		SELECT
			ISBN,
			unnest(string_to_array(Authors, ','))
	AS unnested_author
		FROM unnormal
	) subquery;

	--seprates names from surname
	UPDATE AuthorsList
	SET 
		Author_Name = TRIM(SPLIT_PART(tem, ' ',1)),
		Author_Surname = TRIM(SPLIT_PART(tem,' ',2));

	--manually deleted single repeatition
	DELETE FROM AuthorsList 
	WHERE author_id IN (10,11);
	
	ALTER TABLE AuthorsList DROP COLUMN tem;

	--second normal form
	CREATE TABLE Courses(
		CRN INTEGER, 
		Coursename VARCHAR(255)
	);
	
	INSERT INTO Courses(CRN, Coursename)
	SELECT DISTINCT CRN, Coursename
	FROM unnormal;

	--relational table to illustrate many-to-many relationship between entites 
	CREATE TABLE Course_Material(
		CRN INTEGER,
		ISBN BIGINT
	);
	
	INSERT INTO Course_Material(CRN, ISBN)
	SELECT DISTINCT CRN, ISBN
	FROM unnormal;
	
	--third normal form
	CREATE TABLE PublishingHouse(
		Publisher VARCHAR(255),
		Publisheraddress VARCHAR(255),
		Pages INTEGER,
		PublicationYear INTEGER,
		ISBN BIGINT
	);

	INSERT INTO PublishingHouse(Publisher, Publisheraddress, Pages,PublicationYear,ISBN)
	SELECT DISTINCT Publisher,Publisheraddress,Pages,PublicationYear,ISBN
	FROM unnormal;
	
	ALTER TABLE PublishingHouse ADD CONSTRAINT pk_pudl PRIMARY KEY(ISBN);
	
	CREATE TABLE Textbooks(
		ISBN BIGINT,
		Title VARCHAR(255)
	);
	
	INSERT INTO Textbooks(ISBN, Title)
	SELECT DISTINCT ISBN, Title
	FROM unnormal;
END;
$$;

CALL assignmnet3();
