# Dummy node class for the tests
class Page < Noodall::Node
  #sub_templates PageA, PageB, ArticlesList, LandingPage, EventsList
  searchable_keys :title, :description, :keywords, :body
  root_template!

  main_slots 1
  small_slots 4
  wide_slots 3
end

class LandingPage < Noodall::Node
  root_template!
end

# And a factory to build it
Factory.define :page do |node|
  node.title { Faker::Lorem.words(3).join(' ') }
  node.body { Faker::Lorem.paragraph }
  node.published_at { Time.now }
end

# And a factory to build it
Factory.define :landing_page do |node|
  node.title { Faker::Lorem.words(3).join(' ') }
  node.body { Faker::Lorem.paragraph }
  node.published_at { Time.now }
end
