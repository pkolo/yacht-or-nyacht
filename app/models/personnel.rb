class Personnel < ActiveRecord::Base
  has_many :credits
  has_many :songs, through: :credits, source: :creditable, source_type: 'Song'
  has_many :albums, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Song'
  has_many :album_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Song" }, class_name: 'Credit'
  has_many :album_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Album" }, class_name: 'Credit'

  after_create :create_slug

  def serializer(args=nil)
    if args[:basic]
      {
        id: self.id,
        name: self.name,
        resource_url: "/personnel/#{self.slug}",
        yachtski: self.yachtski
      }
    else
      {}
    end
  end

  def combined_song_credits
    combined_credits = self.song_credits.uniq.each_with_object([]) do |credit, memo|
      combined_credit = {
        media: credit.creditable,
        roles: self.song_credits.where(creditable_id: credit.creditable.id).pluck(:role)
      }
      memo << combined_credit
    end
    combined_credits.uniq {|c| c[:media]}
  end

  def combined_album_credits
    combined_credits = self.album_credits.each_with_object([]) do |credit, memo|
      combined_credit = {
        media: credit.creditable,
        roles: self.album_credits.where(creditable_id: credit.creditable.id).pluck(:role)
      }
      memo << combined_credit
    end
    combined_credits.uniq {|c| c[:media]}
  end

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

  def yachtski
      song_total = self.songs.uniq.inject(0) {|sum, song| sum + song.yachtski}
      album_total = self.albums.uniq.inject(0) {|sum, album| sum + album.yachtski}
      contribution_total = self.albums.uniq.length + self.songs.uniq.length

      contribution_total > 3 ? (song_total + album_total) / (contribution_total) : -1.0
  end

  def active_years
    chron_credits = self.credits.sort_by {|credit| credit.creditable.year }
    "#{chron_credits.first.creditable.year} - #{chron_credits.last.creditable.year}"
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
