class Personnel < ActiveRecord::Base
  has_many :credits
  has_many :songs, through: :credits, source: :creditable, source_type: 'Song'
  has_many :albums, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Song'
  has_many :album_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Album'
end
