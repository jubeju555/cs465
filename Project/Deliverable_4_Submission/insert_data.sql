-- Sample data for schema.sql
-- Run schema.sql before this file.

PRAGMA foreign_keys = ON;

INSERT INTO location (location_id, location_name, street_address, city, state, postal_code) VALUES
    (1, 'Ijams Nature Center', '2915 Island Home Ave', 'Knoxville', 'TN', '37920'),
    (2, 'World''s Fair Park', '963 Worlds Fair Park Dr', 'Knoxville', 'TN', '37916'),
    (3, 'Third Creek Greenway', '3502 Kingston Pike', 'Knoxville', 'TN', '37919'),
    (4, 'Lakeshore Park', '6410 Northshore Dr', 'Knoxville', 'TN', '37919'),
    (5, 'Suttree Landing Park', '1001 Waterfront Dr', 'Knoxville', 'TN', '37920');

INSERT INTO volunteer (volunteer_id, first_name, last_name, email, phone) VALUES
    (1, 'Avery', 'Brooks', 'avery.brooks@example.org', '865-555-0101'),
    (2, 'Jordan', 'Chen', 'jordan.chen@example.org', '865-555-0102'),
    (3, 'Maya', 'Davis', 'maya.davis@example.org', '865-555-0103'),
    (4, 'Eli', 'Foster', 'eli.foster@example.org', '865-555-0104'),
    (5, 'Nora', 'Garcia', 'nora.garcia@example.org', '865-555-0105'),
    (6, 'Sam', 'Hughes', 'sam.hughes@example.org', NULL),
    (7, 'Priya', 'Jackson', 'priya.jackson@example.org', '865-555-0107'),
    (8, 'Theo', 'Lewis', 'theo.lewis@example.org', '865-555-0108');

INSERT INTO supply (supply_id, supply_name, unit, quantity_on_hand, reorder_level) VALUES
    (1, 'Heavy-duty trash bags', 'box', 18, 8),
    (2, 'Recycling bags', 'box', 12, 6),
    (3, 'Work gloves', 'pair', 64, 24),
    (4, 'Safety vests', 'each', 31, 12),
    (5, 'Litter grabbers', 'each', 27, 10),
    (6, 'Reusable water bottles', 'each', 45, 15),
    (7, 'First-aid kits', 'kit', 6, 3),
    (8, 'Hand sanitizer', 'bottle', 22, 8),
    (9, 'Compostable cups', 'sleeve', 16, 5),
    (10, 'Traffic cones', 'each', 40, 12);

INSERT INTO event (event_id, location_id, event_name, event_date, status, description) VALUES
    (1, 1, 'Ijams River Cleanup', '2026-02-14', 'completed', 'Remove litter along the river trail.'),
    (2, 2, 'Spring Festival Grounds Sweep', '2026-03-21', 'completed', 'Clean the park before festival setup.'),
    (3, 3, 'Third Creek Trail Day', '2026-04-18', 'completed', 'Collect litter and clear trail edges.'),
    (4, 4, 'Lakeshore Earth Day Cleanup', '2026-04-25', 'completed', 'Earth Day cleanup around the lake.'),
    (5, 5, 'Downtown Riverfront Cleanup', '2026-05-16', 'open', 'Weekend cleanup at the riverfront.'),
    (6, 1, 'Summer Creek Patrol', '2026-06-20', 'open', 'Inspect and clean creek access points.'),
    (7, 2, 'Community Park Cleanup', '2026-07-11', 'planned', 'Prepare the park for summer programming.'),
    (8, 4, 'Fall Leaves and Litter Day', '2026-10-17', 'planned', 'Seasonal cleanup and litter audit.');

INSERT INTO event_participation (event_id, volunteer_id, role, hours_worked, registered_at) VALUES
    (1, 1, 'captain', 4.0, '2026-02-01 09:00:00'),
    (1, 2, 'volunteer', 3.5, '2026-02-02 10:15:00'),
    (1, 5, 'safety lead', 4.0, '2026-02-03 08:30:00'),
    (1, 7, 'volunteer', 2.5, '2026-02-04 12:00:00'),
    (2, 2, 'captain', 3.0, '2026-03-01 09:10:00'),
    (2, 3, 'volunteer', 3.0, '2026-03-02 11:20:00'),
    (2, 4, 'volunteer', 2.5, '2026-03-03 14:00:00'),
    (2, 8, 'volunteer', 3.0, '2026-03-04 15:45:00'),
    (3, 1, 'volunteer', 2.0, '2026-04-01 09:00:00'),
    (3, 4, 'captain', 4.0, '2026-04-02 10:00:00'),
    (3, 6, 'volunteer', 3.5, '2026-04-03 10:30:00'),
    (4, 3, 'captain', 4.0, '2026-04-05 08:00:00'),
    (4, 5, 'volunteer', 3.5, '2026-04-06 13:00:00'),
    (4, 7, 'volunteer', 3.0, '2026-04-07 16:00:00'),
    (5, 1, 'captain', 2.0, '2026-05-01 09:00:00'),
    (5, 6, 'volunteer', 2.0, '2026-05-02 09:30:00'),
    (5, 8, 'volunteer', 2.5, '2026-05-03 10:00:00'),
    (6, 2, 'captain', 3.0, '2026-06-01 08:00:00'),
    (6, 5, 'volunteer', 3.0, '2026-06-02 10:00:00'),
    (7, 3, 'captain', 0.0, '2026-06-15 11:00:00'),
    (8, 4, 'captain', 0.0, '2026-08-01 12:00:00');

