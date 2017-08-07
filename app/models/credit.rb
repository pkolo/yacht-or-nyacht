class Credit < ActiveRecord::Base
  belongs_to :personnel
  belongs_to :creditable, polymorphic: true

  scope :artist, -> { where 'role IN (?)', ["Artist"] }
  scope :feature, -> { where 'role IN (?)', ["Duet", "Featuring"] }
  scope :player, -> { where 'role NOT IN (?)', ["Artist", "Duet", "Featuring"]}
end
