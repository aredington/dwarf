require 'tree'
module Dwarf
  class TreeNode < Tree::TreeNode
    attr_accessor :examples
    attr_accessor :classification
    attr_accessor :attribute

    def initialize(name, content = nil)
      examples = []
      classification = nil
      attribute = nil
      super(name, content)
    end
  end
end
