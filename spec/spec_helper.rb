require File.join(File.dirname(__FILE__), *%w[.. lib dwarf])
require File.join(File.dirname(__FILE__), *%w[. frawd])

# http://blog.jayfields.com/2007/04/ruby-assigning-instance-variables-in.html
class Module
  def initializer(*args, &block)
    define_method :initialize do |*ctor_args|
      ctor_named_args = (ctor_args.last.is_a?(Hash) ? ctor_args.pop : {})
      (0..args.size).each do |index|
        instance_variable_set("@#{args[index]}", ctor_args[index])
      end
      ctor_named_args.each_pair do |param_name, param_value|
        instance_variable_set("@#{param_name}", param_value) 
      end
    end
  end
end

class FakeCar
  initializer :body_style, :cylinders, :wheel_diameter, :transmission
  attr_accessor :body_style, :cylinders, :wheel_diameter, :transmission

  @@vin_counter = 0
  
  def vin
    @vin ||= @@vin_counter+=1
  end

  def attributes
    ["body_style", "cylinders", "wheel_diameter", "transmission", "vin"]
  end

  alias_method :attribute_names, :attributes
  
  def to_s
    "#{body_style} with #{cylinders} cylinders"
  end
  
  def self.valid_body_styles
    [:boxy, :swoopy, :angry, :boring]
  end
  
  def self.valid_cylinders
    [4, 6, 8]
  end
  
  def self.fake
    new(:body_style => valid_body_styles.sample,
        :cylinders => valid_cylinders.sample)
  end
  
  def self.multiple_fakes(how_many=5)
    array = []
    how_many.times do
      array << fake
    end
    array
  end
end
