require 'spec_helper'

describe SavedResource do

  it {should respond_to(:resource_id)}
  it {should respond_to(:resource_type)}
  it {should respond_to(:description)}
  it {should respond_to(:version)}
  it {should respond_to(:query_string)}
  it {should validate_presence_of(:resource_type)}


end