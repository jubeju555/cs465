KEEP KNOXVILLE BEAUTIFUL
DELIVERABLE 3 - BACKEND IMPLEMENTATION AND DATA

SUBMISSION CONTENTS
-------------------
schema.sql
    Authoritative database structure. Creates all seven tables, keys,
    constraints, foreign-key relationships, the required index, and the
    event_activity_summary view.

insert_data.sql
    Realistic sample records. Run this after schema.sql.

README.txt
    This file. Contains DBMS, recreation, testing, view, index, and design
    information.

The Deliverable 2 ER diagram is not included because no significant
conceptual design changes were made during implementation. The existing
Deliverable 2 diagram still matches the submitted database.

DBMS USED
---------
SQLite 3. The database can be recreated locally without a hosted account,
server, password, or third-party extension.

RECREATION STEPS
----------------
Open a terminal in this submission folder and run:

    sqlite3 knoxville_beautiful.db < schema.sql
    sqlite3 knoxville_beautiful.db < insert_data.sql

Run the files in the order shown. The schema includes cleanup statements and
can be rerun to recreate the database cleanly. Foreign-key enforcement is
enabled by both SQL files. SQLite enables this setting per connection, so use
the following before testing changes in a new interactive connection:

    PRAGMA foreign_keys = ON;

TESTING COMMANDS
----------------
Verify foreign-key enforcement:

    sqlite3 knoxville_beautiful.db "PRAGMA foreign_keys = ON; PRAGMA foreign_keys;"

The result should be 1.

Verify the view and row counts:

    sqlite3 knoxville_beautiful.db "SELECT * FROM event_activity_summary;"
    sqlite3 knoxville_beautiful.db "SELECT COUNT(*) FROM event;"
    sqlite3 knoxville_beautiful.db "SELECT COUNT(*) FROM event_participation;"
    sqlite3 knoxville_beautiful.db "SELECT COUNT(*) FROM supply_request;"
    sqlite3 knoxville_beautiful.db "SELECT COUNT(*) FROM inventory_transaction;"

The sample data contains 90 total rows across the seven major tables.

VIEW
----
event_activity_summary combines event, location, event_participation, and
supply_request. It returns one row per event with the location, event status,
volunteer count, total volunteer hours, supply-request count, and requested
units. Its LEFT JOIN-based summaries preserve events even if they do not yet
have volunteers or supply requests.

INDEX
-----
idx_event_date_status is a manually created composite index on event_date and
status. It supports event-calendar searches that filter by status and date.
It is not an automatic primary-key or unique-constraint index.

CONSTRAINTS AND RELATIONSHIPS
-----------------------------
The implementation uses required-field NOT NULL constraints, UNIQUE
constraints for names and volunteer email addresses, CHECK constraints for
valid statuses, dates, quantities, hours, and postal codes, and defaults for
statuses and timestamps. Foreign keys connect events to locations, event
participation to events and volunteers, supply requests to events and
supplies, and inventory transactions to supplies and optionally events.

DESIGN CHANGES
--------------
No significant conceptual changes were made from Deliverable 2. The seven
entities and relationships match the ER diagram. The implementation adds
physical SQLite details: cleanup statements, defaults, and CHECK constraints
to enforce rules that were previously described as application-level rules.


