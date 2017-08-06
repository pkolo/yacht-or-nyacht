require_relative '../serializers/album_serializers'
require_relative '../serializers/creditable_serializers'

class Album < ActiveRecord::Base
  include AlbumSerializers
  include CreditableSerializers

  has_many :songs, after_add: :write_yachtski
  has_many :credits, as: :creditable, dependent: :destroy do
    def player_credits
      where("role != ?", "Artist")
    end

    def artist_credits
      where 'role IN (?)', ["Artist"]
    end
  end
  has_many :performers, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :personnel
  after_create :create_slug

  def players
    query = <<-SQL
      SELECT p.id, p.name, p.yachtski, p.slug, string_agg(c.role, ', ') AS roles
      FROM personnels p JOIN credits c ON p.id=c.personnel_id
      WHERE c.creditable_id=#{self.id} AND c.creditable_type='Album' AND c.role NOT IN ('Artist', 'Duet', 'Featuring')
      GROUP BY p.id
      ORDER BY p.yachtski DESC
      SQL
    ActiveRecord::Base.connection.execute(query)
  end

  def get_yachtski
    self.songs.sum(:yachtski) / self.songs.count
  end

  def write_yachtski
    self.yachtski = self.get_yachtski
    self.save
  end

  def self.match_in(results)
    result_ids = results.map {|result| result["id"].to_s}
    self.where(discog_id: result_ids).first
  end

  private
    def create_slug
      self.slug = sluggify(self.title, self.id)
      self.save
    end

end
