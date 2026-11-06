-- Keep Knoxville Beautiful Deliverable 4 transaction example
-- DBMS: SQLite 3
-- Fulfill the approved supply request for event 5 as one atomic operation.
-- ROLLBACK keeps the sample database unchanged after the demonstration.

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

UPDATE supply_request
SET request_status = 'fulfilled'
WHERE request_id = 11
  AND request_status = 'approved';

UPDATE supply
SET quantity_on_hand = quantity_on_hand - (
    SELECT quantity_requested
    FROM supply_request
    WHERE request_id = 11
)
WHERE supply_id = (
    SELECT supply_id
    FROM supply_request
    WHERE request_id = 11
)
AND quantity_on_hand >= (
    SELECT quantity_requested
    FROM supply_request
    WHERE request_id = 11
);

INSERT INTO inventory_transaction (
    transaction_id,
    supply_id,
    event_id,
    transaction_type,
    quantity_change,
    transaction_date,
    notes
)
SELECT
    23,
    supply_id,
    event_id,
    'usage',
    -quantity_requested,
    '2026-05-16',
    'Fulfilled supply request 11'
FROM supply_request
WHERE request_id = 11;

SELECT
    request_status,
    (SELECT quantity_on_hand FROM supply WHERE supply_id = 1) AS remaining_supply,
    (SELECT COUNT(*) FROM inventory_transaction WHERE transaction_id = 23)
        AS transaction_rows_created
FROM supply_request
WHERE request_id = 11;

ROLLBACK;

SELECT
    request_status AS status_after_rollback,
    (SELECT quantity_on_hand FROM supply WHERE supply_id = 1)
        AS supply_after_rollback,
    (SELECT COUNT(*) FROM inventory_transaction WHERE transaction_id = 23)
        AS transaction_rows_after_rollback
FROM supply_request
WHERE request_id = 11;
