class Episode < ActiveRecord::Base
  has_many :songs

  validates :number, uniqueness: true

  def title
    if self.number.match('YON')
      self.number.gsub('YON', 'Yacht Or Nyacht #')
    else
      self.number.gsub('BYR', 'Beyond Yacht Rock #')
    end
  end

end
