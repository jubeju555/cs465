#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DB_FILE="$SCRIPT_DIR/knoxville_beautiful.db"

rm -f "$DB_FILE"

echo "Creating a fresh SQLite database..."
sqlite3 "$DB_FILE" < "$SCRIPT_DIR/schema.sql"
sqlite3 "$DB_FILE" < "$SCRIPT_DIR/insert_data.sql"

echo
echo "Running required queries..."
sqlite3 -header -column "$DB_FILE" < "$SCRIPT_DIR/queries.sql"

echo
echo "Running transaction demonstration..."
sqlite3 -header -column "$DB_FILE" < "$SCRIPT_DIR/transaction.sql"

echo
echo "Database recreation and Deliverable 4 checks completed."
