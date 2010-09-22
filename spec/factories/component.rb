# A Dummy slot for tests
class Content < Noodall::Component
  key :title, String
  key :url, String
  key :url_text, String

  allowed_positions :small, :wide
end

# And a factory to build it
Factory.define :content do |component|
  component.title { Faker::Lorem.words(4).join('') }
  component.url { 'http://www.google.com' }
  component.url_text { 'More' }
end

