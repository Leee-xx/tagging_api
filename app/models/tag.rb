class Tag < ApplicationRecord
  has_many :entities, :through => :entity_tag_assocations
end
