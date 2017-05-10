class Album < ActiveRecord::Base
  has_many :songs
  has_many :credits, as: :creditable do
    def players
      where("role != ?", "Artist")
    end
  end
  has_many :performers, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :personnel

  def artist_list
    self.performers.pluck(:name).uniq.join(', ')
  end

  def avg_yachtski
    total_pts = self.songs.inject(0) { |sum, song| sum += song.yachtski }
    (total_pts / self.songs.length)
  end

  def self.match_in(results)
    result_ids = results.map {|result| result["id"].to_s}
    self.where(discog_id: result_ids).first
  end

  def combined_players
    roles = self.credits.players.pluck(:role).uniq
    roles.each_with_object([]) do |role, memo|
      credits = self.credits.players.where(role: role)

      players = {
        role: role,
        personnel: credits.map { |credit| credit.personnel.name }
      }
      memo << players
    end
  end
end
