class Album < ActiveRecord::Base
  has_many :songs
  has_many :credits, as: :creditable do
    def players
      where("role != ?", "Artist")
    end
  end
  has_many :performers, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :personnel
  after_create :create_slug

  def artist_list
    artist_data = self.performers.pluck(:id, :name)
    artist_data.map { |data| "<a href='/personnel/#{data[0]}'>#{data[1]}</a>"}.join(", ")
  end

  def yachtski
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
        personnel: credits.map { |credit| "<a href='/personnel/#{credit.personnel.slug}'>#{credit.personnel.name}</a>" }
      }
      memo << players
    end
  end

  def personnel_combined_roles
    # Combine players by name, combine their roles
    personnel = self.credits.players.each_with_object([]) do |credit, memo|
      combined_roles = {
        personnel: credit.personnel,
        roles: self.credits.players.where(personnel_id: credit.personnel.id).pluck(:role)
      }
      memo << combined_roles
    end
    personnel.uniq
  end

  private
    def create_slug
      self.slug = sluggify(self.title, self.id)
      self.save
    end

end
