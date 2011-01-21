require 'spec_helper'
require 'noodall/site'

describe Noodall::Site do

  before do
    class LandingPage < Noodall::Node; end
    class Home < Noodall::Node; end
    Noodall::Site.map = {
      'home' => {
        'title' => 'Welcome',
        'type' => 'Home'
      },
      'section' => {
        'title' => 'Welcome to section',
        'type' => 'LandingPage',
        'children' => {
          'section/page' => {
            'title' => 'About this section',
            'type' => 'Page',
          },
          'section/page2' => {
            'title' => 'More info',
            'type' => 'Page',
          }
        }
      },
      'about' => {
        'title' => 'About us',
        'type' => 'Page',
      }
    }
    Noodall::Site.build!
  end

  it 'should be populated from a permalink attributues hash' do
    Noodall::Node.count.should == 5
    Noodall::Node.roots.count.should == 3
  end

  it 'should know if it contains a permalink' do
    Noodall::Site.contains?('section/page').should == true
    Noodall::Site.contains?('about').should == true
    Noodall::Site.contains?('wout').should == false
    Home.first.in_site_map?.should == true
  end

  it 'should not fail if site map is empty' do
    Noodall::Site.map = nil
    Noodall::Site.build!
    Noodall::Site.contains?('about').should == false
  end
end
