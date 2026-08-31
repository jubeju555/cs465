-- Part 1: Creating the Database Table

DROP TABLE IF EXISTS Books;

-- Problem 1: Create the Books table
CREATE TABLE Books (
    BookID INTEGER PRIMARY KEY,
    Title TEXT NOT NULL,
    Author TEXT NOT NULL,
    Genre TEXT NOT NULL,
    PublishedYear INTEGER NOT NULL,
    Price REAL NOT NULL,
    ISBN TEXT
);

-- Problem 2: Insert the required book records
INSERT INTO Books (BookID, Title, Author, Genre, PublishedYear, Price, ISBN)
VALUES
    (1, 'To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 10.99, NULL),
    (2, '1984', 'George Orwell', 'Dystopian', 1949, 8.99, '9780451524935'),
    (3, 'The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 1925, 12.50, '9780743273565'),
    (4, 'The Catcher in the Rye', 'J.D. Salinger', 'Classic', 1951, 7.99, NULL),
    (5, 'Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 9.99, '9780141439518');

-- Part 2: Writing SQL Queries

-- Problem 1: Retrieve All Records
SELECT * FROM Books;

-- Problem 2: List Distinct Genres
SELECT DISTINCT Genre FROM Books;

-- Problem 3: Filter by Price
SELECT * FROM Books
WHERE Price < 10.00;

-- Problem 4: Order by Year
SELECT * FROM Books
ORDER BY PublishedYear ASC;

-- Problem 5: Filter with Multiple Conditions
SELECT * FROM Books
WHERE (Genre = 'Classic' OR Price BETWEEN 8.00 AND 12.00)
  AND PublishedYear >= 1950;

-- Problem 6: Find NULL ISBNs
SELECT * FROM Books
WHERE ISBN IS NULL;

-- Problem 7: Use of IN Clause
SELECT * FROM Books
WHERE Author IN ('Harper Lee', 'George Orwell');

-- Problem 8: Apply an Alias
SELECT Title, Price AS Cost FROM Books;

-- Problem 9: Add a new book
INSERT INTO Books (BookID, Title, Author, Genre, PublishedYear, Price, ISBN)
VALUES (6, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy', 1937, 14.99, '9780547928227');
