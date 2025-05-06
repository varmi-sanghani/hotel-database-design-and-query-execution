set search_path to hotel_db;

INSERT INTO guest (guest_id, first_name, last_name, phone_no, email, guest_address) VALUES
(1001, 'Liam', 'Smith', '979-123-4567', 'liam.smith@gmail.com', '123 Main St, Dallas, TX'),
(1002, 'Stephanie', 'Garcia', '848-456-7890', 'stephanie.garcia@yahoo.com', '456 Elm St, Dallas, TX'),
(1003, 'John', 'Davis', '979-111-2345', 'john.davis@gmail.com', '789 Pine St, Houston, TX'),
(1004, 'Lily', 'Chavez', '878-222-4848', 'lilychavez123@gmail.com', '101 Oak St, Los Angeles, CA'),
(1005, 'Will', 'Davis', '979-234-5678', 'willdavis5678@gmail.com', '202 Maple St, New York, NY');

-- DML for inserting data into reservation Entity
INSERT INTO reservation (reservation_id, guest_id, room_id, billing_id, check_in_date, check_out_date, number_of_guests, status) VALUES
(1,1001, 1, 1111, '2023-02-15', '2023-02-17', 2, 'confirmed'),
(2,1002, 2, 1112, '2023-08-18', '2023-08-22', 1, 'cancelled'),
(3,1003, 3, 1113, '2024-05-25', '2024-05-26', 3, 'confirmed'),
(4,1004, 4, 1114, '2024-12-01', '2024-12-02', 4, 'confirmed'),
(5, 1005, 5, 1115, '2025-01-08', '2025-01-10', 2, 'cancelled');

-- DML for inserting data into billing_records Entity
INSERT INTO billing_records (reservation_id, total_amount, payment_method, billing_date, billing_address) VALUES
(1, 500.00, 'Credit Card', '2023-02-15', '123 Main St, Dallas, TX'),
(2, 600.00, 'Debit Card', '2023-08-18', '110 Pine St, Houston, TX'),
(3, 450.00, 'Cash', '2024-05-25', '432 Damascus St, Austin, TX'),
(4, 500.00, 'Credit Card', '2024-12-01', '101 Oak St, Los Angeles, CA'),
(5, 350.00, 'Debit Card', '2025-01-08', '789 Greenwood St, Houston, TX');

-- DML for inserting data into room Entity
INSERT INTO room (room_id, room_no, room_type, capacity, availability, reservation_id) VALUES
(1, 101, 'Single', 2, 'Unoccupied', 1),
(2, 102, 'Single', 2, 'Occupied', 2),
(3, 201, 'Double', 4, 'Unoccupied', 3),
(4, 202, 'Double', 4, 'Unoccupied', 4),
(5, 203, 'Suite', 2, 'Occupied', 5);

-- DML for inserting data into room_service Entity
INSERT INTO room_service (service_name, service_cost, service_payment_status, service_description, room_id) VALUES
('Laundry', 15.00, 'Paid', 'Same-day laundry service', 1),
('Breakfast', 20.00, 'Paid', 'Continental breakfast delivered to room', 2),
('Laundry', 15.00, 'Unpaid', 'Same-day laundry service', 3),
('Dinner', 25.00, 'Unpaid', 'Three-course dinner served in room', 4),
('Spa', 50.00, 'Paid', 'In-room massage and spa service', 5);

COMMIT;

--Query 1: Select all columns and all rows from one table
SELECT * FROM guest;

--Query 2: Select five columns and all rows from one table
SELECT guest_id, first_name, last_name, phone_no, email FROM guest;

--Query 3: Select all columns from all rows from one view
SELECT * FROM total_billed_amount;

--Query 4: Using a join on 2 tables, select all columns and all rows from the tables without the use of a Cartesian product
SELECT * FROM reservation
JOIN guest ON reservation.guest_id = guest.guest_id;

--Query 5: Select and order data retrieved from one table 
SELECT * FROM room ORDER BY room_type;

--Query 6: Using a join on 3 tables, select 5 columns from the 3 tables. Use syntax that would limit the output to 3 rows
SELECT r.*, g.first_name, g.last_name, rm.room_type
FROM reservation r
JOIN guest g ON r.guest_id = g.guest_id
JOIN room rm ON r.room_id = rm.room_id
LIMIT 3;

--Query 7: Select distinct rows using joins on 3 tables
SELECT DISTINCT r.*, g.first_name, g.last_name, rm.room_type
FROM reservation r
JOIN guest g ON r.guest_id = g.guest_id
JOIN room rm ON r.room_id = rm.room_id;

--Query 8: Use GROUP BY and HAVING in a select statement using one or more tables
SELECT room_type, COUNT(*)
FROM room
GROUP BY room_type
HAVING COUNT(*) > 1;

--Query 9: Use IN clause to select data from one or more tables
SELECT * FROM guest WHERE guest_id IN (SELECT guest_id FROM reservation);

--Query 10: Select length of one column from one table (use LENGTH function)
SELECT LENGTH(first_name) AS name_length FROM guest;

--Query 11: Delete one record from one table. Use select statements to demonstrate the table contents before and after the DELETE statement. Make sure you use ROLLBACK afterwards so that the data will not be physically removed 
-- Before DELETE
SELECT * FROM room_service;
-- Delete
DELETE FROM room_service
WHERE service_name = 'Breakfast';
-- After DELETE
SELECT * FROM room_service;
-- Rollback
ROLLBACK;


--Query 12: Update one record from one table. Use select statements to demonstrate the table contents before and after the UPDATE statement. Make sure you use ROLLBACK afterwards so that the data will not be physically removed
-- Before UPDATE
SELECT * FROM guest WHERE guest_id = 1002;
-- Update
UPDATE guest SET first_name = 'John' WHERE guest_id = 1002;
-- After UPDATE
SELECT * FROM guest WHERE guest_id = 1002;
-- Rollback
ROLLBACK;

--Query 13 (Advanced Queries): Retrieve the total revenue generated from room service for each guest
SELECT g.guest_id, g.first_name, g.last_name, COALESCE(SUM(rs.service_cost), 0) AS total_service_revenue
FROM guest g
LEFT JOIN reservation r ON g.guest_id = r.guest_id
LEFT JOIN room_service rs ON r.room_id = rs.room_id
GROUP BY g.guest_id, g.first_name, g.last_name;

--Query 14 (Advanced Queries): Retrieve the top 3 most popular room types based on the number of reservations
SELECT room_type, COUNT(*) AS reservations_count
FROM reservation r
JOIN room rm ON r.room_id = rm.room_id
GROUP BY room_type
ORDER BY reservations_count DESC
LIMIT 3;