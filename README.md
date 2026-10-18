# Hostel Booking App

A small Ruby on Rails app for booking beds in hostel rooms.
Guests can search for rooms with a free bed for their dates and book one. Every booking is checked
so that no room is ever overbooked on any night, including when two people book at the same time.

**Stack:** Ruby 3.4, Rails 8.1, MySQL

![Tests](https://github.com/hhagerm/rails_hostel_booking/actions/workflows/ci.yml/badge.svg)

## Setup:

1. Clone the repository:

```bash
   git clone https://github.com/hhagerm/rails_hostel_booking.git
   cd rails_hostel_booking
```

2. Install dependencies:

```bash
   bundle install
```

3. Configure the database connection. By default the app connects as MySQL `root` with no password
   on `127.0.0.1`. If your setup differs, create a `.env` file and fill in your credentials:

```bash
   cp .env.example .env
   # then edit .env: DB_USERNAME, DB_PASSWORD (and DB_HOST if needed)
```

   Alternatively, pass a connection URL directly:
   `DATABASE_URL=mysql2://user:password@127.0.0.1 bin/rails db:setup`

4. Create the database, load the schema and seed sample data:

```bash
   bin/rails db:setup
```

5. Start the server and open http://localhost:3000:

```bash
   bin/rails server
```

6. Run the tests:

```bash
   bin/rails test
```
## Theme:

I chose a booking system for hostels. I originally thought about hotels, but a hotel room only ever has one
reservation at a time, so the capacity check would be trivial. In a hostel dorm, each reservation takes one bed,
and a room's capacity is its number of beds.

## Decisions:

> **AI Usage:** The CSS/HTML layout and the seed data were written with AI.

- **Check-in in the evening, check-out in the morning.** So a guest can check in on the same day the previous
  guest checks out: the check-out day doesn't count as a night.
- **Logic lives in the models.** Controllers only ask the models for the data they need.
- **One availability check.** `Room#free_bed_between?` is used both by the date search and by the reservation
  validation, so the search and the booking can't disagree. The search result is only a hint; the final check
  happens when the reservation is saved.
- **Editing a reservation** doesn't count the reservation itself when checking capacity.
- **Check-in can't be in the past**, but only for new reservations or when the check-in date changes,
  so an ongoing stay can still be extended.
- **Validations and database constraints.** The validations mirror the database schema: they give the user
  a readable error message in the form, while the database constraints (NOT NULL, unique room name,
  foreign key) are the last line of defense.
- **Locking against race conditions.** When checking whether a new reservation fits, I lock the room's row.
  This prevents two simultaneous bookings from both seeing a free bed and overbooking the room. The query for
  overlapping reservations is a locking read too, so after waiting for the lock it also sees the reservation
  that was just saved.
- **A room with reservations can't be deleted**, so guests' bookings are never lost silently.
  The user gets a message instead.
- **N+1 queries** are avoided with `includes(:room)` on the reservations list. The date search checks
  rooms one by one, which is fine for the handful of rooms a hostel has.
- **Tests:** model tests for the capacity edge cases (overlapping, full night, editing, back-to-back stays)
  and controller tests.
  
## Why the capacity check works:

- A reservation needs a free bed on **every night** of its stay.
- So for each night of the new stay, the check counts the guests already staying that night.
- If any night is already at capacity, the reservation is rejected.

> Counting all overlapping reservations wouldn't work: two guests can each overlap the new stay on different nights, without ever needing a bed at the same time.

## With more time, I would:

- add login and a guest model
- add a hostel model, so multiple hostels could use this booking service
- add temporary holds during checkout, so a guest has a guarantee their bed isn't taken before they complete the booking
- allow one reservation for more than one person
- schedule room deletion: the room stops accepting new bookings and is deleted after all its reservations are completed
- delete old reservations from the table (possibly move them to a separate table for statistics)
- add validation when lowering a room's capacity below existing bookings
