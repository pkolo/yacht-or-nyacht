class Personnel < ActiveRecord::Base
  has_many :credits
  has_many :songs, through: :credits, source: :creditable, source_type: 'Song'
  has_many :albums, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Song'
  has_many :album_performances, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :creditable, source_type: 'Album'

  has_many :song_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Song" }, class_name: 'Credit'
  has_many :album_credits, ->(credit) { where 'credits.role != ? AND credits.creditable_type = ?', "Artist", "Album" }, class_name: 'Credit'

  def combined_song_credits
    combined_credits = self.song_credits.uniq.each_with_object([]) do |credit, memo|
      combined_credit = {
        media: credit.creditable,
        roles: self.song_credits.where(creditable_id: credit.creditable.id).pluck(:role)
      }
      memo << combined_credit
    end
    combined_credits.uniq
  end

  def combined_album_credits
    combined_credits = self.album_credits.each_with_object([]) do |credit, memo|
      combined_credit = {
        media: credit.creditable,
        roles: self.album_credits.where(creditable_id: credit.creditable.id).pluck(:role)
      }
      memo << combined_credit
    end
    combined_credits.uniq
  end

end
