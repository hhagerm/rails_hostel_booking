class RoomsController < ApplicationController
  before_action :set_room, only: %i[ show edit update destroy ]

  # GET /rooms or /rooms.json
  def index
    @start_date = parse_date(params[:start_date])
    @end_date = parse_date(params[:end_date])
    @guests = params[:guests].to_i
    @rooms = Room.order(:name)

    return if params[:start_date].blank? && params[:end_date].blank?

    if @start_date.nil? || @end_date.nil?
      flash.now[:alert] = "Please enter a valid check-in and check-out date."
    elsif @end_date <= @start_date
      flash.now[:alert] = "Your check-in has to be before your check-out."
    elsif @guests < 1
      flash.now[:alert] = "Number of guests has to be a positive number"
    elsif @start_date < Date.current
      flash.now[:alert] = "Your check-in cannot be in the past."
    else
      @rooms = free_rooms(@start_date, @end_date, @guests)
    end
  end

  # GET /rooms/1 or /rooms/1.json
  def show
    @reservations = @room.reservations.order(:start_date)
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms or /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: "Room was successfully created." }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @room.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /rooms/1 or /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: "Room was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @room.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /rooms/1 or /rooms/1.json
  def destroy
    if @room.destroy
      redirect_to rooms_path, notice: "Room was deleted.", status: :see_other
    else
      redirect_to @room, alert: @room.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def room_params
      params.expect(room: [ :name, :capacity ])
    end

    def parse_date(value)
      return nil if value.blank?

      begin
        Date.parse(value)
      rescue
        nil
      end
    end

    def free_rooms(start_date, end_date, guests)
      Room.order(:name).select { |room| room.free_bed_between?(start_date, end_date, guests) }
    end
end
