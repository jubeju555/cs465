-- Keep Knoxville Beautiful Deliverable 4 queries
-- DBMS: SQLite 3

-- Requirement 1: Filtering and Sorting
-- Which upcoming or active events are scheduled first?
SELECT event_id, event_name, event_date, status
FROM event
WHERE status IN ('open', 'planned')
ORDER BY event_date ASC;

-- Requirement 2: INNER JOIN
-- Which volunteers are registered for each cleanup event?
SELECT
    e.event_name,
    v.first_name || ' ' || v.last_name AS volunteer_name,
    ep.role,
    ep.hours_worked
FROM event_participation AS ep
INNER JOIN event AS e ON e.event_id = ep.event_id
INNER JOIN volunteer AS v ON v.volunteer_id = ep.volunteer_id
ORDER BY e.event_date, volunteer_name;

-- Requirement 3: LEFT JOIN
-- Which events have no inventory transaction recorded yet?
SELECT
    e.event_name,
    e.event_date,
    e.status,
    it.transaction_id
FROM event AS e
LEFT JOIN inventory_transaction AS it ON it.event_id = e.event_id
WHERE it.transaction_id IS NULL
ORDER BY e.event_date;

-- Requirement 4: Three-Table Join
-- What supplies are requested for each event, and where will the event occur?
SELECT
    e.event_name,
    l.location_name,
    s.supply_name,
    sr.quantity_requested,
    sr.request_status
FROM supply_request AS sr
INNER JOIN event AS e ON e.event_id = sr.event_id
INNER JOIN location AS l ON l.location_id = e.location_id
INNER JOIN supply AS s ON s.supply_id = sr.supply_id
ORDER BY e.event_date, s.supply_name;

-- Requirement 5: Aggregate Query
-- How many volunteer hours have been scheduled across all event registrations?
SELECT
    COUNT(*) AS registration_count,
    ROUND(SUM(hours_worked), 2) AS total_scheduled_hours,
    ROUND(AVG(hours_worked), 2) AS average_hours_per_registration
FROM event_participation;

-- Requirement 6: GROUP BY and HAVING
-- Which volunteers are registered for at least two events?
SELECT
    v.volunteer_id,
    v.first_name || ' ' || v.last_name AS volunteer_name,
    COUNT(ep.event_id) AS events_registered
FROM volunteer AS v
INNER JOIN event_participation AS ep ON ep.volunteer_id = v.volunteer_id
GROUP BY v.volunteer_id, v.first_name, v.last_name
HAVING COUNT(ep.event_id) >= 2
ORDER BY events_registered DESC, volunteer_name;

-- Requirement 7: Subquery
-- Which supplies have below-average stock and should be prioritized for review?
SELECT
    supply_name,
    quantity_on_hand,
    reorder_level
FROM supply
WHERE quantity_on_hand < (
    SELECT AVG(quantity_on_hand)
    FROM supply
)
ORDER BY quantity_on_hand;

-- Requirement 8: Set Operation
-- Which volunteers have participated in a completed event or are registered
-- for an open event? UNION returns each qualifying volunteer only once.
SELECT volunteer_id
FROM event_participation
WHERE event_id IN (
    SELECT event_id
    FROM event
    WHERE status = 'completed'
)
UNION
SELECT volunteer_id
FROM event_participation
WHERE event_id IN (
    SELECT event_id
    FROM event
    WHERE status = 'open'
)
ORDER BY volunteer_id;

-- Requirement 9: View
-- Which event summaries show staffing and supply planning in one report?
SELECT
    event_name,
    location_name,
    status,
    volunteer_count,
    total_hours,
    supply_request_count,
    total_units_requested
FROM event_activity_summary
WHERE status IN ('open', 'planned')
ORDER BY event_date;
