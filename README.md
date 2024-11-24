[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/w1BdldVH)
# Introduction

### Assignment three required students to implement a code solution to normalization problem given in Assignment two. I made an effort to transfer into code as many aspects of my theoretical solution. Nevertheless, some adjustments were necessary to address technical constraints and ensure proper coding functionality. 

## Preparing the data

## First of all, I created a table using the query tool in PgAdmin.  Certain columns had to be renamed to suit naming restrictions.  

```
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

```

### I also updated column names in unnormalized Excel table before converting it to comma-separated values (csv) file. Once that was done, I used the COPY command to insert all values into the database.  

```
--import unnormalized data in csv format with UTF-8 encription 

    COPY unnormal(CRN, ISBN, Title, Authors, Edition, Publisher, Publisheraddress, Pages, PublicationYear, Coursename) 

    FROM 'E:\Unnormalized1.csv' 

    DELIMITER ',' 

    CSV HEADER; 
```
 

### I added an extra column to function as a primary key, because the original dataset had no suitable candidates.   

```
ALTER TABLE unnormal ADD COLUMN material_id SERIAL; 

    ALTER TABLE unnormal ADD CONSTRAINT pk_textbooks PRIMARY KEY(material_id); 

 
```
 

### With these adjustments complete, the data was ready for the normalization process. 

# FIRST NORMAL FORM

### In my previous assignment, the “Authors” column was separated into a new entity which was  made atomic.  

```
CREATE TABLE AuthorsList( 

        author_id SERIAL PRIMARY KEY, 

        tem VARCHAR(255), --temporary column to copy into unatomized author names from data   

        Author_Surname VARCHAR(255), 

        Author_Name VARCHAR (255), 

        ISBN BIGINT 

    ); 
```
 
### To achieve this in code, I created a subquery that transformed the string into an array of characters, separated by comma. The subquery then trimmed the array and inserted the values into the temporary column that I added specifically for this.  

```
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
```
 
### Next, I further trimmed the values into separate columns for the first and last names 

```
UPDATE AuthorsList 

    SET  

        Author_Name = TRIM(SPLIT_PART(tem, ' ',1)), 

        Author_Surname = TRIM(SPLIT_PART(tem,' ',2)); 
```
 
### Due to a duplicate entry caused by “Fundamentals of Database Systems 7th Edition” being used by two different courses, I decided to manually remove it from the AuthorsList table.  

```
DELETE FROM AuthorsList  

    WHERE author_id IN (10,11); 
```
 
### Lastly, I dropped the temporary column as it was no longer needed.
# SECOND NORMAL FORM

### In the second normal form,  I created a new entity called “Courses.”  

```
CREATE TABLE Courses( 

        CRN INTEGER,  

        Coursename VARCHAR(255) 

    ); 

     

    INSERT INTO Courses(CRN, Coursename) 

    SELECT DISTINCT CRN, Coursename 

    FROM unnormal; 

```

### Since the “Courses” entity has many-to-many relationship with “Textbooks” entity, I created a relational table called “Course Material,” where the course CRNs are matched with the corresponding textbook ISBNs. 
```
CREATE TABLE Course_Material( 

        CRN INTEGER, 

        ISBN BIGINT 

    ); 

     

    INSERT INTO Course_Material(CRN, ISBN) 

    SELECT DISTINCT CRN, ISBN 
```
# THIRD NORMAL FORM 

### In the third normal form, I created a “Publishing House” table and populated it with values.  
```
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
```

### Finaly, I created the “Textbooks” table and copied the remaining columns from unnormalized table  
```
CREATE TABLE Textbooks( 

        ISBN BIGINT, 

        Title VARCHAR(255) 

    ); 

     

    INSERT INTO Textbooks(ISBN, Title) 

    SELECT DISTINCT ISBN, Title 

    FROM unnormal; 
```
 
## Conclusion

### All of the above code was later encapsulated into a procedure called “assignment 3.” 
```
CREATE OR REPLACE PROCEDURE assignmnet3() 

LANGUAGE plpgsql 

AS $$ 

BEGIN 

.... 

END; 

$$; 

 

CALL assignmnet3(); 
```
