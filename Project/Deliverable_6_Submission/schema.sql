-- Keep Knoxville Beautiful database schema
-- DBMS: SQLite 3

PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS event_activity_summary;
DROP TABLE IF EXISTS inventory_transaction;
DROP TABLE IF EXISTS supply_request;
DROP TABLE IF EXISTS event_participation;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS supply;
DROP TABLE IF EXISTS volunteer;
DROP TABLE IF EXISTS location;

CREATE TABLE location (
    location_id INTEGER PRIMARY KEY,
    location_name TEXT NOT NULL UNIQUE,
    street_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Knoxville',
    state TEXT NOT NULL DEFAULT 'TN' CHECK (length(state) = 2),
    postal_code TEXT NOT NULL CHECK (postal_code GLOB '[0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE volunteer (
    volunteer_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE COLLATE NOCASE,
    phone TEXT
);

CREATE TABLE supply (
    supply_id INTEGER PRIMARY KEY,
    supply_name TEXT NOT NULL UNIQUE,
    unit TEXT NOT NULL,
    quantity_on_hand INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    reorder_level INTEGER NOT NULL DEFAULT 0 CHECK (reorder_level >= 0)
);

CREATE TABLE event (
    event_id INTEGER PRIMARY KEY,
    location_id INTEGER NOT NULL,
    event_name TEXT NOT NULL,
    event_date TEXT NOT NULL CHECK (date(event_date) IS NOT NULL),
    status TEXT NOT NULL DEFAULT 'planned'
        CHECK (status IN ('planned', 'open', 'completed', 'cancelled')),
    description TEXT,
    FOREIGN KEY (location_id) REFERENCES location(location_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE event_participation (
    event_id INTEGER NOT NULL,
    volunteer_id INTEGER NOT NULL,
    role TEXT NOT NULL DEFAULT 'volunteer',
    hours_worked REAL NOT NULL DEFAULT 0 CHECK (hours_worked >= 0),
    registered_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, volunteer_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (volunteer_id) REFERENCES volunteer(volunteer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE supply_request (
    request_id INTEGER PRIMARY KEY,
    event_id INTEGER NOT NULL,
    supply_id INTEGER NOT NULL,
    quantity_requested INTEGER NOT NULL CHECK (quantity_requested > 0),
    request_status TEXT NOT NULL DEFAULT 'requested'
        CHECK (request_status IN ('requested', 'approved', 'fulfilled', 'cancelled')),
    requested_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (event_id, supply_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (supply_id) REFERENCES supply(supply_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE inventory_transaction (
    transaction_id INTEGER PRIMARY KEY,
    supply_id INTEGER NOT NULL,
    event_id INTEGER,
    transaction_type TEXT NOT NULL
        CHECK (transaction_type IN ('restock', 'usage', 'adjustment')),
    quantity_change INTEGER NOT NULL CHECK (quantity_change <> 0),
    transaction_date TEXT NOT NULL CHECK (date(transaction_date) IS NOT NULL),
    notes TEXT,
    FOREIGN KEY (supply_id) REFERENCES supply(supply_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (event_id) REFERENCES event(event_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- Supports the common event calendar/status lookup.
CREATE INDEX idx_event_date_status ON event (event_date, status);

-- Summarizes event staffing and requested supplies, including events with no
-- participation or requests.
CREATE VIEW event_activity_summary AS
SELECT
    e.event_id,
    e.event_name,
    e.event_date,
    e.status,
    l.location_name,
    COALESCE(ep.volunteer_count, 0) AS volunteer_count,
    COALESCE(ep.total_hours, 0) AS total_hours,
    COALESCE(sr.supply_request_count, 0) AS supply_request_count,
    COALESCE(sr.total_units_requested, 0) AS total_units_requested
FROM event AS e
JOIN location AS l ON l.location_id = e.location_id
LEFT JOIN (
    SELECT event_id, COUNT(*) AS volunteer_count, SUM(hours_worked) AS total_hours
    FROM event_participation
    GROUP BY event_id
) AS ep ON ep.event_id = e.event_id
LEFT JOIN (
    SELECT event_id, COUNT(*) AS supply_request_count,
           SUM(quantity_requested) AS total_units_requested
    FROM supply_request
    GROUP BY event_id
) AS sr ON sr.event_id = e.event_id;
