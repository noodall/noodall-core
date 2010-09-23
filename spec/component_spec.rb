require 'spec_helper'

describe Noodall::Component do

  it "should allow you to define the slots that are available" do
    Noodall::Node.slots :wide, :small, :main

    Noodall::Component.possible_slots.should == [:wide, :small, :main]

    class Promo < Noodall::Component
      allowed_positions :small, :wide, :main, :egg, :nog
    end

    Promo.positions.should have(3).things
  end

  it "should list components classes avaiable to a slot" do

    class Promo < Noodall::Component
      allowed_positions :small, :wide
    end

    Promo.positions.should have(2).things

    Noodall::Component.positions_classes(:small).should include(Promo)
    Noodall::Component.positions_classes(:main).should_not include(Promo)
  end

  it "should be validated by the node" do
    class Promo < Noodall::Component
      allowed_positions :small, :wide
    end

    node = Factory(:page)
    node.main_slot_0 = Promo.new()
  
    node.save
  
    node.errors.should have(1).things
  end

  it "should know it's node" do
    node = Factory(:page)
    node.small_slot_0 = Factory(:content) 

    node.save!

    node.small_slot_0.node.should == node
  end

end
