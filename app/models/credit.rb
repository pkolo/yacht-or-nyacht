class Credit < ActiveRecord::Base
  belongs_to :personnel
  belongs_to :creditable, polymorphic: true

end
