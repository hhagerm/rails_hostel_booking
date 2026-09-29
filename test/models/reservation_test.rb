require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  setup do
    @d = Date.current + 30
    @room = Room.create!(name: "Twin test room", capacity: 2)
    @room.reservations.create!(guest_name: "Ana", start_date: @d, end_date: @d + 1)
    @room.reservations.create!(guest_name: "Ben", start_date: @d + 2, end_date: @d + 3)
  end

  test "should allow a stay spanning two non-overlapping bookings" do
    reservation = @room.reservations.new(guest_name: "John", start_date: @d, end_date: @d + 3)

    assert reservation.valid?, reservation.errors.full_messages.to_sentence
  end

  test "should report a free bed for the spanning stay" do
    reservation = @room.reservations.new(guest_name: "John", start_date: @d, end_date: @d + 3)

    assert @room.free_bed_between?(reservation[:start_date], reservation[:end_date])
  end

  test "should reject a stay when one of its nights is full" do
    @room.reservations.create!(guest_name: "John", start_date: @d, end_date: @d + 3)
    reservation = @room.reservations.new(guest_name: "Patrick", start_date: @d, end_date: @d + 3)


    assert_not reservation.valid?
    assert_includes reservation.errors[:base], "No free bed for the selected dates"
  end

  test "should not count itself when editing a reservation in a full room" do
    reservation = @room.reservations.create!(guest_name: "John", start_date: @d, end_date: @d + 1)

    # precondition: the night of @d is full (Anna + John)
    assert_not @room.free_bed_between?(@d, @d + 1)

    assert reservation.update(end_date: @d + 3), reservation.errors.full_messages.to_sentence
    assert_equal @d + 3, reservation.reload.end_date
  end

  test "should allow check-in on another guest's check-out day" do
    @room.reservations.create!(guest_name: "John", start_date: @d, end_date: @d + 3)
    reservation = @room.reservations.new(guest_name: "Patrick", start_date: @d + 3, end_date: @d + 4)

    assert reservation.valid?, reservation.errors.full_messages.to_sentence
  end
end
