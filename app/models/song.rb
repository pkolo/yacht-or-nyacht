class Song < ActiveRecord::Base
  belongs_to :episode
  belongs_to :artist
end
