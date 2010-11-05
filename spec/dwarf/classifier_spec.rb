require File.join(File.dirname(__FILE__), *%w[.. spec_helper.rb])

describe Dwarf::Classifier do  
  
  before(:each) do
    @classifier = Dwarf::Classifier.new()
  end

  def mock_car_examples
    @example1 = FakeCar.new(:body_style => :boxy,
                            :cylinders => 4,
                            :transmission => :manual)
    @example2 = FakeCar.new(:body_style => :swoopy,
                            :cylinders => 6,
                            :transmission => :manual)
    @example3 = FakeCar.new(:body_style => :angry,
                            :cylinders => 8,
                            :transmission => :manual)
    @example4 = FakeCar.new(:body_style => :swoopy,
                            :cylinders => 8,
                            :transmission => :manual)
    @example5 = FakeCar.new(:body_style => nil,
                            :cylinders => 6,
                            :transmission => :manual)
    @example6 = FakeCar.new(:body_style => :sleek,
                            :cylinders => nil,
                            :transmission => :manual)
  end

  context "add_example" do
  
    it "accepts example classifications" do
      @classifier.should respond_to(:add_example)
    end

    it "stores examples" do
      @example3 = double('example3')
      @example3.stub(:attribute_names) { [] }
      @classifier.add_example(@example3, :irish)
      @classifier.examples.should include(@example3)
    end

    it "enumerate example attributes" do
      @example_with_attributes = double('attrs')
      @example_with_attributes.stub(:attribute_names) { ["height", "branch_density"] }
      @classifier.add_example(@example_with_attributes, :pine)
      @classifier.example_attributes.should include("height", "branch_density")
    end

    it "gracefully accepts examples with nil attributes" do
      @example_with_nil_attributes = double('nils')
      @example_with_nil_attributes.stub(:attribute_names) { ["height", "branch_density"] }
      @example_with_nil_attributes.stub(:height) { nil }
      @example_with_nil_attributes.stub(:branch_density) { :high }
      lambda {@classifier.add_example(@example_with_nil_attributes, :pine)}.should_not raise_exception     
    end

  end

  context "learn! and classify" do

    it "only implements classify on the learning instance" do
      @example = double('example3')
      @example.stub(:attribute_names) { [] }
      @class2 = Dwarf::Classifier.new()
      @classifier.add_example(@example, :round)
      @classifier.learn!
      @classifier.classify(@example) == :round
      @class2.classify(@example).should  == nil
    end

    context "frawd is dwarf backwards" do
      before(:each) do
         @frawd = Frawd.new(1,100)
       end

      it "is totally awesome" do
         @frawd.training.each do |example, classification|
          @classifier.add_example(example, classification)
        end
        @classifier.learn!
        success = 0
        @frawd.testing.each do |example, classification|
          success += 1 if @classifier.classify(example) == classification
        end
        success.should == @frawd.testing.size
      end
    end

    context "classifying cars" do

      before(:each) do
        mock_car_examples
        @classifier.add_example(@example1, :japanese)
        @classifier.add_example(@example2, :german)
        @classifier.add_example(@example3, :american)
      end
      
      it "classifies in a trivial case" do
        @classifier.learn!
        @classifier.classify(@example1).should == :japanese
        @classifier.classify(@example2).should == :german
        @classifier.classify(@example3).should == :american
      end

      it "classifies when multiple predicates required" do
        @classifier.add_example(@example4, :german)
        @classifier.learn!
        @classifier.classify(@example1).should == :japanese
        @classifier.classify(@example2).should == :german
        @classifier.classify(@example3).should == :american
        @classifier.classify(@example4).should == :german
      end

      it "handles nils gracefully" do
        @classifier.add_examples(@example4 => :german,
                                 @example5 => :japanese,
                                 @example6 => :japanese)
        lambda{@classifier.learn!}.should_not raise_exception
      end

      it "handles nils correctly" do
        @classifier.add_examples(@example4 => :german,
                                 @example5 => :japanese,
                                 @example6 => :japanese)
        @classifier.learn!
        @classifier.classify(@example1).should == :japanese
        @classifier.classify(@example2).should == :german
        @classifier.classify(@example3).should == :american
        @classifier.classify(@example4).should == :german
        @classifier.classify(@example5).should == :japanese
        @classifier.classify(@example6).should == :japanese
      end

      it "handles a feature missing from all examples correctly" do
        @classifier.add_examples(@example4 => :german,
                                 @example5 => :japanese,
                                 @example6 => :japanese)
        @classifier.learn!
        open = [@classifier.decision_tree]
        until open.empty?
          current = open.pop
          current.attribute.should_not == "wheel_diameter"
          current.children.each {|child| open.push child}
        end
      end
    
      it "does not use a feature which is identical across all examples" do
        @classifier.add_examples(@example4 => :german,
                                 @example5 => :japanese,
                                 @example6 => :japanese)
        @classifier.learn!
        open = [@classifier.decision_tree]
        until open.empty?
          current = open.pop
          current.attribute.should_not == "transmission"
          current.children.each {|child| open.push child}
        end
      end

      it "does not use a feature unique to each example" do
        @classifier.add_examples(@example4 => :german,
                                 @example5 => :japanese,
                                 @example6 => :japanese)
        @classifier.learn!
        open = [@classifier.decision_tree]
        until open.empty?
          current = open.pop
          current.attribute.should_not == "vin"
          current.children.each {|child| open.push child}
        end
        
      end
      
    end
    
  end

  context "find_by_classification" do
    
    it "returns sets of cars based on class" do
      mock_car_examples
      @classifier.add_examples(@example1 => :japanese,
                               @example2 => :german,
                               @example3 => :american,
                               @example4 => :german)
      @classifier.learn!
      all_cars = [@example1, @example2, @example3, @example4]
      japanese_cars = @classifier.find_by_classification(all_cars, :japanese)
      japanese_cars.should == [@example1]
    end
    
    
  end
  
  
end
