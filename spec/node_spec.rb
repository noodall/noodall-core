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
  end

  it "should be found by permalink" do
    page = Factory(:page, :title => "My Page", :publish => true)
    Noodall::Node.find_by_permalink('my-page').should == page
  end


  describe "within a tree" do
    before(:each) do
      @root = Page.create!(:title => "Root")

      @child = Page.create!(:title => "Ickle Kid", :parent => @root)

      @grandchild = Page.create!(:title => "Very Ickle Kid", :parent => @child) 
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
      nodes = Noodall::Node.all(:published_at => { :$lte => Time.now }, :published_to => { :$gte => Time.now })
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
    node.destroyable_groups.should == ['Webbies', 'Dudes', 'Things']

    node = Factory(:page, :destroyable_groups_list => 'Webbies, Dudes,Things,  Dudes, ,')
    node.destroyable_groups.should == ['Webbies', 'Dudes', 'Things']
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

    ruby = Factory(:page, :updatable_groups => ['Dudes'], :destroyable_groups => ['Webbies', 'Dudes'], :publishable_groups => ['Dudes'] )

    ruby.all_groups.should have(2).things

    john.can_create?(ruby).should == true
    steve.can_create?(ruby).should == true

    ruby.creator = john
    ruby.save

    john.can_view?(ruby).should == true
    steve.can_view?(ruby).should == true

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

    results.first.should == top_hit

    results = Page.search("supercalifragilistic")

    results.should have(0).things
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
    class LandindPage < Noodall::Node
      sub_templates Page
    end
    class ArticlesList < Noodall::Node
      sub_templates LandindPage
    end

    Page.parent_classes.should include(LandingPage)
    Page.parent_classes.should_not include(ArticlesList)
  end

end
