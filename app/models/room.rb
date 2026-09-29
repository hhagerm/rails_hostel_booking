class Room < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def free_bed_between?(start_date, end_date)
    overlapping = reservations
      .where("start_date < ? AND ? < end_date", end_date, start_date)
      .to_a

    guests_per_night = (start_date...end_date).map do |night|
      overlapping.count do |overlap|
        overlap.start_date <= night && night < overlap.end_date
      end
    end

    guests_per_night.all? { |guests| guests < capacity }
  end
end
