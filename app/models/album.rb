class Album < ActiveRecord::Base
  has_many :songs
  has_many :credits, as: :creditable
end
