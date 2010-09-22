require 'mongo_mapper'
require 'mongo_mapper_acts_as_tree'
require 'canable'

module Noodall
  VESRION = '0.0.1'
  autoload :GlobalUpdateTime,         'noodall/global_update_time'
  autoload :MultiParameterAttributes, 'noodall/multi_parameter_attributes'
  autoload :Search,                   'noodall/search'
  autoload :Tagging,                  'noodall/tagging'
  autoload :Permalink,                'noodall/permalink'
  autoload :Component,                'noodall/component'
  autoload :Node,                     'noodall/node'
end
