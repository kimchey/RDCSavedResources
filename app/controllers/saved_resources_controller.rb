class SavedResourcesController < ApplicationController

  before_filter :lookup_member, only: [:show, :update, :delete, :remove_resource, :add_resources]
  before_filter :lookup_saved_resource, only: [:update, :remove_resource]
  rescue_from MongoMapper::DocumentNotFound, :with => :show_record_not_found

  def create
    @member = Member.create(params[:member])
    if @member.errors.count > 0
      render :json => { :meta => @member.errors }
    else
      render :json => @member.to_json
    end
  end

  def show
    render :json => @member.to_json
  end

  def update
    attributes_hash = params[:saved_resource]
    attributes_hash.keys.each do |key|
      method = (key + '=').to_sym
      if @sr.respond_to?(method) and key != "id"
        @sr.send(method, attributes_hash[key])
      end
    end
    @member.save
    render :json => @member.to_json
  end

  def add_resources
    saved_resources =  params[:saved_resources]
    saved_resources.each do |sr|
      @member.saved_resources << SavedResource.new(sr)
    end
    @member.save
    render :json => @member.to_json
  end

  def delete
    @member.destroy
    render :json => {:meta => "Member deleted"}
  end

  def remove_resource
    @srs.reject! {|ea| ea.id.to_str == @sr.id.to_str }
    @member.save
    render :json => {:meta => "resource deleted"}
  end

  def lookup_member
    @member = Member.find_by_member_id(params["member_id"].to_i)
    raise(MongoMapper::DocumentNotFound.new("Member with id: #{params["member_id"]} not found")) unless @member
  end

  def lookup_saved_resource
    @srs =  @member.saved_resources
    attributes_hash = params[:saved_resource]
    @sr =  @srs.find(params[:saved_resource][:id])
    raise(MongoMapper::DocumentNotFound.new("Saved_Resource with id: #{params[:saved_resource][:id]} not found")) unless @sr
  end


  def show_record_not_found(exception)
    render :json => {:meta => { :errors => [{
                                  :message => exception.message
                                            }]
                              }
                    }
  end

end