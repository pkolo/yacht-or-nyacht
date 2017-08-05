class Credit < ActiveRecord::Base
  belongs_to :personnel
  belongs_to :creditable, polymorphic: true

  after_create :update_personnel_yachtski

  def update_personnel_yachtski
    self.personnel.write_yachtski
  end
end
