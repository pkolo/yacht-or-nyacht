class Artist < ActiveRecord::Base
  has_many :songs

  def total_avg
    (self.songs.inject(0) {|sum, song| sum + song.yachtski}) / self.songs.length.to_f
  end
end
