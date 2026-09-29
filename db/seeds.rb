# Sample data for trying out the app.
# Dates are relative to today, so the seeds never create reservations in the past
# (which the validations would reject).
# Run with: rails db:setup (fresh DB) or rails db:seed (re-run; existing data is cleared).

Reservation.delete_all
Room.delete_all

d = Date.current + 7 # all bookings start a week from today

dorm4   = Room.create!(name: "4-bed mixed dorm", capacity: 4)
dorm8   = Room.create!(name: "8-bed mixed dorm", capacity: 8)
female6 = Room.create!(name: "6-bed female dorm", capacity: 6)
twin    = Room.create!(name: "Twin room", capacity: 2)
private = Room.create!(name: "Private double", capacity: 1)

book = ->(room, guest, from, nights) do
  room.reservations.create!(guest_name: guest, start_date: d + from, end_date: d + from + nights)
end

# 4-bed dorm: nearly full.
# Guests per night: d: 2, d+1: 3, d+2: 4 (FULL), d+3: 1
book.(dorm4, "Fauna Veva", 0, 3)
book.(dorm4, "Kason Giselbert", 0, 3)
book.(dorm4, "Cara Müller", 1, 3)
book.(dorm4, "Dubravka Ashanti", 2, 1)
# Try: d+1 → d+2 succeeds (last bed), d+1 → d+3 fails (night d+2 is full).

# Twin room: two stays that overlap a long booking but not each other.
# A new booking d → d+3 still fits (never more than 2 guests on any night).
book.(twin, "Cletus Gustavs", 0, 1)
book.(twin, "Celeste Sridevi", 2, 1)

# Private double (1 bed): back-to-back stays.
# Check-out day is not a night, so Hana can check in the day Gustav leaves.
book.(private, "Lars Joop", 0, 2)
book.(private, "Loretta Isla", 2, 2)

# 8-bed dorm and female dorm: some ordinary bookings.
book.(dorm8, "Bakyt Ottar", 0, 5)
book.(dorm8, "Jaromir Iudgual", 3, 2)
book.(female6, "Ángela Wilhelmina", 1, 4)
book.(female6, "Laura Chen", 1, 2)

puts "Seeded #{Room.count} rooms and #{Reservation.count} reservations (bookings start #{d})."
