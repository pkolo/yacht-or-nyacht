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

  has_many :song_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Song" }, class_name: 'Credit'
  has_many :album_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Album" }, class_name: 'Credit'

  default_scope { order(yachtski: :desc) }

  after_create :create_slug
  after_create :write_yachtski

  def all_song_albums
    song_albums = self.songs.map {|song| song.album}.uniq
    (song_albums + self.albums.uniq).uniq
  end

  def yachtski_songs
    total = self.songs.uniq.inject(0) {|sum, song| sum + song.yachtski}
    total / self.songs.uniq.length
  end

  def yachtski_albums
    total = self.albums.uniq.inject(0) {|sum, album| sum + album.yachtski}
    total / self.albums.uniq.length
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
    self.where("similarity(name, ?) > 0.3", query).order("similarity(name, #{ActiveRecord::Base.connection.quote(query)}) DESC")
  end

  private
    def create_slug
      self.slug = sluggify(self.name, self.id)
      self.save
    end

end
