class Entity < ApplicationRecord
  has_many :entity_tag_associations
  has_many :tags, :through => :entity_tag_associations
  
  def set_tags(tags_to_set = [])
    if self.entity_tag_associations.any?
      self.entity_tag_associations.each {|eta| eta.destroy}
    end
    tags_to_set.each do |tag_str|
      tag = Tag.where(tag: tag_str).first_or_create
      self.entity_tag_associations.create!(
        tag_id: tag.id,
        entity_id: self.id
      )
    end
  end
end
