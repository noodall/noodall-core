module Noodall
  class Permalink < Array
    def initialize(*args)
      if args.length > 1
        super args
      else
        super args.first.to_s.split('/')
      end
    end

    def to_s
      self.join('/')
    end

    def inspect
      "<Permalink #{self.to_s}>"
    end

    def self.to_mongo(value)
      value.to_s
    end
    
    def self.from_mongo(value)
      new( *value.to_s.split('/') ) 
    end
  end
end
