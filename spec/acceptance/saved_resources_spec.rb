require 'spec_helper'

resource "SavedResources" do

  post '/saved_resources/create' do
    let(:raw_post) {params.to_json}
    let(:member) { {
                    member_id: 1,
                    saved_resources: [
                        {
                            resource_id: "123",
                            resource_type: "Rental",
                            description: "Test resource",
                            version: "1.0",
                            query_string: "beds=1.0&baths=2.9"
                        }
                    ]
                  } }
    parameter :member, "The members' resource being created"

    example "Create a new member with resource(s)" do
      do_request
      status.should == 200
    end

  end


  get '/saved_resources/show/:member_id' do
    let(:member_id) {1}

    example "Show member and associated resources" do
      do_request
      status.should == 200
    end
  end

  put '/saved_resources/update/:member_id' do
    let(:raw_post) {params.to_json}
    let(:saved_resource) {{
                          id: "50a6fc9e6cde546b46000002",
                          description: "Changing description to rental"
                          }}
    let(:member_id) {1}
    parameter :saved_resource, "---"

    example "Update resource attributes for a member/saved_resource" do
      do_request
      status.should == 200
    end

  end


  delete '/saved_resources/delete/:member_id' do
    let(:member_id) {1}

    example "Delete a member" do
      do_request
      status.should == 200
    end
  end

  put '/saved_resources/add_resources/:member_id' do
    let(:member_id) {1}
    let(:raw_post) {params.to_json}
    let(:saved_resources){
      [ {
          description: "This is my first saved Rental resource",
          resource_type: "Rental",
          resource_id: "abc-rental-id"
        },
        {
            description: "This is my first saved Listing resource",
        resource_type: "Listing",
        resource_id: "abc-listing-id"
        } ]
      }
    parameter :saved_resources, "new resources to add"

    example 'Add a resource to the resource list of a member' do
      do_request
      status.should == 200
    end
  end

  put '/saved_resources/remove_resource/:member_id' do
    let(:member_id) {1}
    let(:raw_post) {params.to_json}
    let(:id) { "50a6fc9e6cde546b46000002"}

    parameter :id, "resource to delete"

    example 'Remove a resource from a member' do
      do_request
      status.should == 200
    end
  end






end