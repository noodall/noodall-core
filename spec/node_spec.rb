require 'spec_helper'

describe Noodall::Node do
  before(:each) do
    @valid_attributes = {
      :title => "My First Node"
    }
  end

  it "should create a new instance given valid attributes" do
    Noodall::Node.create!(@valid_attributes)
  end

  it "should be invalid if attributes are incorrect" do
    c = Noodall::Node.create
    c.valid?.should == false
  end

  it "should know it's root templates" do
    class LandingPage < Noodall::Node
      root_template!
    end

    Noodall::Node.template_classes.should include(LandingPage)
  end

  it "should know what class it is" do
    page = Page.create!(@valid_attributes)
    page.reload

    page.class.should == Page

    node = Noodall::Node.find(page.id)

    node.class.should == Page

    class LandingPage < Noodall::Node
      root_template!
    end

    LandingPage.create!(@valid_attributes)

    Page.last.class.should == Page
    LandingPage.last.class.should == LandingPage
  end

  it "should be found by permalink" do
    page = Factory(:page, :title => "My Page", :publish => true)
    Noodall::Node.find_by_permalink('my-page').should == page
  end

  it "should allow you to set the number of slots" do
    class NicePage < Noodall::Node
      wide_slots 3
      small_slots 5
    end

    NicePage.slots_count.should == 8
  end

  describe "within a tree" do
    before(:each) do
      class LandingPage < Noodall::Node
        root_template!
      end

      @root = LandingPage.create!(:title => "Root")

      @child = Page.create!(:title => "Ickle Kid", :parent => @root)

      @grandchild = Page.create!(:title => "Very Ickle Kid", :parent => @child)
    end

    it "should list the roots" do
      Page.create!(:title => "Root 2")

      Noodall::Node.roots.should have(2).things
    end

    it "should know about it's siblings" do
      3.times do |i|
        Page.create!(:title => "Sibbling #{i}", :parent => @root)
      end

      @child.siblings.should have(3).things
      @child.self_and_siblings.should have(4).things
    end

    it "should create permlink based on tree" do
      @grandchild.permalink.to_s.should == "root/ickle-kid/very-ickle-kid"
      @grandchild.reload
      @grandchild.permalink.to_s.should == "root/ickle-kid/very-ickle-kid"
    end

    it "should be under the correct path once moved" do
      grand_child_2 = Page.create!(:title => "Ickle Kid", :parent => @child)
      root_2 = Page.create!(:title => "Root 2")

      grand_child_2.parent = root_2
      grand_child_2.save!

      grand_child_2.path.should_not include(@child.id)
      grand_child_2.path.should include(root_2.id)
    end

    it "should be under the correct path once it's parent is moved" do
      grand_child_2 = Page.create!(:title => "Ickle Kid 2", :parent => @child)
      root_2 = Page.create!(:title => "Root 2")
      @child.parent = root_2
      @child.save(:validate => false)

      grand_child_2.reload

      grand_child_2.path.should_not include(@root.id)
      grand_child_2.path.should include(root_2.id)
    end

    it "should allow parent to be set to nill using a the string 'none' to make it easy to set via forms" do
      @grandchild.update_attributes!(:parent => 'none')
      @grandchild.reload
      @grandchild.parent.should be(nil)
    end

  end

  describe "Publish dates" do
    before(:each) do
      @node = Factory(:page, :published_at => 3.days.ago, :published_to => 3.days.since)
    end

    it "should be able to be published now" do
      node = Factory(:page, :publish => true)
      node.published?.should == true
    end

    it "should be able to be hidden now" do
      @node.hide = true
      @node.save
      @node.published?.should == false
    end

    it "should determine if it is published" do
      @node.published?.should == true
    end

    it "should know it it is to be published" do
      @node.published_at = 1.hour.since
      @node.save
      @node.published?.should == false
      @node.pending?.should == true
      @node.expired?.should == false
    end

    it "should know it has been published" do
      @node.published_to = 1.hour.ago
      @node.save
      @node.published?.should == false
      @node.pending?.should == false
      @node.expired?.should == true
    end

    it "should allow you to clear published to" do
      @node.published_to = 1.hour.ago
      @node.save
      @node.published?.should == false

      @node.published_to = nil
      @node.save
      @node.published?.should == true
    end

    it "should be findable by publish dates" do
      nodes = Noodall::Node.published
      nodes.should have(1).things

      nodes = Noodall::Node.all(:published_at => { :$lte => 4.days.ago }, :published_to => { :$gte => 4.days.ago })
      nodes.should have(0).things

      nodes = Noodall::Node.all(:published_at => { :$lte => 4.days.since }, :published_to => { :$gte => 4.days.since })
      nodes.should have(0).things

    end

  end

  it "should update the global update timestamp" do
    Noodall::GlobalUpdateTime::Stamp.should_receive(:update!)
    p = Factory(:page)
  end

  it "should be able to list all slots" do
    ObjectSpace.each_object(Class) do |c|
      next unless c.ancestors.include?(Noodall::Node) and (c != Noodall::Node)
      c.new.slots.should be_instance_of(Array)
    end

    node = Factory(:page)
    node.small_slot_0 = Content.new(:body => "Some text")
    node.small_slot_1 = Content.new(:body => "Some more text")

    node.save!

    node.slots.should have(2).things

    node.slots.first.body.should == "Some text"
    node.slots.last.body.should == "Some more text"
  end

  it "should use a tree structure" do
    root = Page.create!(@valid_attributes)

    child = Page.create!(:title => "Ickle Kid", :parent => root)

    grandchild = Page.create!(:title => "Very Ickle Kid", :parent => child)

    child.parent.should == root

    grandchild.root.should == root

    root.children.first.should == child

    sec_child = Page.create!(:title => "Ickle Kid 2", :parent => root)

    child.siblings.first.should == sec_child

    root.children.last.should == sec_child

    sec_child.position = 0
    sec_child.save

    root.children.first.should == sec_child

    child.reload

    child.position.should == 1

    third_child = Page.create!(:title => "Ickle Kid 3", :parent => root, :position => 0)

    root.children.first.should == third_child

    sec_child.reload

    sec_child.position.should == 1

    child.reload

    child.position.should == 2

    last_child = Page.create!(:title => "Ickle Kid 4", :parent => root, :position => 33)

    last_child.reload

    root.children.should have(4).things


    root.children.last.should == last_child

    last_child.position.should == 3
  end

  it "shold allow groups to be set by strings for easy form access" do
    node = Factory(:page)
    node.destroyable_groups_list = 'Webbies, Dudes,Things,  Dudes, ,'
    node.destroyable_groups.should == ['webbies', 'dudes', 'things']

    node = Factory(:page, :destroyable_groups_list => 'Webbies, Dudes,Things,  Dudes, ,')
    node.destroyable_groups.should == ['webbies', 'dudes', 'things']
  end

  it "should restrict user accces by groups" do
    # Stub a simple user model
    class ::User
      include MongoMapper::Document
      include Canable::Cans

      key :name, String
      key :groups, Array
      key :admin, Boolean
    end

    john = User.create!(:name => 'John', :groups => ['Webbies','Blokes'])
    steve = User.create!(:name => 'Steve', :groups => ['Dudes'])

    ruby = Factory(:page, :updatable_groups => ['Dudes'], :destroyable_groups => ['Webbies', 'Dudes'], :publishable_groups => ['Dudes'], :viewable_groups => ['Blokes'] )

    ruby.all_groups.should have(3).things

    john.can_create?(ruby).should == true
    steve.can_create?(ruby).should == true

    ruby.creator = john
    ruby.save

    john.can_view?(ruby).should == true
    steve.can_view?(ruby).should == false

    john.can_update?(ruby).should == false
    steve.can_update?(ruby).should == true

    john.can_destroy?(ruby).should == true
    steve.can_destroy?(ruby).should == true
  end

  it "should be searchable" do
    3.times do |i|
      Factory(:page, :title => "My Searchable Page #{i}")
    end

    top_hit = Factory(:page, :title => "My Extra Searchable Page", :description => "My Extra Searchable Page")

    3.times do |i|
      Factory(:page, :title => "My Unfit Page #{i}")
    end

    results = Page.search("Searchable")

    results.should have(4).things

    results.first.should == top_hit

    results = Page.search("Searchable", :per_page => 2)

    results.should have(2).things
    results.total_pages.should == 2

    results.first.should == top_hit

    results = Page.search("supercalifragilistic")

    results.should have(0).things
  end

  describe "creating keywords" do

    it "should create keywords" do
      page = Factory(:page, :title => "I like to teach")
      page._keywords.should include("teach")

      page = Factory(:page, :title => "I am going to be teaching")
      page._keywords.should include("teach")

      page = Factory(:page, :title => "The way he teaches is terrible")
      page._keywords.should include("teach")
    end

  end

  describe "stemmed searching" do

    before(:each) do
      Factory(:page, :title => "I like to teach")
      Factory(:page, :title => "I like teaching")
      Factory(:page, :title => "The way he teaches is terrible")
      Factory(:page, :title => "I like the moon")
      Factory(:page, :title => "I like cheese")
    end

    it "should return stemmed matches" do
      results = Page.search("teaching")
      results.should have(3).things
    end

  end

  it "should return related" do
    Factory(:page, :title => "My Page 1", :tag_list => 'one,two,three')
    Factory(:page, :title => "My Page 2", :tag_list => 'two,three,four')
    Factory(:page, :title => "My Page 3", :tag_list => 'three,four,five')
    ref = Factory(:page, :title => "My Page 4", :tag_list => 'five,nine')

    ref.related.should have(1).things

    Factory(:page, :title => "My Page 5", :tag_list => 'nine')

    ref.related.should have(2).things
  end

  it "should know who can be a parent" do
    class LandingPage < Noodall::Node
      sub_templates Page
    end
    class ArticlesList < Noodall::Node
      sub_templates LandingPage
    end

    Page.parent_classes.should include(LandingPage)
    Page.parent_classes.should_not include(ArticlesList)
  end

  it "should know what sub templates are allowed" do
    class LandingPage < Noodall::Node
      root_template!
      sub_templates Page, LandingPage
    end
    class Article < Noodall::Node
    end

    LandingPage.template_classes.should include(Page)
    Article.template_classes.should have(0).things
  end

  it "should fall back to title for link name if it is blank" do
    page = Factory(:page, :title => "My Long Title that is long")

    page.name.should == "My Long Title that is long"

    page.name = "Shorty"
    page.save

    page.name.should == "Shorty"
  end

  it "should be indexed only when explicitly called" do
    Noodall::Node.collection.drop_indexes
    class LandingPage < Noodall::Node
      key :dude, String, :index => true
    end

    Noodall::Node.indexes.should include ['dude']

    Noodall::Node.create_indexes!
    Noodall::Node.collection.index_information.keys.should include('dude_1')
  end

  describe "when template changing" do

    before(:each) do
      class LandingPage < Noodall::Node
        root_template!
        sub_templates Page, LandingPage
      end
      class Article < Noodall::Node
      end
      @page = Factory(:page)
      Factory(:page, :parent => @page) # add a child
    end

    it "should not error if we haven't changed template" do
      @page.save!
    end

    it "should throw an validation error if the children are not valid" do
      @page.template = 'Article'
      @page.save.should be(false)
    end

    it "should allow us to change template" do
      @page.template = 'Landing Page'
      @page.save!
    end
  end
end
