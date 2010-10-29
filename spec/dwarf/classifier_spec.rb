require File.join(File.dirname(__FILE__), *%w[.. spec_helper.rb])

describe Dwarf::Classifier do  
  
  before(:each) do
    @classifier = Dwarf::Classifier.new()
  end

  def mock_car_examples
    @example1 = double('example1')
    @example1.stub(:body_style) { :boxy }
    @example1.stub(:cylinders) { 4 }
    @example1.stub(:attributes) { ["body_style", "cylinders"] }
    
    @example2 = double('example2')
    @example2.stub(:body_style) { :swoopy }
    @example2.stub(:cylinders) { 6 }
    @example2.stub(:attributes) { ["body_style", "cylinders"] }
    
    @example3 = double('example3')
    @example3.stub(:body_style) { :angry }
    @example3.stub(:cylinders) { 8 }
    @example3.stub(:attributes) { ["body_style", "cylinders"] }
    
    @example4 = double('example4')
    @example4.stub(:body_style) {:swoopy}
    @example4.stub(:cylinders) {8}
    @example4.stub(:attributes) { ["body_style", "cylinders"] }
    
    @example5 = double('example5')
    @example5.stub(:body_style) { nil }
    @example5.stub(:cylinders) { 6 }
    @example5.stub(:attributes) { ["body_style", "cylinders"] }
    
    @example6 = double('example6')
    @example6.stub(:body_style) { :sleek }
    @example6.stub(:cylinders) { nil }
    @example6.stub(:attributes) { ["body_style", "cylinders"] }

  end

  context "add_example" do
  
    it "accepts example classifications" do
      @classifier.should respond_to(:add_example)
    end

    it "stores examples" do
      @example3 = double('example3')
      @example3.stub(:attributes) { [] }
      @classifier.add_example(@example3, :irish)
      @classifier.examples.should include(@example3)
    end

    it "enumerate example attributes" do
      @example_with_attributes = double('attrs')
      @example_with_attributes.stub(:attributes) { ["height", "branch_density"] }
      @classifier.add_example(@example_with_attributes, :pine)
      @classifier.example_attributes.should include("height", "branch_density")
    end

    it "gracefully accepts examples with nil attributes" do
      @example_with_nil_attributes = double('nils')
      @example_with_nil_attributes.stub(:attributes) { ["height", "branch_density"] }
      @example_with_nil_attributes.stub(:height) { nil }
      @example_with_nil_attributes.stub(:branch_density) { :high }
      lambda {@classifier.add_example(@example_with_nil_attributes, :pine)}.should_not raise_exception     
    end

  end

  context "learn! and classify" do

    it "only implements classify on the learning instance" do
      @example = double('example3')
      @example.stub(:attributes) { [] }
      @class2 = Dwarf::Classifier.new()
      @classifier.add_example(@example, :round)
      @classifier.learn!
      @classifier.classify(@example) == :round
      @class2.classify(@example).should  == nil
    end

    context "classifying cars" do
      
      it "classifies in a trivial case" do
        mock_car_examples
        @classifier.add_example(@example1, :japanese)
        @classifier.add_example(@example2, :german)
        @classifier.add_example(@example3, :american)
        @classifier.learn!
        @classifier.classify(@example1).should == :japanese
        @classifier.classify(@example2).should == :german
        @classifier.classify(@example3).should == :american
      end

      it "classifies when multiple predicates required" do
        mock_car_examples
        @classifier.add_examples(@example1 => :japanese, @example2 => :german, @example3 => :american, @example4 => :german)
        @classifier.learn!
        @classifier.classify(@example1).should == :japanese
        @classifier.classify(@example2).should == :german
        @classifier.classify(@example3).should == :american
        @classifier.classify(@example4).should == :german
      end

      it "handles nils gracefully" do
        mock_car_examples
        @classifier.add_examples(@example1 => :japanese,
                                 @example2 => :german,
                                 @example3 => :american,
                                 @example4 => :german,
                                 @example5 => :japanese,
                                 @example6 => :japanese)
        lambda{@classifier.learn!}.should_not raise_exception
      end

      it "handles nils correctly" do
        mock_car_examples
        @classifier.add_examples(@example1 => :japanese,
                                 @example2 => :german,
                                 @example3 => :american,
                                 @example4 => :german,
                                 @example5 => :japanese,
                                 @example6 => :japanese)
        @classifier.learn!
        puts @classifier.classifier_logic
        @classifier.classify(@example1).should == :japanese
        @classifier.classify(@example2).should == :german
        @classifier.classify(@example3).should == :american
        @classifier.classify(@example4).should == :german
        @classifier.classify(@example5).should == :japanese
        @classifier.classify(@example6).should == :japanese
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
