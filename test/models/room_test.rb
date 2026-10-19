require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "should require capacity" do
    room = Room.new(name: "Test room")

    assert_not room.valid?
    assert room.errors.of_kind?(:capacity, :blank)
  end

  test "should require capacity to be positive int" do
    room = Room.new(name: "Test room", capacity: 0)

    assert_not room.valid?
    assert room.errors.of_kind?(:capacity, :greater_than)
  end

  test "should require capacity to a number" do
    room = Room.new(name: "Test room", capacity: "string")

    assert_not room.valid?
    assert room.errors.of_kind?(:capacity, :not_a_number)
  end

  test "should require capacity to an integer" do
    room = Room.new(name: "Test room", capacity: 2.5)

    assert_not room.valid?
    assert room.errors.of_kind?(:capacity, :not_an_integer)
  end

  test "should require name" do
    room = Room.new(capacity: 5)

    assert_not room.valid?
    assert room.errors.of_kind?(:name, :blank)
  end

  test "should require name to be hundred or less chars" do
    room = Room.new(name: "a" * 101,  capacity: 5)

    assert_not room.valid?
    assert room.errors.of_kind?(:name, :too_long)
  end

  test "name isn't case sensitive" do
    Room.create!(name: "test", capacity: 5)

    new_room = Room.new(name: "TEST", capacity: 5)
    assert_not new_room.valid?
    assert new_room.errors.of_kind?(:name, :taken)
  end

  test "should be valid" do
    room = Room.new(name: "test", capacity: 1)

    assert room.valid?
  end
end
