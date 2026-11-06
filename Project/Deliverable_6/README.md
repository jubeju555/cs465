# Keep Knoxville Beautiful — Deliverable 6

This folder is the final project submission. It contains:

- A local Python web dashboard
- A command-line SQLite application
- The database schema and sample data
- Reporting and transaction SQL
- The final entity-relationship diagram

The project uses Python 3 and SQLite. It has no third-party Python
dependencies.

## 1. Prerequisites

Install or verify:

```bash
python3 --version
sqlite3 --version
```

Run all commands from this folder:

```bash
cd /path/to/cs465/Project/Deliverable_6
```

## 2. Recreate the Database

The checked-in `knoxville_beautiful.db` is ready to use. To rebuild it from
the schema and sample data:

```bash
rm -f knoxville_beautiful.db
sqlite3 knoxville_beautiful.db < schema.sql
sqlite3 knoxville_beautiful.db < insert_data.sql
```

The database contains seven related tables and the
`event_activity_summary` view. Both applications enable SQLite foreign-key
enforcement for every connection.

## 3. Run the Web Dashboard

Start the server:

```bash
python3 web_app.py
```

Open <http://127.0.0.1:8000> in a browser. Stop the server with `Ctrl+C`.

To select another database or port:

```bash
python3 web_app.py --database /path/to/database.db --port 8080
```

### Dashboard workflow

1. Review the dashboard totals and upcoming events.
2. Search events by name or location, and filter by status.
3. Select an event to view its location, volunteers, and supply requests.
4. Update an event status or register a volunteer.
5. Add volunteers with **+ Add volunteer**.
6. Fulfill approved supply requests from an event's details.
7. Load the activity report and inventory report.
8. Use **Refresh data** after changes when needed.

The web application serves the page from `index.html`, styles from
`static/styles.css`, and browser behavior from `static/app.js`.

## 4. Run the Command-Line Application

Start the interactive CLI:

```bash
python3 app.py
```

The CLI uses the database in this folder by default. It supports the same
core data-management operations and validation rules as the web application.

## 5. Validate the Submission

Run the complete database recreation and SQL demonstration:

```bash
bash run_queries.sh
```

This script:

1. Recreates `knoxville_beautiful.db`.
2. Runs the required reporting queries in `queries.sql`.
3. Runs the transaction demonstration in `transaction.sql`.

Note: `run_queries.sh` intentionally deletes and recreates the local database.

## 6. Web API Overview

The dashboard uses these JSON endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/dashboard` | Dashboard totals and upcoming events |
| GET | `/api/events` | Search and filter events |
| GET | `/api/events/:id` | Event details and related records |
| GET | `/api/volunteers` | List volunteers |
| GET | `/api/activity` | Event activity report |
| GET | `/api/inventory` | Inventory report |
| POST | `/api/volunteers` | Add a volunteer |
| POST | `/api/participation` | Register a volunteer for an event |
| PATCH | `/api/events/:id/status` | Update an event status |
| POST | `/api/requests/:id/fulfill` | Fulfill an approved supply request |

User-provided values are passed through parameterized SQL statements.
Invalid IDs, statuses, email addresses, duplicate records, missing records,
and insufficient inventory return errors rather than silently succeeding.

## 7. File Guide

| File | Purpose |
|---|---|
| `README.md` | Setup, operation, validation, and handoff instructions |
| `app.py` | Interactive command-line application |
| `web_app.py` | Local HTTP server and JSON API |
| `index.html` | Dashboard page |
| `static/app.js` | Dashboard behavior and API requests |
| `static/styles.css` | Dashboard styling |
| `schema.sql` | Tables, constraints, indexes, and summary view |
| `insert_data.sql` | Reproducible sample records |
| `knoxville_beautiful.db` | Ready-to-use SQLite database |
| `queries.sql` | Reporting and verification queries |
| `transaction.sql` | Commit and rollback demonstration |
| `run_queries.sh` | Database recreation and validation runner |
| `erd.png` | Final entity-relationship diagram |

## 8. Handoff Checklist

Before submitting or handing off the project:

- Run `bash run_queries.sh`.
- Confirm the web dashboard opens at `http://127.0.0.1:8000`.
- Confirm `python3 app.py` starts the CLI.
- Keep `schema.sql` and `insert_data.sql` together.
- Do not edit the database manually when a reproducible SQL change is
  appropriate.
- Remember that `run_queries.sh` recreates the database and removes local
  data changes.
