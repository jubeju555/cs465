#!/usr/bin/env python3
"""Local web application for Keep Knoxville Beautiful."""

from __future__ import annotations

import argparse
import json
import sqlite3
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from app import DEFAULT_DB, EMAIL_PATTERN, STATUSES, connect


ROOT = Path(__file__).parent
STATIC = ROOT / "static"


def rows_as_dicts(rows: list[sqlite3.Row]) -> list[dict[str, object]]:
    return [dict(row) for row in rows]


def read_json(handler: BaseHTTPRequestHandler) -> dict[str, object]:
    length = int(handler.headers.get("Content-Length", "0"))
    if length <= 0 or length > 1_000_000:
        raise ValueError("A JSON request body is required.")
    try:
        payload = json.loads(handler.rfile.read(length))
    except json.JSONDecodeError as error:
        raise ValueError("Request body must be valid JSON.") from error
    if not isinstance(payload, dict):
        raise ValueError("Request body must be a JSON object.")
    return payload


class ApplicationHandler(BaseHTTPRequestHandler):
    database: Path = DEFAULT_DB

    def log_message(self, format: str, *args: object) -> None:
        print(f"{self.address_string()} - {format % args}")

    def send_json(
        self, payload: dict[str, object], status: HTTPStatus = HTTPStatus.OK
    ) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def send_error_json(self, message: str, status: HTTPStatus) -> None:
        self.send_json({"error": message}, status)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/":
            self.serve_file("index.html", "text/html; charset=utf-8")
            return
        if parsed.path.startswith("/static/"):
            self.serve_file(parsed.path.removeprefix("/static/"))
            return
        try:
            self.handle_get(parsed.path, parse_qs(parsed.query))
        except sqlite3.Error:
            self.send_error_json("The database operation failed.", HTTPStatus.INTERNAL_SERVER_ERROR)
        except (ValueError, KeyError) as error:
            self.send_error_json(str(error), HTTPStatus.BAD_REQUEST)

    def do_POST(self) -> None:
        try:
            self.handle_post(urlparse(self.path).path, read_json(self))
        except sqlite3.IntegrityError as error:
            message = (
                "That record already exists."
                if "UNIQUE" in str(error).upper()
                else "The selected event or volunteer does not exist."
            )
            self.send_error_json(message, HTTPStatus.CONFLICT)
        except sqlite3.Error:
            self.send_error_json("The database operation failed.", HTTPStatus.INTERNAL_SERVER_ERROR)
        except (ValueError, KeyError) as error:
            self.send_error_json(str(error), HTTPStatus.BAD_REQUEST)

    def do_PATCH(self) -> None:
        try:
            self.handle_patch(urlparse(self.path).path, read_json(self))
        except sqlite3.Error:
            self.send_error_json("The database operation failed.", HTTPStatus.INTERNAL_SERVER_ERROR)
        except (ValueError, KeyError) as error:
            self.send_error_json(str(error), HTTPStatus.BAD_REQUEST)

    def serve_file(self, name: str, content_type: str | None = None) -> None:
        path = (STATIC / name).resolve() if name != "index.html" else (ROOT / name).resolve()
        base = STATIC.resolve() if name != "index.html" else ROOT.resolve()
        if base not in path.parents or not path.is_file():
            self.send_error_json("Page not found.", HTTPStatus.NOT_FOUND)
            return
        content = path.read_bytes()
        if content_type is None:
            content_type = "text/css; charset=utf-8" if path.suffix == ".css" else "application/javascript; charset=utf-8"
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def handle_get(self, path: str, query: dict[str, list[str]]) -> None:
        with connect(self.database) as connection:
            if path == "/api/dashboard":
                stats = connection.execute(
                    """
                    SELECT
                      (SELECT COUNT(*) FROM event) AS event_count,
                      (SELECT COUNT(*) FROM volunteer) AS volunteer_count,
                      (SELECT COUNT(*) FROM supply WHERE quantity_on_hand <= reorder_level)
                        AS low_stock_count,
                      (SELECT COALESCE(SUM(hours_worked), 0)
                       FROM event_participation) AS volunteer_hours
                    """
                ).fetchone()
                upcoming = connection.execute(
                    """
                    SELECT e.event_id, e.event_name, e.event_date, e.status,
                           l.location_name
                    FROM event AS e
                    JOIN location AS l ON l.location_id = e.location_id
                    WHERE e.status IN ('open', 'planned')
                    ORDER BY e.event_date
                    LIMIT 5
                    """
                ).fetchall()
                self.send_json({"stats": dict(stats), "upcoming": rows_as_dicts(upcoming)})
            elif path == "/api/events":
                search = query.get("search", [""])[0].strip()
                status = query.get("status", [""])[0].strip().lower()
                if status and status not in STATUSES:
                    raise ValueError("Invalid event status.")
                pattern = f"%{search}%"
                events = connection.execute(
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
                self.send_json({"events": rows_as_dicts(events)})
            elif path.startswith("/api/events/"):
                event_id = self.path_id(path, "/api/events/")
                event = connection.execute(
                    """
                    SELECT e.event_id, e.event_name, e.event_date, e.status,
                           e.description, l.location_name, l.street_address,
                           l.city, l.state, l.postal_code
                    FROM event AS e
                    JOIN location AS l ON l.location_id = e.location_id
                    WHERE e.event_id = ?
                    """,
                    (event_id,),
                ).fetchone()
                if event is None:
                    self.send_error_json("Event not found.", HTTPStatus.NOT_FOUND)
                    return
                volunteers = connection.execute(
                    """
                    SELECT v.volunteer_id, v.first_name || ' ' || v.last_name AS volunteer,
                           ep.role, ep.hours_worked
                    FROM event_participation AS ep
                    JOIN volunteer AS v ON v.volunteer_id = ep.volunteer_id
                    WHERE ep.event_id = ? ORDER BY volunteer
                    """,
                    (event_id,),
                ).fetchall()
                supplies = connection.execute(
                    """
                    SELECT sr.request_id, s.supply_name, sr.quantity_requested,
                           sr.request_status
                    FROM supply_request AS sr
                    JOIN supply AS s ON s.supply_id = sr.supply_id
                    WHERE sr.event_id = ? ORDER BY s.supply_name
                    """,
                    (event_id,),
                ).fetchall()
                self.send_json({
                    "event": dict(event),
                    "volunteers": rows_as_dicts(volunteers),
                    "supplies": rows_as_dicts(supplies),
                })
            elif path == "/api/volunteers":
                volunteers = connection.execute(
                    """
                    SELECT volunteer_id, first_name, last_name, email, phone
                    FROM volunteer ORDER BY last_name, first_name
                    """
                ).fetchall()
                self.send_json({"volunteers": rows_as_dicts(volunteers)})
            elif path == "/api/activity":
                summary = connection.execute(
                    """
                    SELECT event_name, event_date, status, location_name,
                           volunteer_count, ROUND(total_hours, 2) AS total_hours,
                           supply_request_count, total_units_requested
                    FROM event_activity_summary ORDER BY event_date
                    """
                ).fetchall()
                self.send_json({"summary": rows_as_dicts(summary)})
            elif path == "/api/inventory":
                inventory = connection.execute(
                    """
                    SELECT s.supply_id, s.supply_name, s.unit, s.quantity_on_hand,
                           s.reorder_level,
                           COALESCE(SUM(CASE WHEN it.transaction_type = 'usage'
                                             THEN -it.quantity_change ELSE 0 END), 0)
                               AS units_used
                    FROM supply AS s
                    LEFT JOIN inventory_transaction AS it ON it.supply_id = s.supply_id
                    GROUP BY s.supply_id, s.supply_name, s.unit,
                             s.quantity_on_hand, s.reorder_level
                    ORDER BY s.quantity_on_hand <= s.reorder_level DESC,
                             s.supply_name
                    """
                ).fetchall()
                self.send_json({"inventory": rows_as_dicts(inventory)})
            else:
                self.send_error_json("API route not found.", HTTPStatus.NOT_FOUND)

    def handle_post(self, path: str, payload: dict[str, object]) -> None:
        with connect(self.database) as connection:
            if path == "/api/volunteers":
                first = self.text(payload, "first_name")
                last = self.text(payload, "last_name")
                email = self.text(payload, "email")
                if not EMAIL_PATTERN.fullmatch(email):
                    raise ValueError("Enter a valid email address.")
                cursor = connection.execute(
                    """
                    INSERT INTO volunteer (first_name, last_name, email, phone)
                    VALUES (?, ?, ?, ?)
                    """,
                    (first, last, email, payload.get("phone") or None),
                )
                self.send_json({"message": "Volunteer added.", "id": cursor.lastrowid},
                               HTTPStatus.CREATED)
            elif path == "/api/participation":
                event_id = self.positive_int(payload, "event_id")
                volunteer_id = self.positive_int(payload, "volunteer_id")
                role = self.text(payload, "role", "volunteer")
                connection.execute(
                    """
                    INSERT INTO event_participation (event_id, volunteer_id, role)
                    VALUES (?, ?, ?)
                    """,
                    (event_id, volunteer_id, role),
                )
                self.send_json({"message": "Volunteer registered."}, HTTPStatus.CREATED)
            elif path.startswith("/api/requests/") and path.endswith("/fulfill"):
                request_id = self.path_id(path.removesuffix("/fulfill"), "/api/requests/")
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
                    raise ValueError("No approved request found with that ID.")
                if request["quantity_on_hand"] < request["quantity_requested"]:
                    raise ValueError("Insufficient inventory.")
                with connection:
                    connection.execute(
                        "UPDATE supply_request SET request_status = 'fulfilled' WHERE request_id = ?",
                        (request_id,),
                    )
                    connection.execute(
                        "UPDATE supply SET quantity_on_hand = quantity_on_hand - ? WHERE supply_id = ?",
                        (request["quantity_requested"], request["supply_id"]),
                    )
                    connection.execute(
                        """
                        INSERT INTO inventory_transaction
                            (supply_id, event_id, transaction_type, quantity_change,
                             transaction_date, notes)
                        VALUES (?, ?, 'usage', ?, date('now'), ?)
                        """,
                        (request["supply_id"], request["event_id"],
                         -request["quantity_requested"], f"Fulfilled request {request_id}"),
                    )
                self.send_json({"message": f"{request['supply_name']} request fulfilled."})
            else:
                self.send_error_json("API route not found.", HTTPStatus.NOT_FOUND)

    def handle_patch(self, path: str, payload: dict[str, object]) -> None:
        if not path.startswith("/api/events/") or not path.endswith("/status"):
            self.send_error_json("API route not found.", HTTPStatus.NOT_FOUND)
            return
        event_id = self.path_id(path.removesuffix("/status"), "/api/events/")
        status = self.text(payload, "status").lower()
        if status not in STATUSES:
            raise ValueError("Invalid event status.")
        with connect(self.database) as connection:
            cursor = connection.execute(
                "UPDATE event SET status = ? WHERE event_id = ?", (status, event_id)
            )
            if cursor.rowcount == 0:
                self.send_error_json("Event not found.", HTTPStatus.NOT_FOUND)
                return
        self.send_json({"message": "Event status updated."})

    @staticmethod
    def path_id(path: str, prefix: str) -> int:
        value = path.removeprefix(prefix)
        if not value.isdigit() or int(value) < 1:
            raise ValueError("Invalid ID.")
        return int(value)

    @staticmethod
    def text(payload: dict[str, object], key: str, default: str | None = None) -> str:
        value = payload.get(key, default)
        if not isinstance(value, str) or not value.strip():
            raise ValueError(f"{key.replace('_', ' ').capitalize()} is required.")
        return value.strip()

    @staticmethod
    def positive_int(payload: dict[str, object], key: str) -> int:
        value = payload.get(key)
        if isinstance(value, bool) or not isinstance(value, int) or value < 1:
            raise ValueError(f"{key.replace('_', ' ').capitalize()} must be a positive integer.")
        return value


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=DEFAULT_DB)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()
    ApplicationHandler.database = args.database
    server = ThreadingHTTPServer((args.host, args.port), ApplicationHandler)
    print(f"Keep Knoxville Beautiful running at http://{args.host}:{args.port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
