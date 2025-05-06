# Hotel Database System – Express Suites

This project is a complete relational database system for the “Express Suites” hotel, designed using PostgreSQL. It models core hotel operations including guest reservations, room services, billing, and availability. 

---

## Project Structure

- `docs/`: Project documentation and ER diagram
- `scripts/`: SQL scripts for database schema (DDL) and data population (DML)
- `README.md`: Project overview and setup

---

## Database Overview

- **Entities**: Guest, Reservation, Room, Billing Records, Room Service
- **Views**: Reservation details, Room availability, Guest reservations, Total billed amount
- **Triggers & Sequences**: Auto-generated IDs, auto-billing date, room availability updates
- **Security**: Multi-tier access system and role-based control
- **DBMS**: PostgreSQL 15

---

## Features

- Tracks guest check-ins, check-outs, room bookings, and billing.
- Maintains service usage and cost.
- Provides analytics on total revenue, popular room types, and guest activity.
- Implements layered security and audit trails.

---

## Getting Started

### Prerequisites

- PostgreSQL 15
- pgAdmin or any SQL execution environment

### Steps

1. Create a schema named `hotel_db`.
2. Run the script in `scripts/DDL_Group13.sql` to build the schema.
3. Execute `scripts/DML_Group13.sql` to populate sample data.
4. Explore views and run custom queries as needed.

