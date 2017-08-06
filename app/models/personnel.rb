require_relative '../serializers/creditable_serializers'
require_relative '../serializers/personnel_serializers'

class Personnel < ActiveRecord::Base
  include PersonnelSerializers
  include CreditableSerializers

  has_many :credits
  has_many :songs, through: :credits, source: :creditable, source_type: 'Song'
  has_many :albums, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Song'
  has_many :album_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Album'

  # has_many :song_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Song" }, class_name: 'Credit'
  # has_many :album_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Album" }, class_name: 'Credit'

  default_scope { order(yachtski: :desc) }

  after_create :create_slug

  # Returns a PG object with creditable ID and type with combined credit roles.
  def credits_for(table)
    query = <<-SQL
      SELECT #{table}.id, c.creditable_type AS type, string_agg(c.role, ', ') AS roles
      FROM #{table}
      JOIN credits c ON c.creditable_id=#{table}.id AND c.creditable_type=\'#{table[0..-2].capitalize}\'
      WHERE c.personnel_id=#{self.id} AND c.role NOT IN ('Artist', 'Duet', 'Featuring')
      GROUP BY #{table}.id, c.creditable_type
      ORDER BY #{table}.yachtski DESC
    SQL
    ActiveRecord::Base.connection.execute(query)
  end

  def get_yachtski
      song_total = self.songs.uniq.inject(0) {|sum, song| sum + song.yachtski}
      album_total = self.albums.uniq.inject(0) {|sum, album| sum + album.yachtski}
      contribution_total = self.albums.uniq.length + self.songs.uniq.length

      contribution_total > 3 ? (song_total + album_total) / (contribution_total) : -1.0
  end

  def write_yachtski
    self.yachtski = self.get_yachtski
    self.save
  end

  def self.name_search(query)
    self.where("similarity(name, ?) > 0.3", query).order("similarity(name, ?) DESC", ActiveRecord::Base.connection.quote(query))
  end

  private
    def create_slug
      self.slug = sluggify(self.name, self.id)
      self.save
    end

end
