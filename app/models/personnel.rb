class Personnel < ActiveRecord::Base
  has_many :credits
  has_many :songs, through: :credits, source: :creditable, source_type: 'Song'
  has_many :albums, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Song'
  has_many :album_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Song" }, class_name: 'Credit'
  has_many :album_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Album" }, class_name: 'Credit'
end
