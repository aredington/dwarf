#require File.join(File.dirname(__FILE__), *%w[. spec_helper.rb])
require 'rspec/mocks'
require 'faker'
require 'digest'

class Frawd
  attr_reader :rules
  
  def initialize(depth = 10, sample_sizes = 1000)
    @depth = depth
    @sample_sizes = sample_sizes
    initialize_attributes
    @leaves = []
    @rules = build_rules
    @rules.each_leaf do |leaf|
      @leaves << leaf
    end
    #Voodoo to avoid mocks. After we have built the rule tree,
    # create an anonymous class which will accomodate all the 
    # attributes generated in it's creation.
    @example_class = Class.new
    attribute_names = @attributes.map {|a| a[0]}
    @example_class.send(:define_method, :attribute_names) {return attribute_names}
    @example_class.module_eval(attribute_names.map{ |name| "attr_accessor :#{name}\n" }.join)
  end

  def types
    [:enum, :number, :text]
  end

  def enums
    unless @enums
      @enums = [[:true, :false],
                [:baz, :bar, :zot],
                [:baz, :bar, :zot, :quux]]
      (1..rand(10)).each do
        @enums << Faker::Lorem.words(rand(10)).uniq.map(&:to_sym)
      end
    end
    @enums
  end

  def classifications
    @classifications ||= (1..rand(10)).map {|x| "classification#{x}".to_sym }
  end

  def initialize_attributes
    @attributes = []
    num_attributes = 10#rand(100)
    (1..num_attributes).each do |number|
      type = types.sample
      values = enums.sample if type == :enum
      @attributes << ["attribute#{number}", type, values]
    end
  end

  def filtered_attributes
    @attributes.select {|a| a[1] == :enum}
  end

  def build_rules(node = Dwarf::TreeNode.new("ROOT"), attributes = filtered_attributes)
    parents = node.parentage || []
    if (rand(@depth) < parents.length) || attributes.empty?
      node.classification = classifications.sample
    else
      attribute = attributes.sample
      node.attribute = attribute[0]
      attribute[2].each do |value|
        child = Dwarf::TreeNode.new(value.to_s)
        node << child
        build_rules(child,attributes-[attribute[0]])
      end
    end
    node
  end

  def generate_example
    node = @leaves.sample
    example_classification = node.classification
    example = @example_class.new
    node.parentage.unshift(node).each_cons(2) do |child, parent|
      example.send("#{parent.attribute}=".to_sym, child.name)
    end
    @attributes.each do |attribute|
      unless example.respond_to? attribute[0].to_sym
        val = case attribute[1]
              when :enum then attribute[2].sample
              when :number then rand((2**(0.size * 8 -2) -1))
              when :text then Faker::Lorem.paragraphs
              end
        example.stub!(attribute[0].to_sym) { val }
      end
    end
    [ example, example_classification ]
  end

  def generate_examples(count)
    examples = Array.new(count)
    (0...count).each { |index| examples[index] = generate_example }
    examples
  end

  def training
    @training ||= generate_examples(@sample_sizes)
  end

  def testing
    @testing ||= generate_examples(@sample_sizes)
  end
  
end
