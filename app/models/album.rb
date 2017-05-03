class Album < ActiveRecord::Base
  belongs_to :artist
  has_many :songs
  has_many :credits, as: :creditable

  def avg_yachtski
    total_pts = self.songs.inject(0) { |sum, song| sum += song.yachtski }
    (total_pts / self.songs.length)
  end
end
