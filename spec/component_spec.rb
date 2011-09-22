require 'spec_helper'

describe Noodall::Component do

  it "should list components classes avaiable to a slot (deprecated)" do
    class DListedComponent < Noodall::Component
      allowed_positions :dsmall, :dwide
    end

    Noodall::Node.dsmall_slot_components.should include(DListedComponent)
    Noodall::Node.dmain_slot_components.should_not include(DListedComponent)
  end

  it "should list components classes avaiable to a slot" do
    class ListedComponent < Noodall::Component
    end

    Noodall::Node.slot :small, ListedComponent, Content
    Noodall::Node.slot :main, Content

    Noodall::Node.small_slot_components.should include(ListedComponent)
    Noodall::Node.main_slot_components.should_not include(ListedComponent)
  end

  it "should be validated by the node (deprecated)" do
    Noodall::Node.slots :wide, :small, :main

    class DValidatedComponent < Noodall::Component
      allowed_positions :small, :wide
    end

    class DValidatedNode < Noodall::Node
      main_slots 3
    end

    node = DValidatedNode.new :title => "Slot Node"
    node.main_slot_0 = DValidatedComponent.new

    node.save

    node.errors.should have(1).things
  end

  it "should be validated by the node" do
    class ValidatedComponent < Noodall::Component
    end

    Noodall::Node.slot :middle, ValidatedComponent
    Noodall::Node.slot :main, Content

    class ValidatedNode < Noodall::Node
      main_slots 1
    end

    node = ValidatedNode.new :title => "Slot Node"
    node.main_slot_0 = ValidatedComponent.new

    node.save

    node.errors.should have(1).things
  end

  it "should know it's node" do
    Noodall::Node.slot :small, Content

    class KnowingNode < Noodall::Node
      small_slots 3
    end

    node = KnowingNode.new :title => "Slot Node"

    node.small_slot_0 = Factory(:content)

    node.save!

    node.small_slot_0.node.should == node
  end

end