INSERT INTO supply_request (request_id, event_id, supply_id, quantity_requested, request_status, requested_at) VALUES
    (1, 1, 1, 4, 'fulfilled', '2026-02-05 09:00:00'),
    (2, 1, 3, 12, 'fulfilled', '2026-02-05 09:05:00'),
    (3, 1, 5, 8, 'fulfilled', '2026-02-05 09:10:00'),
    (4, 2, 1, 5, 'fulfilled', '2026-03-08 10:00:00'),
    (5, 2, 4, 10, 'fulfilled', '2026-03-08 10:05:00'),
    (6, 2, 10, 8, 'fulfilled', '2026-03-08 10:10:00'),
    (7, 3, 2, 4, 'fulfilled', '2026-04-04 09:00:00'),
    (8, 3, 3, 10, 'fulfilled', '2026-04-04 09:05:00'),
    (9, 4, 1, 6, 'fulfilled', '2026-04-10 11:00:00'),
    (10, 4, 6, 12, 'fulfilled', '2026-04-10 11:05:00'),
    (11, 5, 1, 5, 'approved', '2026-05-05 09:00:00'),
    (12, 5, 7, 2, 'approved', '2026-05-05 09:05:00'),
    (13, 6, 3, 8, 'requested', '2026-06-05 12:00:00'),
    (14, 6, 8, 6, 'requested', '2026-06-05 12:05:00'),
    (15, 7, 4, 12, 'requested', '2026-06-20 12:00:00'),
    (16, 8, 9, 4, 'requested', '2026-08-05 12:00:00');

INSERT INTO inventory_transaction (transaction_id, supply_id, event_id, transaction_type, quantity_change, transaction_date, notes) VALUES
    (1, 1, NULL, 'restock', 30, '2026-01-10', 'January warehouse delivery'),
    (2, 2, NULL, 'restock', 20, '2026-01-10', 'January warehouse delivery'),
    (3, 3, NULL, 'restock', 80, '2026-01-10', 'Volunteer glove shipment'),
    (4, 4, NULL, 'restock', 40, '2026-01-10', 'Safety equipment shipment'),
    (5, 5, NULL, 'restock', 35, '2026-01-10', 'Tool replacement order'),
    (6, 6, NULL, 'restock', 60, '2026-01-10', 'Hydration supplies'),
    (7, 7, NULL, 'restock', 8, '2026-01-10', 'Medical supplies'),
    (8, 8, NULL, 'restock', 30, '2026-01-10', 'Sanitizer delivery'),
    (9, 9, NULL, 'restock', 20, '2026-01-10', 'Event serving supplies'),
    (10, 10, NULL, 'restock', 50, '2026-01-10', 'Traffic control supplies'),
    (11, 1, 1, 'usage', -4, '2026-02-14', 'Used during river cleanup'),
    (12, 3, 1, 'usage', -12, '2026-02-14', 'Issued to volunteers'),
    (13, 5, 1, 'usage', -8, '2026-02-14', 'Issued to cleanup teams'),
    (14, 1, 2, 'usage', -5, '2026-03-21', 'Used during grounds sweep'),
    (15, 4, 2, 'usage', -10, '2026-03-21', 'Issued to volunteers'),
    (16, 10, 2, 'usage', -8, '2026-03-21', 'Used for pedestrian safety'),
    (17, 2, 3, 'usage', -4, '2026-04-18', 'Recycling collection'),
    (18, 3, 3, 'usage', -10, '2026-04-18', 'Issued to volunteers'),
    (19, 1, 4, 'usage', -6, '2026-04-25', 'Used during Earth Day cleanup'),
    (20, 6, 4, 'usage', -12, '2026-04-25', 'Volunteer hydration supplies'),
    (21, 3, NULL, 'adjustment', 2, '2026-05-01', 'Inventory count correction'),
    (22, 8, NULL, 'restock', 12, '2026-05-01', 'May sanitizer delivery');
