class CreateEntityTagAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :entity_tag_associations do |t|
      t.belongs_to :entity, index: true
      t.belongs_to :tag, index: true
      t.timestamps
    end
  end
end
