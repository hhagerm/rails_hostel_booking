class Reservation < ApplicationRecord
  belongs_to :room

  validates :guest_name, :start_date, :end_date, presence: true
  validates :guest_name, length: { maximum: 100 }
  validate :end_date_after_start_date
  validate :start_date_not_in_past
  validate :room_has_free_bed

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "must be after check-in date")
    end
  end

  def start_date_not_in_past
    return if start_date.blank?

    return unless new_record? || start_date_changed?

    if Date.current > start_date
      errors.add(:start_date, "cannot be in the past")
    end
  end

  def room_has_free_bed
    return if room.blank? || start_date.blank? || end_date.blank?

    room.lock!

    overlapping = Reservation.where(room_id: room_id)
      .where("start_date < ? AND ? < end_date", end_date, start_date)
      .where.not(id: id)
      .lock

    guests_per_night = (start_date...end_date).map do |night|
      overlapping.count do |overlap|
        overlap["start_date"] <= night && night < overlap["end_date"]
      end
    end

    if guests_per_night.any? { |guests| guests >= room.capacity }
      errors.add(:base, "no free bed for the selected dates")
    end
  end
end
