.mode box

PRAGMA foreign_keys = ON;

dROP TABLE IF EXISTS attendees;
drop table IF EXISTS events;
drop table IF EXISTS registrations;

CREATE TABLE attendees (
    attendee_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
    status TEXT NOT NULL DEFAULT 'active'
);

create table events (
    event_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    fee REAL NOT NULL CHECK (fee >= 0)
    status TEXT NOT NULL DEFAULT 'open'
);

create table registrations (
    attendee_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,
    Primary Key (attendee_id, event_id),
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id)

);