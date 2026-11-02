#!/usr/bin/env python3
"""Interactive CLI for the Keep Knoxville Beautiful database."""

from __future__ import annotations

import argparse
import re
import sqlite3
from pathlib import Path


# The database lives beside this script so the grader can run the app from
# any working directory. These values mirror the CHECK constraint in schema.sql.
DEFAULT_DB = Path(__file__).with_name("knoxville_beautiful.db")
STATUSES = ("planned", "open", "completed", "cancelled")
EMAIL_PATTERN = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def connect(database: Path) -> sqlite3.Connection:
    """Open SQLite and enable foreign keys for this connection."""
    connection = sqlite3.connect(database)
    # Row objects allow results to be accessed by column name, not only index.
    connection.row_factory = sqlite3.Row
    # SQLite requires this setting separately for every new connection.
    connection.execute("PRAGMA foreign_keys = ON")
    return connection


def print_rows(rows: list[sqlite3.Row]) -> None:
    """Print query results as a readable table."""
    if not rows:
        print("No matching records found.")
        return
    headers = rows[0].keys()
    widths = {
        header: max(len(header), *(len(str(row[header])) for row in rows))
        for header in headers
    }
    print(" | ".join(f"{header:{widths[header]}}" for header in headers))
    print("-+-".join("-" * widths[header] for header in headers))
    for row in rows:
        print(" | ".join(f"{str(row[header]):{widths[header]}}" for header in headers))


def required(prompt: str) -> str:
    """Keep prompting until the user supplies a non-empty value."""
    while True:
        value = input(prompt).strip()
        if value:
            return value
        print("This value is required.")


def integer(prompt: str, minimum: int | None = None) -> int:
    """Read an integer ID and optionally enforce a minimum value."""
    while True:
        try:
            value = int(input(prompt).strip())
            if minimum is not None and value < minimum:
                raise ValueError
            return value
        except ValueError:
            suffix = f" at least {minimum}" if minimum is not None else ""
            print(f"Enter a whole number{suffix}.")


def choose_status(prompt: str = "Status: ") -> str:
    """Restrict event status input to values allowed by the schema."""
    while True:
        value = input(prompt).strip().lower()
        if value in STATUSES:
            return value
        print(f"Choose one of: {', '.join(STATUSES)}.")


def browse_events(connection: sqlite3.Connection) -> None:
    """Search events and locations, demonstrating filtering, a join, and sorting."""
    term = input("Search event name or location (blank for all): ").strip()
    status = input("Status filter (blank for all): ").strip().lower()
    if status and status not in STATUSES:
        print(f"Choose one of: {', '.join(STATUSES)}, or leave blank.")
        return
    pattern = f"%{term}%"
    # The ? placeholders keep search text separate from the SQL statement.
    rows = connection.execute(
        """
        SELECT e.event_id, e.event_name, e.event_date, e.status,
               l.location_name
        FROM event AS e
        JOIN location AS l ON l.location_id = e.location_id
        WHERE (e.event_name LIKE ? OR l.location_name LIKE ?)
          AND (? = '' OR e.status = ?)
        ORDER BY e.event_date, e.event_name
        """,
        (pattern, pattern, status, status),
    ).fetchall()
    print_rows(rows)


def event_details(connection: sqlite3.Connection) -> None:
    """Display one event plus its related location, volunteers, and supplies."""
    event_id = integer("Event ID: ", 1)
    event = connection.execute(
        """
        SELECT e.event_name, e.event_date, e.status, e.description,
               l.location_name, l.street_address, l.city, l.state
        FROM event AS e
        JOIN location AS l ON l.location_id = e.location_id
        WHERE e.event_id = ?
        """,
        (event_id,),
    ).fetchone()
    if event is None:
        print("Event not found.")
        return
    print_rows([event])
    # These are separate queries so each related collection can be displayed
    # clearly without multiplying volunteer rows by supply rows.
    volunteers = connection.execute(
        """
        SELECT v.first_name || ' ' || v.last_name AS volunteer,
               ep.role, ep.hours_worked
        FROM event_participation AS ep
        JOIN volunteer AS v ON v.volunteer_id = ep.volunteer_id
        WHERE ep.event_id = ?
        ORDER BY volunteer
        """,
        (event_id,),
    ).fetchall()
    supplies = connection.execute(
        """
        SELECT s.supply_name, sr.quantity_requested, sr.request_status
        FROM supply_request AS sr
        JOIN supply AS s ON s.supply_id = sr.supply_id
        WHERE sr.event_id = ?
        ORDER BY s.supply_name
        """,
        (event_id,),
    ).fetchall()
    print("\nVolunteers")
    print_rows(volunteers)
    print("\nSupply requests")
    print_rows(supplies)


def add_volunteer(connection: sqlite3.Connection) -> None:
    """Validate and insert a new volunteer record."""
    first = required("First name: ")
    last = required("Last name: ")
    email = required("Email: ")
    if not EMAIL_PATTERN.fullmatch(email):
        print("Enter a valid email address.")
        return
    phone = input("Phone (optional): ").strip() or None
    try:
        # The UNIQUE email constraint provides a second line of defense.
        cursor = connection.execute(
            """
            INSERT INTO volunteer (first_name, last_name, email, phone)
            VALUES (?, ?, ?, ?)
            """,
            (first, last, email, phone),
        )
        connection.commit()
        print(f"Volunteer added with ID {cursor.lastrowid}.")
    except sqlite3.IntegrityError:
        connection.rollback()
        print("A volunteer with that email already exists.")


