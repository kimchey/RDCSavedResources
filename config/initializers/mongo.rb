MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "rdcsaved_resources-#{Rails.env}"