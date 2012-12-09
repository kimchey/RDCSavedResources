
class SavedResource
  include MongoMapper::EmbeddedDocument
  include MongoMapper::Plugins::Associations


  key :resource_id, String
  key :resource_type, String, :required => true
  key :description, String
  key :version, String
  key :query_string, String

  validate :test_required

  def test_required
    errors.add(:resource_type, "TESTING TEST")
  end

end