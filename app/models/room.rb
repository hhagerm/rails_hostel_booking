class Room < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def free_bed_between?(start_date, end_date, guests = 1, except_id: nil, lock: false)
    overlapping = reservations
      .where("start_date < ? AND ? < end_date", end_date, start_date)
      .where.not(id: except_id)
    overlapping = overlapping.lock if lock
    overlapping = overlapping.to_a

    guests_per_night = (start_date...end_date).map do |night|
      overlapping.sum do |overlap|
        if overlap.start_date <= night && night < overlap.end_date
          overlap.guests
        else
          0
        end
      end
    end

    guests_per_night.all? { |occupied| occupied + guests <= capacity }
  end
end
