require_relative '../serializers/episode_serializers'

class Episode < ActiveRecord::Base
  include EpisodeSerializers

  has_many :songs

  validates :number, uniqueness: true

  def title
    if self.number.match('YON')
      self.number.gsub('YON', 'Yacht Or Nyacht #')
    elsif self.number.match('BRC')
      self.number.gsub('BRC', 'Beyond Yacht Rock Record Club #')
    else
      self.number.gsub('BYR', 'Beyond Yacht Rock #')
    end
  end

end
