set search_path to hotel_db;



/*DROP statements to clean up objects from previous run*/
--Triggers
DROP TRIGGER IF EXISTS set_billing_date ON billing_records;
DROP TRIGGER IF EXISTS update_room_availability ON reservation;
DROP TRIGGER IF EXISTS generate_reservation_id ON reservation;

--Sequences
DROP SEQUENCE IF EXISTS reservation_id_seq;
DROP SEQUENCE IF EXISTS guest_id_seq;
DROP SEQUENCE IF EXISTS billing_id_seq;
DROP SEQUENCE IF EXISTS room_id_seq;
DROP SEQUENCE IF EXISTS room_service_id_seq;

--Views
DROP VIEW IF EXISTS reservation_details;
DROP VIEW IF EXISTS room_availability;
DROP VIEW IF EXISTS total_billed_amount;
DROP VIEW IF EXISTS guest_reservations;

--Indices
DROP INDEX IF EXISTS idx_guest_guest_id;
DROP INDEX IF EXISTS idx_guest_last_name;

DROP INDEX IF EXISTS idx_reservation_reservation_id;
DROP INDEX IF EXISTS idx_reservation_check_in_date;
DROP INDEX IF EXISTS idx_reservation_check_out_date;
DROP INDEX IF EXISTS idx_reservation_guest_id_fk_pk;

DROP INDEX IF EXISTS idx_billing_records_payment_method;
DROP INDEX IF EXISTS idx_billing_records_billing_date;
DROP INDEX IF EXISTS idx_billing_records_reservation_id_fk;

DROP INDEX IF EXISTS idx_room_room_id;
DROP INDEX IF EXISTS idx_room_room_no;
DROP INDEX IF EXISTS idx_room_availability;
DROP INDEX IF EXISTS idx_room_reservation_id_fk;

DROP INDEX IF EXISTS idx_room_service_service_name;
DROP INDEX IF EXISTS idx_room_service_service_payment_status;
DROP INDEX IF EXISTS idx_room_service_room_id_fk;


--Tables
DROP TABLE guest CASCADE;
DROP TABLE reservation CASCADE;
DROP TABLE billing_records CASCADE;
DROP TABLE room CASCADE;
DROP TABLE room_service CASCADE;

/*Create tables  based on entities*/
create table guest (
	guest_id int primary key,
	first_name varchar(255),
	last_name varchar(255),
	phone_no varchar(20),
	email varchar(255),
	guest_address varchar(255)
);

create table reservation (
	reservation_id int primary key,
	guest_id int,
	room_id int,
	billing_id int,
	check_in_date date,
	check_out_date date,
	number_of_guests int,
	status varchar(50),
	foreign key (guest_id) references guest(guest_id)
);

create table billing_records (
    billing_id serial primary key,
    reservation_id int,
    total_amount numeric(10, 2),
    payment_method varchar(50),
    billing_date date,
    billing_address varchar(255),
    foreign key (reservation_id) references reservation(reservation_id)
);


create table room (
    room_id serial primary key,
    room_no varchar(20),
    room_type varchar(50),
    capacity int,
    availability varchar(20),
    reservation_id int,
    foreign key (reservation_id) references reservation(reservation_id)
);


create table room_service (
    service_id serial primary key,
    service_name varchar(100),
    service_cost numeric(10, 2),
    service_payment_status varchar(20),
    service_description text,
    room_id int,
    foreign key (room_id) references room(room_id)
);


/*Create indices for natural keys, foreign keys, and frequently- queried columns*/
--Guest
CREATE INDEX idx_guest_guest_id ON guest(guest_id);
CREATE INDEX idx_guest_last_name ON guest(last_name);

--Reservation
CREATE INDEX idx_reservation_reservation_id ON reservation(reservation_id);
CREATE INDEX idx_reservation_check_in_date ON reservation(check_in_date);
CREATE INDEX idx_reservation_check_out_date ON reservation(check_out_date);
CREATE INDEX idx_reservation_guest_id_fk_pk ON reservation(guest_id);

--Billing_records
CREATE INDEX idx_billing_records_payment_method ON billing_records(payment_method);
CREATE INDEX idx_billing_records_billing_date ON billing_records(billing_date);
CREATE INDEX idx_billing_records_reservation_id_fk ON billing_records(reservation_id);

--Room
CREATE INDEX idx_room_room_id ON room(room_id);
CREATE INDEX idx_room_room_no ON room(room_no);
CREATE INDEX idx_room_availability ON room(availability);
CREATE INDEX idx_room_reservation_id_fk ON room(reservation_id);

--Room_service
CREATE INDEX idx_room_service_service_name ON room_service(service_name);
CREATE INDEX idx_room_service_service_payment_status ON room_service(service_payment_status);
CREATE INDEX idx_room_service_room_id_fk ON room_service(room_id);


