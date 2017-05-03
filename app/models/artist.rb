class Artist < ActiveRecord::Base
  has_many :songs
  has_many :albums

  def total_avg
    ((self.songs.inject(0) {|sum, song| sum + song.yachtski}) / self.songs.length.to_f).round(2)
  end
end
