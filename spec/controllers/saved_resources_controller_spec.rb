require 'spec_helper'

describe SavedResourcesController do

  describe "#create" do

    context "Good data" do
      it "should create a member in MongoDB" do
        expect {xhr :post, :create, get_valid_member_with_resource}.to change(Member, :count).by(1)
      end

      it "should create a member with member_id 1 and with resource 123" do
        xhr :post, :create, get_valid_member_with_resource
        member = assigns(:member)
        member.member_id.should == 1
        member.saved_resources[0].resource_id.should == "123"
      end
    end

    context "Bad data" do
      it "should not create a member given invalid arguments" do
        expect {xhr :post, :create, get_valid_member_with_resource([:member_id])}.to change(Member, :count).by(0)
      end

      it "--" do
        pending
        xhr :post, :create, get_valid_member_with_resource([], [:resource_type])
        mem =  assigns(:member)
      end
    end
  end

  describe "show" do

    before do
      @member_t = Member.create(get_valid_member_with_resource[:member])
    end

    it "should find the member id and return it" do
      xhr :get, :show, :member_id => @member_t.member_id
      mem = assigns(:member)
      mem.member_id.should == @member_t.member_id
    end

    it "should not find the member" do
      xhr :get, :show, :member_id => 24
      mem = assigns(:member)
      mem.should be_nil
    end

  end

  describe "update" do

    before do
      @saved_member = Member.create!(get_valid_member_with_resource[:member])
    end

    context "with good data" do

      it "should update an existing saved resource" do
        updated_request_hash = update_resource @saved_member.saved_resources.first
        xhr :put, :update, :member_id => @saved_member.member_id,
            :saved_resource => updated_request_hash
        @saved_member.reload
        sr = @saved_member.saved_resources.find(updated_request_hash[:id])
        updated_request_hash.keys.each do |key|
          sr.send(key.to_sym).should == updated_request_hash[key]  unless
              key.to_s == "id" or !sr.respond_to?(key.to_sym)
        end
      end
    end

    context "with bad data" do

      it "should not update member if member does not exist" do
        updated_request_hash = update_resource @saved_member.saved_resources.first
        xhr :put, :update, :member_id => -1,
            :saved_resource => updated_request_hash
        @saved_member.reload
        sr = @saved_member.saved_resources.find(updated_request_hash[:id])
        updated_request_hash.keys.each do |key|
          sr.send(key.to_sym).should_not == updated_request_hash[key]  unless
              key.to_s == "id" or !sr.respond_to?(key.to_sym)
        end
        response.body.should have_errors_only
      end

      it "should not update member if saved_response does not exist" do
        updated_request_hash = update_resource
        xhr :put, :update, :member_id => @saved_member.member_id,
            :saved_resource => updated_request_hash
        @saved_member.reload
        sr = @saved_member.saved_resources.first
        updated_request_hash.keys.each do |key|
          sr.send(key.to_sym).should_not == updated_request_hash[key]  unless
              key.to_s == "id" or !sr.respond_to?(key.to_sym)
        end
        response.body.should have_errors_only
      end

      it "should allow saving of attributes besides the ones explicitly defined in the models"  do
        new_member_with_resource = get_valid_member_with_resource
        new_member_with_resource[:member][:member_id] = 4
        new_member_with_resource[:member][:saved_resources].first.merge!(number_of_arms:  2)
        #xhr :post, :create, new_member_with_resource
        expect {xhr :post, :create, new_member_with_resource}.to change(Member, :count).by(1)
        #binding.pry
        #pp response.body

        #module RSpec
        #  attr_accessor :parse_json
        #end
        #response.body.should have_json_path("member/saved_resources/0/number_of_arms")
      end

    end
  end

  describe "delete a member" do

    before do
      @saved_member = Member.create!(get_valid_member_with_resource[:member])
    end

    context "when member exists" do
      it "should remove the member with given member id" do
        expect {xhr :delete, :delete, :member_id => @saved_member.member_id}.to change(Member, :count).by(-1)
      end
    end

    context "when member does not exist" do
      it "member count stays the same as before" do
        expect {xhr :delete, :delete, :member_id => -1 }.to change(Member, :count).by(0)
        response.body.should have_errors_only
      end
    end
  end

  describe "removing a resource from a member" do

    before do
      @saved_member = Member.create!(get_valid_member_with_resource[:member])
    end

    context "when both member and resources exist" do

      it "should remove the resource" do
        remove_resource_hash = delete_resource @saved_member.saved_resources.first
        xhr :put, :remove_resource, :member_id => @saved_member.member_id,
                                    :saved_resource => remove_resource_hash
        @saved_member.reload
        @saved_member.saved_resources.length.should == 0
      end
    end

    context "when either member or resource(s) do not exist" do

      it "should cause an error when member is invalid" do
        remove_resource_hash = delete_resource @saved_member.saved_resources.first
        xhr :put, :remove_resource, :member_id => -1,
                                    :saved_resource => remove_resource_hash
        response.body.should have_errors_only
      end

      it "should cause an error when resource is invalid" do
        remove_resource_hash = delete_resource
        xhr :put, :remove_resource, :member_id => @saved_member.member_id,
            :saved_resource => remove_resource_hash
        response.body.should have_errors_only
      end

    end

  end

  describe "adding a new resource to a member" do

    before do
      @saved_member = Member.create(get_valid_member_with_resource[:member])
    end

    context "when the member exist" do

      it "should add new resources to saved_resources" do
        num_old_resources = @saved_member.saved_resources.length
        xhr :put, :add_resources, :member_id => 1, :saved_resources => get_new_resources
        @saved_member.reload
        @saved_member.saved_resources.length.should be == num_old_resources + 2
      end
    end

    context "that does not exist" do
      it "should cause and error" do
        num_old_resources = @saved_member.saved_resources.length
        xhr :put, :add_resources, :member_id => -1, :saved_resources => get_new_resources
        @saved_member.reload
        @saved_member.saved_resources.length.should_not be == num_old_resources + 2
        response.body.should have_errors_only
      end
    end

  end

  def get_valid_member_with_resource(reject_keys_sd=[], reject_keys_sr=[])
    {
      member: {
        member_id: 1,
        saved_resources: [
            {
                resource_id: "123",
                resource_type: "Rental",
                description: "Test resource",
                version: "1.0",
                query_string: "beds=1.0&baths=2.9"
            }.reject {|k,v| reject_keys_sr.include? k }
        ]
      }.reject {|k,v| reject_keys_sd.include? k}
    }
  end

  def update_resource(saved_resource = nil)
    id = saved_resource ? saved_resource.id.to_s : "bad_id_123"
    {
        :id => id,
        :description => "new description",
        :resource_type => "jake"
    }
  end

  def delete_resource(saved_resource = nil)
    id = saved_resource ? saved_resource.id.to_s : "bad_id_123"
    {
        :id => id
    }
  end

  def get_new_resources
     [
            {
                description: "This is my first saved Rental resource",
                resource_type: "Rental",
                resource_id: "abc-rental-id"
            },
            {
                description: "This is my first saved Listing resource",
                resource_type: "Listing",
                resource_id: "abc-listing-id"
            }
    ]

  end

end