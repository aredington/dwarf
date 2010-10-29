module Dwarf
  class Classifier

    attr_accessor :examples
    attr_accessor :example_attributes
    attr_accessor :classifier_logic

    def initialize()
      @examples, @example_attributes = {}, []
      @decision_tree = TreeNode.new("ROOT")
      @nil_name = Object.new.to_s
    end

    def add_examples(example_hash)
      example_hash.each do |example, classification|
        add_example(example, classification)
      end
    end

    def add_example(example_record, classification)
      @examples[example_record]=classification
      @example_attributes |= example_record.attributes
    end

    def classify(example)
      return nil
    end

    def learn!
      @decision_tree.examples = @examples.keys
      converge_tree
      self.classifier_logic = codify_tree(@decision_tree)
      implement_classify
    end

    def find_by_classification(world, classification)
      matches = []
      world.each do |instance|
        if classify(instance) == classification
          matches << instance
        end
      end
      matches
    end
    
    private

    include ExampleManagement

    def converge_tree
      pending = []
      pending.push @decision_tree
      until pending.empty?
        node = pending.pop
        if classification = homogenous_examples(node)
          node.classification = classification
        elsif no_valuable_attributes?(node) && node.parent
          if split_nil_children = check_nil_split(node)
            split_nil_children.each {|child_node| pending.push(child_node)}
          else
            create_expected_value(node)
          end
        elsif no_valuable_attributes?(node)
          node.classification = expected_value(node.examples)
        elsif false #stub branch
          #C4.5 would also allow for previously unseen classifications
          #dwarf needs to correctly handle a pre-existing tree when
          #learn! is called
        else
          split_children = homogenize_children(node)
          split_children.each {|child_node| pending.push(child_node)}
        end
      end
    end

    def check_nil_split(node)
      infogains = {}

      used_attributes = used_attributes(node)
      (@example_attributes-used_attributes).each do |example_attribute|
        infogains[Information::unfiltered_information_gain(node.examples,example_attribute,@examples)] =
          example_attribute
      end
      best_gain = infogains.keys.sort[0]
      best_attribute = infogains[best_gain]
      if best_gain > 0.0
        return split(node, best_attribute)
      end
      
    end
    
    def create_expected_value(node)
      new_node = TreeNode.new(node.name)
      expected_value = expected_value(node.examples)
      new_node.classification = expected_value
      parent = node.parent
      parent.remove! node
      parent << new_node
      new_node << node
    end

    def used_attributes(node)
      if node.parentage
        node.parentage.map { |parent| parent.attribute }
      else
        []
      end
    end

    def homogenize_children(node)
      infogains = {}

      used_attributes = used_attributes(node)
      
      (@example_attributes-used_attributes).each do |example_attribute|
        infogains[Information::information_gain(node.examples,example_attribute,@examples)] =
          example_attribute
      end
      
      best_gain = infogains.keys.sort[0]
      best_attribute = infogains[best_gain]

      return split(node,best_attribute)
    end

    def implement_classify
      classify_impl = "def classify(example)\n#{self.classifier_logic}\nend"
      self.instance_eval classify_impl
    end

    def codify_tree(decision_tree)
      lines = [""]
      depth = 1
      codify_node(decision_tree, lines, depth)
      lines.join("\n")
    end

    def codify_node(decision_tree, lines, depth)
      if decision_tree.attribute
        lines << ("  "*depth)+"case example.#{decision_tree.attribute}"
        decision_tree.children.each do |child|
          lines << ("  "*depth)+"when #{codify_literal(child.name)}"
          codify_node(child, lines, depth + 1)
        end
        lines << ("  "*depth)+"end"
      elsif decision_tree.classification
        lines << ("  "*depth)+"return #{codify_literal(decision_tree.classification)}"
      end
    end

    def codify_literal(object)
      case object
        when @nil_name then "nil"
        when Symbol then ":#{object}"
        when String then "\"#{object}\""
      else
        object.to_s
      end
    end
    
    def split(node, attribute)
      node.attribute = attribute
      example_subset = node.examples
      examples_inversion = invert_with_dups(attribute_map(example_subset,attribute))
      examples_inversion.each do |key, value|
        if key.nil?
          key = @nil_name
        end
        child_node = TreeNode.new(key)
        child_node.examples = value
        node << child_node
      end
      node.examples = nil
      node.children
    end

    def expected_value(example_subset)
      examples_inversion = invert_with_dups(classification_map(example_subset, @examples))
      occurrences = examples_inversion.merge(examples_inversion) { |key, value| value.length }
      occurrences.keys.sort { |key| occurrences[key] }[0]
    end

    def no_valuable_attributes?(node)
      @example_attributes.map {|example_attribute|
        Information::information_gain(node.examples, example_attribute, @examples)}.each {|info_gain|
        return false if info_gain != 0}
      return true
    end
    
    def homogenous_examples(node)
      classifications = filter_classifications(@examples, node.examples)
      if classifications.length == 1
        return classifications[0]
      else
        return nil
      end
    end

  end
end