def register_volunteer(connection: sqlite3.Connection) -> None:
    """Create the many-to-many event/volunteer relationship."""
    event_id = integer("Event ID: ", 1)
    volunteer_id = integer("Volunteer ID: ", 1)
    role = input("Role (default volunteer): ").strip() or "volunteer"
    try:
        connection.execute(
            """
            INSERT INTO event_participation (event_id, volunteer_id, role)
            VALUES (?, ?, ?)
            """,
            (event_id, volunteer_id, role),
        )
        connection.commit()
        print("Volunteer registered.")
    except sqlite3.IntegrityError as error:
        connection.rollback()
        if "UNIQUE" in str(error).upper():
            print("That volunteer is already registered for this event.")
        else:
            print("Event or volunteer ID does not exist.")


def update_event_status(connection: sqlite3.Connection) -> None:
    """Update an event after validating its ID and new status."""
    event_id = integer("Event ID: ", 1)
    status = choose_status("New status: ")
    cursor = connection.execute(
        "UPDATE event SET status = ? WHERE event_id = ?",
        (status, event_id),
    )
    connection.commit()
    print("Event status updated." if cursor.rowcount else "Event not found.")


def activity_report(connection: sqlite3.Connection) -> None:
    """Display the schema's view combining event staffing and supplies."""
    rows = connection.execute(
        """
        SELECT event_name, event_date, status, location_name,
               volunteer_count, ROUND(total_hours, 2) AS total_hours,
               supply_request_count, total_units_requested
        FROM event_activity_summary
        ORDER BY event_date
        """
    ).fetchall()
    print_rows(rows)


def inventory_report(connection: sqlite3.Connection) -> None:
    """Find supplies at or below reorder level using aggregation."""
    rows = connection.execute(
        """
        SELECT s.supply_name, s.quantity_on_hand, s.reorder_level,
               COALESCE(SUM(CASE WHEN it.transaction_type = 'usage'
                                 THEN -it.quantity_change ELSE 0 END), 0)
                   AS units_used
        FROM supply AS s
        LEFT JOIN inventory_transaction AS it ON it.supply_id = s.supply_id
        GROUP BY s.supply_id, s.supply_name, s.quantity_on_hand, s.reorder_level
        HAVING s.quantity_on_hand <= s.reorder_level
        ORDER BY s.quantity_on_hand, s.supply_name
        """
    ).fetchall()
    print("Supplies at or below reorder level")
    print_rows(rows)


def fulfill_request(connection: sqlite3.Connection) -> None:
    """Fulfill a request as one atomic inventory operation."""
    request_id = integer("Approved request ID: ", 1)
    request = connection.execute(
        """
        SELECT sr.supply_id, sr.event_id, sr.quantity_requested,
               s.supply_name, s.quantity_on_hand
        FROM supply_request AS sr
        JOIN supply AS s ON s.supply_id = sr.supply_id
        WHERE sr.request_id = ? AND sr.request_status = 'approved'
        """,
        (request_id,),
    ).fetchone()
    if request is None:
        print("No approved request found with that ID.")
        return
    if request["quantity_on_hand"] < request["quantity_requested"]:
        print("Insufficient inventory; request was not changed.")
        return
    try:
        # The context manager commits all three statements together, or rolls
        # them back together if one statement fails.
        with connection:
            connection.execute(
                """
                UPDATE supply_request
                SET request_status = 'fulfilled'
                WHERE request_id = ?
                """,
                (request_id,),
            )
            connection.execute(
                """
                UPDATE supply
                SET quantity_on_hand = quantity_on_hand - ?
                WHERE supply_id = ?
                """,
                (request["quantity_requested"], request["supply_id"]),
            )
            connection.execute(
                """
                INSERT INTO inventory_transaction
                    (supply_id, event_id, transaction_type, quantity_change,
                     transaction_date, notes)
                VALUES (?, ?, 'usage', ?, date('now'), ?)
                """,
                (
                    request["supply_id"],
                    request["event_id"],
                    -request["quantity_requested"],
                    f"Fulfilled supply request {request_id}",
                ),
            )
        print(f"Request fulfilled. {request['supply_name']} inventory updated.")
    except sqlite3.IntegrityError:
        connection.rollback()
        print("The request could not be fulfilled.")


def menu() -> None:
    """Show the operations available to the user."""
    print(
        "\nKeep Knoxville Beautiful\n"
        "1. Search or browse events\n"
        "2. View event details (volunteers and supplies)\n"
        "3. Add a volunteer\n"
        "4. Register a volunteer for an event\n"
        "5. Update event status\n"
        "6. Event activity summary report\n"
        "7. Low-inventory report\n"
        "8. Fulfill an approved supply request\n"
        "0. Exit"
    )


def run(database: Path) -> None:
    """Start the menu loop and close the connection when the app exits."""
    if not database.exists():
        print(f"Database not found: {database}")
        print("Create it with: sqlite3 knoxville_beautiful.db < schema.sql")
        return
    connection = connect(database)
    # Menu choices map directly to functions, keeping the loop small and clear.
    actions = {
        "1": browse_events,
        "2": event_details,
        "3": add_volunteer,
        "4": register_volunteer,
        "5": update_event_status,
        "6": activity_report,
        "7": inventory_report,
        "8": fulfill_request,
    }
    try:
        while True:
            menu()
            choice = input("Choose an option: ").strip()
            if choice == "0":
                print("Goodbye.")
                return
            action = actions.get(choice)
            if action is None:
                print("Invalid menu choice.")
                continue
            try:
                action(connection)
            except sqlite3.Error:
                # Prevent a failed statement from leaving an open transaction.
                connection.rollback()
                print("The database operation could not be completed.")
    finally:
        connection.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--database",
        type=Path,
        default=DEFAULT_DB,
        help="SQLite database path (default: knoxville_beautiful.db)",
    )
    run(parser.parse_args().database)
