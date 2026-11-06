# Keep Knoxville Beautiful - Deliverable 6

This final submission includes a locally hosted Python 3 web application, a
command-line application, the database design ERD, and SQL query and
transaction scripts. Both applications use SQLite as the primary persistent
data store. No external Python packages are required.

## Setup

From this directory, recreate the database:

```bash
rm -f knoxville_beautiful.db
sqlite3 knoxville_beautiful.db < schema.sql
sqlite3 knoxville_beautiful.db < insert_data.sql
```

Then start the web application:

```bash
python3 web_app.py
```

Open <http://127.0.0.1:8000> in a browser. Stop the server with Ctrl+C.
You can select a different database or port with:

```bash
python3 web_app.py --database /path/to/database.db --port 8080
```

The original CLI remains available with `python3 app.py`. Both applications
enable SQLite foreign-key enforcement for every connection.

## Quick Frontend Walkthrough

1. **Start the application.** From this folder, run `python3 web_app.py`, then
   open `http://127.0.0.1:8000` in a browser.
2. **Review the dashboard.** The top cards show total events, volunteers,
   volunteer hours, and supplies at or below their reorder level. The
   "Upcoming events" panel provides a quick schedule overview.
3. **Find an event.** Use the Search box to search by event name or location.
   Use the Status dropdown to limit results to planned, open, completed, or
   cancelled events.
4. **Open event details.** Click an event row to see its location,
   registered volunteers, and requested supplies. The detail window also lets
   you update the event status.
5. **Manage volunteers.** Click **+ Add volunteer**, complete the form, and
   submit it. From an event's detail window, select a volunteer and role, then
   click **Register** to add that volunteer to the event.
6. **Manage approved supplies.** In an event's detail window, click
   **Fulfill** beside an approved supply request. This updates the request,
   inventory, and inventory history together.
7. **View reports.** Click **Load report** under Activity Summary to view
   staffing and supply-request totals. Click **View inventory** under Supply
   Levels to review current stock and reorder levels.
8. **Refresh or stop.** Use **Refresh data** after changes if needed. Stop
   the local server with Ctrl+C in the terminal.

## Operations

The web dashboard provides these operations:

1. **Search or browse events** - filters event and location records using SQL.
2. **View event details** - joins events to locations, volunteers, and supply
   requests by clicking an event.
3. **Add a volunteer** - opens the Add volunteer form and performs an insert.
4. **Event activity summary** - loads the view with joins and aggregates.
5. **Supply levels** - loads inventory with a grouped usage report.
6. **Dashboard summary** - displays event, volunteer, hours, and low-stock
   totals.

The JSON API also supports volunteer registration, event status updates, and
approved supply fulfillment. These are available to the frontend's API and
retain the same parameterized SQL and transaction behavior as the CLI.

All values entered by the user are passed through parameterized SQL
placeholders. Invalid IDs, statuses, email addresses, duplicate records,
missing records, and insufficient inventory receive user-friendly messages.

## Files

- `app.py` - application source code
- `web_app.py` - local HTTP server and JSON API
- `index.html` - web application page
- `static/` - responsive CSS and frontend JavaScript
- `schema.sql` - database schema and `event_activity_summary` view
- `insert_data.sql` - reproducible sample data
- `queries.sql` - reporting queries
- `transaction.sql` - transaction demonstration
- `run_queries.sh` - database recreation and validation script
- `erd.png` - final database entity-relationship diagram
- `README.md` - setup and operation instructions