/*Alter table by adding audit tables*/
ALTER TABLE guest 
ADD COLUMN created_by    VARCHAR(30),
ADD COLUMN date_created  DATE,
ADD COLUMN modified_by   VARCHAR(30),
ADD COLUMN date_modified DATE;

ALTER TABLE reservation 
ADD COLUMN created_by    VARCHAR(30),
ADD COLUMN date_created  DATE,
ADD COLUMN modified_by   VARCHAR(30),
ADD COLUMN date_modified DATE;

ALTER TABLE billing_records 
ADD COLUMN created_by    VARCHAR(30),
ADD COLUMN date_created  DATE,
ADD COLUMN modified_by   VARCHAR(30),
ADD COLUMN date_modified DATE;

ALTER TABLE room
ADD COLUMN created_by    VARCHAR(30),
ADD COLUMN date_created  DATE,
ADD COLUMN modified_by   VARCHAR(30),
ADD COLUMN date_modified DATE;

ALTER TABLE room_service 
ADD COLUMN created_by    VARCHAR(30),
ADD COLUMN date_created  DATE,
ADD COLUMN modified_by   VARCHAR(30),
ADD COLUMN date_modified DATE;

-- Views

--Reservation details view
CREATE OR REPLACE VIEW reservation_details AS
SELECT r.reservation_id, g.first_name || ' ' || g.last_name AS guest_name, r.check_in_date, r.check_out_date,
       rm.room_no, rm.room_type, rm.capacity, rm.availability,
       b.total_amount, b.payment_method, b.billing_date
FROM reservation r
JOIN guest g ON r.guest_id = g.guest_id
JOIN room rm ON r.room_id = rm.room_id
JOIN billing_records b ON r.billing_id = b.billing_id;

-- Room Availability View
CREATE OR REPLACE VIEW room_availability AS
SELECT room_no, room_type, availability
FROM room;

-- Create view for total billed amount including room service
CREATE VIEW total_billed_amount AS (
	SELECT
		r.reservation_id,
		r.check_in_date,
		r.check_out_date,
		r.number_of_guests,
		b.total_amount AS room_bill,
		COALESCE(SUM(rs.service_cost), 0) AS room_service_bill,
		b.total_amount + COALESCE(SUM(rs.service_cost), 0) AS total_billed_amount
	FROM
		reservation r
	LEFT JOIN
		billing_records b ON r.reservation_id = b.reservation_id
	LEFT JOIN
		room_service rs ON r.room_id = rs.room_id
	GROUP BY
		r.reservation_id, r.check_in_date, r.check_out_date, r.number_of_guests, b.total_amount
);

-- Create view for guest reservations
CREATE VIEW guest_reservations AS
SELECT
    g.first_name || ' ' || g.last_name AS guest_name,
    r.check_in_date,
    r.check_out_date,
    ro.room_no
FROM
    guest g
JOIN
    reservation r ON g.guest_id = r.guest_id
JOIN
    room ro ON r.room_id = ro.room_id;
	

/* CREATE ITEMS */
-- Sequences
CREATE SEQUENCE guest_id_seq
  START WITH 1001
  INCREMENT BY 1
  MAXVALUE 9999
  CYCLE;

CREATE SEQUENCE reservation_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 9999
  CYCLE;

CREATE SEQUENCE billing_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 9999
  CYCLE;

CREATE SEQUENCE room_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 9999
  CYCLE;

CREATE SEQUENCE room_service_id_seq
  START WITH 1
  INCREMENT BY 1
  MAXVALUE 9999
  CYCLE;


-- Triggers

-- Create Trigger for unique reservation_id
CREATE OR REPLACE FUNCTION generate_reservation_id()
RETURNS TRIGGER AS $$
BEGIN
  SELECT nextval('reservation_id_seq') INTO NEW.reservation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_reservation_id
BEFORE INSERT ON reservation
FOR EACH ROW
EXECUTE FUNCTION generate_reservation_id();

-- Create Trigger to set billing_date to current date
CREATE OR REPLACE FUNCTION set_billing_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.billing_date := CURRENT_DATE;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_billing_date
BEFORE INSERT ON billing_records
FOR EACH ROW
EXECUTE FUNCTION set_billing_date();

-- Create Trigger to update room availability
CREATE OR REPLACE FUNCTION update_room_availability()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Reservation is confirmed, set room availability to occupied
    UPDATE room
    SET availability = 'occupied'
    WHERE room_id = NEW.room_id;
  ELSIF TG_OP = 'DELETE' THEN
    -- Reservation is canceled, set room availability to unoccupied
    UPDATE room
    SET availability = 'unoccupied'
    WHERE room_id = OLD.room_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_room_availability
AFTER INSERT OR DELETE ON reservation
FOR EACH ROW
EXECUTE FUNCTION update_room_availability();


