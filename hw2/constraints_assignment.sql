.mode box

PRAGMA foreign_keys = ON;

drop table IF EXISTS registrations;
drop table IF EXISTS events;
drop table IF EXISTS attendees;

CREATE TABLE attendees (
    attendee_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active'
);

create table events (
    event_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    fee REAL NOT NULL CHECK (fee >= 0),
    status TEXT NOT NULL DEFAULT 'open'
);

create table registrations (
    attendee_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,
    Primary Key (attendee_id, event_id),
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id)

);

insert into attendees (name, email) values ('Alice Smith', 'alice@example.com');
insert into attendees (name, email, status) values ('Bob Jones', 'bob@example.com', 'inactive');
insert into attendees (name, email, status) values ('Carol Brown', 'carol@example.com', 'active');

insert into events (title, capacity, fee) values ('Database Day', 10, 0);
insert into events (title, capacity, fee, status) values ('Python Night', 50, 10.00, 'open');
insert into events (title, capacity, fee, status) values ('SQL Workshop', 25, 15.00, 'closed');

insert into registrations (attendee_id, event_id) values (1, 1);
insert into registrations (attendee_id, event_id) values (1, 3);
insert into registrations (attendee_id, event_id) values (2, 1);
insert into registrations (attendee_id, event_id) values (3, 2);

SELECT * FROM attendees;
SELECT * FROM events;
SELECT * FROM registrations;