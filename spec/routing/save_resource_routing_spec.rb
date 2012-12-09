require 'spec_helper'

describe "save_resources routing" do

  describe "POST /saved_resources/create" do

    it "routes to /saved_resources/#create" do
     {:post=> '/saved_resources/create' }.should route_to(
        :controller => "saved_resources",
        :action => "create",
        :format => 'json'
      )
    end


  end

  describe "GET /saved_resources/show/:member_id" do

    it "routes to /saved_resources/show/:member_id" do
      {:get=> '/saved_resources/show/1' }.should route_to(
                                                      :controller => "saved_resources",
                                                      :action => "show",
                                                      :member_id => '1',
                                                      :format => 'json'
                                                  )
    end


  end

  describe "POST /saved_resources/update/:member_id" do

    it "routes to /saved_resources/update/:member_id" do
      {:put => '/saved_resources/update/1'}.should route_to(
                                                          :controller => "saved_resources",
                                                          :action => "update",
                                                          :member_id => '1',
                                                          :format => 'json'
                                                          )
    end

  end

  describe "DELETE Member /saved_resources/delete/:member_id" do

    it "routes to /saved_resources/delete/:member_id" do
      {:delete => '/saved_resources/delete/1'}.should route_to(
                                                              :controller => "saved_resources",
                                                              :action => "delete",
                                                              :member_id => '1',
                                                              :format => 'json'
                                                              )
    end
  end

  describe "Remove a saved_resource from a member" do

    it "should route to /saved_resources/remove_resource/:member_id" do
      {:put => '/saved_resources/remove_resource/1'}.should route_to(
                                                         :controller => "saved_resources",
                                                         :action => "remove_resource",
                                                         :member_id => '1',
                                                         :format => 'json'
                                                   )
    end

  end

  describe "Add a saved_resource to a existing member" do

    it "should route to /saved_resources/add_resources/:member_id" do
      {:put => '/saved_resources/add_resources/1'}.should route_to(
                                                                :controller => "saved_resources",
                                                                :action => "add_resources",
                                                                :member_id => '1',
                                                                :format => 'json'
                                                            )
    end

  end
end