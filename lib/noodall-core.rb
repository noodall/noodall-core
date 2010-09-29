require 'mongo_mapper'
require 'mongo_mapper_acts_as_tree'
require 'canable'
require 'noodall/global_update_time'
require 'noodall/multi_parameter_attributes'
require 'noodall/search'
require 'noodall/tagging'
require 'noodall/permalink'
require 'noodall/indexer'
require 'noodall/component'
require 'noodall/node'


# Ruby 1.8 Compatibilty
class Object
  unless defined?(define_singleton_method)
    puts "Redefining 'define_singleton_method' to work with Ruby1.8"
    def define_singleton_method(sym, &block)
      singleton_class.instance_eval do
        define_method sym, block
      end
    end
  end
end
