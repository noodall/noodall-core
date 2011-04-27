# This is a duplicate of mm-versionable lib/versionable/models/version.rb
# with indexing turned off so it doesn't complian when included that there
# is no db connection
class Version
  include MongoMapper::Document

  key :data, Hash
  key :date, Time
  key :pos, Integer#, :index => true
  key :doc_id, String#, :index => true
  key :message, String
  key :updater_id, String

  def content(key)
    cdata = self.data[key]
    if cdata.respond_to?(:join)
      cdata.join(" ")
    else
      cdata
    end
  end
end
