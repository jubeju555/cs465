.mode box

pragma foreign_keys = ON;

-- Expected to fail because of the UNIQUE constraint.
INSERT INTO attendees (name, email)
VALUES ('Duplicate Alice', 'alice@example.com');

-- Expected to fail because of the NOT NULL constraint.
INSERT INTO attendees (email)
VALUES ('noname@example.com');

-- Expected to fail because of the CHECK constraint.
INSERT INTO events (title, capacity, fee)
VALUES ('Zero Capacity Event', 0, 10.00);

-- Expected to fail because of the CHECK constraint.
INSERT INTO events (title, capacity, fee)
VALUES ('Negative Fee Event', 10, -5.00);

-- Expected to fail because of the FOREIGN KEY constraint.
INSERT INTO registrations (attendee_id, event_id)
VALUES (999, 1);

-- Expected to fail because of the FOREIGN KEY constraint.
INSERT INTO registrations (attendee_id, event_id)
VALUES (1, 999);

-- Expected to fail because of the composite PRIMARY KEY constraint.
INSERT INTO registrations (attendee_id, event_id)
VALUES (1, 1);

-- Expected to succeed because of the DEFAULT constraint.
INSERT INTO attendees (name, email)
VALUES ('David Green', 'david@example.com');

SELECT *
FROM attendees
WHERE email = 'david@example.com';