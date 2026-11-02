# Keep Knoxville Beautiful - Deliverable 5

This submission is a menu-driven Python 3 application using SQLite as its
primary persistent data store. No external Python packages are required.

## Setup

From this directory, recreate the database:

```bash
rm -f knoxville_beautiful.db
sqlite3 knoxville_beautiful.db < schema.sql
sqlite3 knoxville_beautiful.db < insert_data.sql
```

Then start the application:

```bash
python3 app.py
```

An alternate database can be selected with
`python3 app.py --database /path/to/database.db`. The application enables
SQLite foreign-key enforcement for every connection.

## Operations

The interactive menu provides these operations:

1. **Search or browse events** - filters event and location records using SQL.
2. **View event details** - joins events to locations, volunteers, and supply
   requests.
3. **Add a volunteer** - validates the required fields and inserts a record.
4. **Register a volunteer** - inserts a relationship record between an event
   and volunteer.
5. **Update event status** - changes an existing event using `UPDATE`.
6. **Event activity summary** - reads the supplied view, which uses joins,
   aggregates, and grouping.
7. **Low-inventory report** - uses a join, `SUM`, `GROUP BY`, and `HAVING`.
8. **Fulfill an approved supply request** - uses one transaction to update the
   request, decrement inventory, and insert an inventory transaction together.

All values entered by the user are passed through parameterized SQL
placeholders. Invalid IDs, statuses, email addresses, duplicate records,
missing records, and insufficient inventory receive user-friendly messages.

## Files

- `app.py` - application source code
- `schema.sql` - database schema and `event_activity_summary` view
- `insert_data.sql` - reproducible sample data
- `README.md` - setup and operation instructions
