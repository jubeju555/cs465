KEEP KNOXVILLE BEAUTIFUL - DELIVERABLE 3
========================================

DBMS USED
---------
SQLite 3. The implementation uses standard SQLite SQL and does not require a
hosted account, server, or third-party extension.

FILES AND RECREATION
--------------------
Run the files in this order from the Project directory:

    sqlite3 knoxville_beautiful.db < schema.sql
    sqlite3 knoxville_beautiful.db < insert_data.sql

Both files enable PRAGMA foreign_keys = ON. The schema also drops the view and
tables in dependency-safe order, so the first command can be rerun to recreate
a clean database. No passwords, environment variables, or manual edits are
required.

To verify the result:

    sqlite3 knoxville_beautiful.db "PRAGMA foreign_keys = ON; PRAGMA foreign_keys;"
    sqlite3 knoxville_beautiful.db "PRAGMA foreign_keys = ON; SELECT COUNT(*) FROM event_activity_summary;"
    sqlite3 knoxville_beautiful.db "PRAGMA foreign_keys = ON; SELECT name FROM sqlite_master WHERE type='index';"

The first query should return 1. SQLite foreign-key enforcement is
connection-specific, so any later interactive connection must also execute
`PRAGMA foreign_keys = ON` before making changes. The sample data contains
90+ rows across the seven tables and includes completed, open, and planned
events, an event with multiple volunteers and supplies, and inventory
transactions that are both event-related and general warehouse activity.

VIEW
----
event_activity_summary combines event, location, event_participation, and
supply_request. It returns one row per event with its location, volunteer
count, total volunteer hours, number of supply requests, and total requested
units. LEFT JOINs keep events visible even when they have no participation or
requests yet, which makes the view useful for staffing and event-readiness
reports.

INDEX
-----
idx_event_date_status is an explicitly created composite index on event_date
and status. It supports the common operation of finding events in calendar
order while filtering by status. It is separate from indexes automatically
created for primary keys and unique constraints.

CONSTRAINTS AND FOREIGN KEYS
----------------------------
The schema uses NOT NULL and UNIQUE constraints for required entity data,
CHECK constraints for dates, statuses, nonnegative inventory/hours, positive
requests, and valid postal codes, plus defaults for common statuses and
timestamps. Foreign-key enforcement is enabled with PRAGMA foreign_keys = ON.
The junction table has a composite primary key so a volunteer cannot register
twice for the same event. Cascades remove dependent participation and requests
when an event is removed; inventory history remains protected from deleting a
supply.

DESIGN CHANGES
--------------
No significant conceptual changes were made from Deliverable 2. The seven
entities and relationships match the submitted ER diagram and design notes.
The physical implementation adds SQLite-specific cleanup statements, useful
defaults, and CHECK constraints to enforce the status and quantity rules that
were identified as application-level rules in the logical design.
