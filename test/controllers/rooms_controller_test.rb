require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room = rooms(:dorm)
  end

  test "should get index" do
    get rooms_url
    assert_response :success
  end

  test "should get new" do
    get new_room_url
    assert_response :success
  end

  test "should create room" do
    assert_difference("Room.count") do
      post rooms_url, params: { room: { capacity: @room.capacity, name: "new_room" } }
    end

    assert_redirected_to room_url(Room.last)
  end

  test "should show room" do
    get room_url(@room)
    assert_response :success
  end

  test "should get edit" do
    get edit_room_url(@room)
    assert_response :success
  end

  test "should update room" do
    patch room_url(@room), params: { room: { capacity: @room.capacity, name: @room.name } }
    assert_redirected_to room_url(@room)
  end

 test "should destroy room without reservations" do
    empty = rooms(:empty)
    assert_difference("Room.count", -1) do
      delete room_url(empty)
    end
    assert_redirected_to rooms_url
  end

  test "should not destroy room with reservations" do
    puts "deleting #{@room.name}, reservations: #{@room.reservations.count}"
    assert_no_difference("Room.count") do
      delete room_url(@room)
    end
    assert_redirected_to room_url(@room)
  end
end
