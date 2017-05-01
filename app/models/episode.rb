class Episode < ActiveRecord::Base
  has_many :songs

  validates :number, uniqueness: true

end
