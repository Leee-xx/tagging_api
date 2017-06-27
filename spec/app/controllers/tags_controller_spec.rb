require 'rails_helper'
require 'byebug'

RSpec.describe TagsController, :type => :controller do
  let(:entity1) {
    tags = %w(one)
    eid = "abcd"
    do_add_tags(entity_type: "Article", entity_id: eid, tags: tags)
    Entity.where(external_id: eid).first
  }
  let(:entity2) {
    tags = %w(one two)
    eid = "abcd"
    do_add_tags(entity_type: "Product", entity_id: eid, tags: tags)
    Entity.where(external_id: eid).first
  }
  def do_add_tags(params, options = {})
    post :add_tags, params: params
    expect(response.code).to eql("204")
  end
  
  def do_get_tags(entity_type, entity_id, options = {})
    response_code = options["response_code"] || "200"
    get :get_tags, params: { entity_id: entity_id, entity_type: entity_type }
    expect(response.code).to eql(response_code)
    body = JSON.parse(response.body)
    if response_code == "200"
      expect(body["entity_id"]).to eql(entity_id)
      expect(body["entity_type"]).to eql(entity_type)
    else
      expect(body["errors"]).to be
    end
    return body
  end
  
  def do_delete_tags(entity_type, entity_id, options = {})
    response_code = options["response_code"] || "204"
    delete :delete, params: { entity_id: entity_id, entity_type: entity_type }
    expect(response.code).to eql(response_code)
    if response_code == "204"
      expect(response.body).to eql("")
    else
      body = JSON.parse(response.body)
      expect(body["errors"]).to be
    end
  end

  def do_get_all_stats
    get :get_all_stats
    expect(response.code).to eql("200")
    body = JSON.parse(response.body)
    expect(body).to be_a(Hash)
    expect(body['items']).to be
    expect(body['items']).to be_an(Array)
    body
  end
  
  def do_get_entity_stats(entity_type, external_id, options = {})
    response_code = options["response_code"] || "200"
    get :get_stats, params: { entity_id: external_id, entity_type: entity_type }
    expect(response.code).to eql(response_code)
    body = JSON.parse(response.body)
    if response_code == "200"
      entity = Entity.find_by(external_id: external_id, entity_type: entity_type)
      entity.tags.map(&:tag).each do |tag|
        stats = body.detect {|stat| stat['tag'] == tag}
        expect(stats).to be
        expect(stats['count']).to eql(1)
      end
    else
      expect(body["errors"]).to be
    end
  end
  
  describe "POST #create" do
     
     it "should respond successfully" do
        tags = %w(one)
        eid = "abcd"
        # Also creates a new Entity
        do_add_tags(entity_type: "Article", entity_id: eid, tags: tags)
        entity = Entity.where(external_id: eid).first
        expect(entity).to be
        expect(entity.tags.size).to eql(1)
        expect(entity.tags.first.tag).to eql("one")
        one_tag = entity.tags.first
        tags = %w(two three)
        do_add_tags(entity_type: "Article", entity_id: eid, tags: tags)
        entity.reload
        expect(entity.tags.size).to eql(2)
        expect(entity.tags).not_to include(one_tag)
        tag_names = entity.tags.map(&:tag)
        tags.each {|tag| expect(tag_names).to include(tag)}
     end
     
     it "should create distinct Entity objects if entity type is different" do
      tags = %w(one)
      eid = "abcd"
      type1 = "article"
      type2 = "product"
      do_add_tags(entity_type: type1, entity_id: eid, tags: tags)
      do_add_tags(entity_type: type2, entity_id: eid, tags: tags)
      entity_type1 = Entity.where(entity_type: type1, external_id: eid).first
      entity_type2 = Entity.where(entity_type: type2, external_id: eid).first
      expect(entity_type1).not_to equal(entity_type2)
     end
  end
  
  describe "GET #show" do
  
    it "should respond successfully" do
      response = do_get_tags(entity1.entity_type, entity1.external_id)
      expect(response["tags"].size).to eql(1)
      expect(response["tags"].first).to eql(entity1.tags.first.tag)
      tags = %w(two three)
      do_add_tags(entity_type: entity1.entity_type, entity_id: entity1.external_id, tags: tags)
      response = do_get_tags(entity1.entity_type, entity1.external_id)
      expect(response["tags"].size).to eql(2)
      tags.each {|tag| expect(response["tags"]).to include(tag) }
    end
    
    it "should respond with 404 if entity not found" do
      response = do_get_tags("foo", "bar", { "response_code" => "404" })
    end
  end
  
  describe "DELETE #delete" do
  
    it "should respond successfully" do
      external_id = entity1.external_id
      entity_type = entity1.entity_type
      tag_names = entity1.tags.map(&:tag)
      do_delete_tags(entity1.entity_type, entity1.external_id)
      entity = Entity.where(entity_type: entity_type, external_id: external_id).first
      expect(entity).to be_nil
      # Tags for other entities should not be affected
      expect(entity2.tags.size).to eql(2)
      tag_names_2 = entity2.tags.map(&:tag)
      expect(tag_names_2).to include("one", "two")
      #tag_names.each {|tag_name| expect(Tag.where(tag: tag_name).first).to be_nil}
    end
    
    it "should respond with 404 if entity not found" do
      response = do_delete_tags("foo", "bar", { "response_code" => "404" })
    end
  end
  
  describe "stats" do

    describe "GET #get_all_stats" do
      it "should return correct result" do
        expect(entity1).to be
        expect(entity2).to be
        response = do_get_all_stats()
        expect(response['total']).to eql(2)
        one_stats = response['items'].detect {|stats| stats['tag'] == 'one' }
        two_stats = response['items'].detect {|stats| stats['tag'] == 'two' }
        expect(one_stats).to be
        expect(one_stats['count']).to eql(2)
        expect(two_stats).to be
        expect(two_stats['count']).to eql(1)
      end

    end
    
    describe "GET #get_entity_stats" do
    
      it "should return correct results for an entity" do
        do_get_entity_stats(entity1.entity_type, entity1.external_id)
        do_get_entity_stats(entity2.entity_type, entity2.external_id)
      end
      
      it "should respond with 404 if entity not found" do
        response = do_get_entity_stats("foo", "bar", { "response_code" => "404" })
      end
    end
  end
end