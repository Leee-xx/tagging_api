class TagsController < ApplicationController  
  def add_tags
    params.permit(:entity_id, :entity_type)
    entity = Entity.where(external_id: params['entity_id'], entity_type: params['entity_type']).first_or_create
    entity.set_tags(params['tags'])
    head :no_content, status: "204"
  end
  
  def get_tags
    entity = get_entity()
    
    resp = {
      entity_id: entity.external_id,
      entity_type: entity.entity_type,
      tags: entity.tags.map(&:tag)
    }
    render json: resp.to_json
  end
  
  def delete
    entity = get_entity()  
    entity.entity_tag_associations.each {|eta| eta.try(:destroy)}
    entity.destroy
    head :no_content, status: "204"
  end
  
  def get_all_stats
    params.permit(:limit, :offset, :sort_key, :ascending)
    limit = params['limit'] || -1
    offset = params['offset'] || 0
    sort_key = params['sort_key'] || "tag"
    ascending = params['ascending'] || 'true'
    
    num_tags = Tag.count
    resp = {
      items: [],
      total: num_tags,
      limit: limit,
      offset: offset,
      sort_key: sort_key,
      ascending: ascending,
    }
    
    case sort_key
      when "count"
        sort_key = "count_all"
      when "tag"
        sort_key = "tags.tag"
    end
    case ascending
      when 'true'
        ascending = "ASC"
      when 'false'
        ascending = "DESC"
    end
    
    tags = EntityTagAssociation.joins(:tag).group("tags.tag").order("#{sort_key} #{ascending}").limit(limit).offset(offset).count
    
    tags.each {|tag, cnt| resp[:items] << { tag: tag, count: cnt} }
    render json: resp.to_json
  end
  
  def get_stats
    entity = get_entity()
    resp = []
    entity.tags.each {|tag| resp << { tag: tag.tag, count: 1 } }
    render json: resp
  end
  
  protected
  
    def get_entity
      Entity.includes(:tags).find_by!(external_id: params['entity_id'], entity_type: params['entity_type'])
    end
    
    
  
end
