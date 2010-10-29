require File.join(File.dirname(__FILE__), *%w[.. spec_helper.rb])

describe Dwarf::Information do

  class Deck

    def initialize()
      @draw = (1..52).map{|v| v}
      @draw.shuffle!
      @discard = []
    end

    def sample
      unless @draw.empty?
        card = @draw.pop
        @discard.push card
        return card
      else
        @draw = @discard
        @draw.shuffle
        @discard = []
        return self.sample
      end
    end

  end

  class Coin

    def initialize(weighting)
      @weighting = weighting
      @faces = [:heads, :tails]
    end

    def attributes
      "weighting"
    end

    def weighting
      @weighting
    end

    def sample
      case @weighting
      when :fair then @faces.sample
      when :heads then :heads
      when :tails then :tails
      end
    end

  end
  
  context "entropy" do
    it "calculates correctly for heads and tails" do
      examples = []
      classifications = {}
      coin = Coin.new(:fair)
      1000.times do
        obj = Object.new
        examples << obj
        classifications[obj] = coin.sample
      end
      entropy = Dwarf::Information.entropy(examples, classifications)
      entropy.should > 0.99
      entropy.should <= 1.0
    end

    it "calculates correctly for 1d6" do
      examples = []
      classifications = {}
      die = (1..6).map{|v| v}
      1000.times do
        obj = Object.new
        examples << obj
        classifications[obj] = die.sample
      end
      entropy = Dwarf::Information.entropy(examples, classifications)
      entropy.should > 0.99
      entropy.should <= 1.0      
    end

    it "calculates correctly for a deck of cards" do
      examples = []
      classifications = {}
      deck = Deck.new
      1000.times do
        obj = Object.new
        examples << obj
        classifications[obj] = deck.sample
      end
      entropy = Dwarf::Information.entropy(examples, classifications)
      entropy.should > 0.99
      entropy.should <= 1.0
    end

    it "calculates correctly with a weighted coin" do
      examples = []
      classifications = {}
      1000.times do
        obj = Object.new
        examples << obj
        classifications[obj] = (rand(100) == 99) ? :heads : :tails
      end
      entropy = Dwarf::Information.entropy(examples,classifications)
      entropy.should < 0.101 #With a perfect 99:1 distribution, entropy should == 0.0807...
      entropy.should >= 0.04
    end

    it "calculates correctly with a homogenous set" do
      examples = []
      classifications = {}
      1000.times do
        obj = Object.new
        examples << obj
        classifications[obj] = :heads
      end
      entropy = Dwarf::Information.entropy(examples,classifications)
      entropy.should == 0.0
    end
    
  end

  context "information_gain" do

    it "calculates correctly splitting perfectly weighted coins" do
      examples = []
      classifications = {}
      500.times do
        coin = Coin.new(:heads)
        examples << coin
        classifications[coin] = coin.sample
      end
      500.times do
        coin = Coin.new(:tails)
        examples << coin
        classifications[coin] = coin.sample
      end
      information_gain = Dwarf::Information.information_gain(examples, "weighting", classifications)
      information_gain.should == 1.0
    end

    it "calculates worthless infogame for fair weighted coins" do
      examples = []
      classifications = {}
      coin = Coin.new(:fair)
        1000.times do
        coin = Coin.new(:fair)
          examples << coin
        classifications[coin] = coin.sample
      end
      information_gain = Dwarf::Information.information_gain(examples, "weighting", classifications)
      information_gain.should == 0.0
    end
      
  end

end
