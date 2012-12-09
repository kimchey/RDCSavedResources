require 'spec_helper'

describe Member do

  describe "attributes" do
    it {should respond_to(:member_id)}
    it {should validate_presence_of(:member_id)}
    it {should validate_uniqueness_of(:member_id)}
  end


  it "should have many saved_resources association" do
    #This is sort of a hack since there are no shoulda matchers for mongomapper associations
    Member.associations[:saved_resources].class.to_s.should include("ManyAssociation")
  end

  it "should create a member" do
    @member = Member.new(:member_id => 1234)
    @member.save
    @member.should be_valid
  end

  it "should find the member" do
    @member = Member.new(:member_id => 1234)
    @member.save
    Member.find_by_member_id(1234).should == @member
  end

end