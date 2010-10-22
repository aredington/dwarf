require File.join(File.dirname(__FILE__), *%w[spec_helper])

describe Dwarf::Classifier do  
  
  before(:each) do
    @classifier = Dwarf::Classifier.new()
  end
  
  it "accepts example classifications" do
    @classifier.should respond_to(:add_example)
  end

  it "stores examples" do
    @example3 = double('example3')
    @example3.stub(:attributes) { [] }
    @classifier.add_example(@example3, :irish)
    @classifier.examples.should include(@example3)
  end

  it "only implements classify on the learning instance" do
    @example = double('example3')
    @example.stub(:attributes) { [] }
    @class2 = Dwarf::Classifier.new()
    @classifier.add_example(@example, :round)
    @classifier.learn!
    @classifier.classify(@example).should eq(:round)
    @class2.classify(@example).should eq(nil)
  end

  context "classifying cars" do
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
    end
   
    it "enumerate example attributes" do
      mock_car_examples
      @classifier.add_example(@example1, :japanese)
      @classifier.example_attributes.should include("body_style", "cylinders")
    end

    it "classifies in a trivial case" do
      mock_car_examples
      @classifier.add_example(@example1, :japanese)
      @classifier.add_example(@example2, :german)
      @classifier.add_example(@example3, :american)
      @classifier.learn!
      @classifier.classify(@example1).should eq(:japanese)
      @classifier.classify(@example2).should eq(:german)
      @classifier.classify(@example3).should eq(:american)
    end

    it "classifies when multiple predicates required" do
      mock_car_examples
      @classifier.add_examples(@example1 => :japanese, @example2 => :german, @example3 => :american, @example4 => :german)
      @classifier.learn!
      @classifier.classify(@example1).should eq(:japanese)
      @classifier.classify(@example2).should eq(:german)
      @classifier.classify(@example3).should eq(:american)
      @classifier.classify(@example4).should eq(:german)
    end
    
  end
  
  
end
