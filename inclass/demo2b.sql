PRAGMA foreign_keys = ON;


CREATE TABLE Customers (
	customer_id INTEGER PRIMARY KEY,
	name TEXT NOT NULL,
	email TEXT NOT NULL UNIQUE,
	status TEXT NOT NULL DEFAULT 'active'
);

CREATE TABLE Orders (
	order_id INTEGER PRIMARY KEY,
	customer_id INTEGER NOT NULL,
	amount REAL NOT NULL CHECK (amount > 0),
	status TEXT NOT NULL DEFAULT 'pending',
	FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 1. Valid customer
INSERT INTO Customers (name, email)
VALUES ('Ada Lovelace', 'ada@gmail.com');

-- 2. Fails: UNIQUE constraint on Customers.email
-- INSERT INTO Customers (name, email)
-- VALUES ('Grace Hopper', 'ada@gmail.com');

-- 3. Valid order
INSERT INTO Orders (customer_id, amount)
VALUES (1, 125.50);

-- 4. Fails: FOREIGN KEY constraint on Orders.customer_id
-- INSERT INTO Orders (customer_id, amount)
-- VALUES (999, 25.00);

-- 5. Fails: CHECK constraint amount > 0
-- INSERT INTO Orders (customer_id, amount)
-- VALUES (1, -10.00);

-- 6. Valid order; status defaults to 'pending'
INSERT INTO Orders (customer_id, amount)
VALUES (1, 40.00);

SELECT * FROM Customers;
SELECT * FROM Orders;
