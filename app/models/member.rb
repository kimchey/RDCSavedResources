
class Member
  include MongoMapper::Document

  self.include_root_in_json = true

  key :member_id, Integer, :required => true, :unique => true

  many :saved_resources


  Member.ensure_index(:member_id)


end