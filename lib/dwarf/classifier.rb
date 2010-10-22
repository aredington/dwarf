module Dwarf
  class Classifier
    attr_accessor :examples
    attr_accessor :example_attributes
    attr_accessor :classifier_logic

    def initialize()
      @examples, @example_attributes = {}, []
      @decision_tree = TreeNode.new("ROOT")
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
      pending = []
      pending.push @decision_tree
      used_attributes = []
      until pending.empty?
        node = pending.pop
        if classification = homogenous_examples(node)
          node.classification = classification
        elsif no_valuable_attributes?(node) && node.parent
          node.parent.classification= expected_value(node.examples)
        elsif no_valuable_attributes?(node)
          classifier_logic = expected_value(node.examples)
        elsif false #stub branch
          #C4.5 would also allow for previously unseen classifications
          #dwarf's API dictates all classifications are known before learning
          #starts
        else
          infogains = {}
          (@example_attributes-used_attributes).each do |example_attribute|
            infogains[information_gain(node.examples,example_attribute)] = example_attribute
          end
          best_gain = infogains.keys.sort[0]
          best_attribute = infogains[best_gain]
          split(node,best_attribute).each {|child_node| pending.push(child_node)}
          used_attributes << best_attribute
        end
      end
      self.classifier_logic = codify_tree(@decision_tree)
      implement_classify
    end

    private

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
        child_node = TreeNode.new(key)
        child_node.examples = value
        node << child_node
      end
      node.examples = nil
      node.children
    end

    def expected_value(example_subset)
      examples_inversion = invert_with_dups(classification_map(example_subset))
      occurrences = examples_inversion.merge(examples_inversion) { |key, value| value.length }
      occurrences.keys.sort { |key| occurrences[key] }[0]
    end

    def no_valuable_attributes?(node)
      @example_attributes.map {|example_attribute|
        information_gain(node.examples, example_attribute)}.each {|info_gain|
        return false if info_gain != 0}
      return true
    end
    

    def homogenous_examples(node)
      classifications = classifications(node.examples)
      if classifications.length == 1
        return classifications[0]
      else
        return nil
      end
    end

    def entropy(example_subset)
      set_size = example_subset.length.to_f
      examples_inversion = invert_with_dups(classification_map(example_subset))
      occurences = examples_inversion.merge(examples_inversion) { |key, value| value.length.to_f }
      0.0 - classifications(example_subset).inject(0.0) do |sum, classification|
        sum + ((occurences[classification]/set_size)* Math.log2((occurences[classification]/set_size)))
      end
    end

    def information_gain(example_subset,attribute)
      set_size = example_subset.length.to_f
      examples_inversion = invert_with_dups(attribute_map(example_subset,attribute))
      occurrences = examples_inversion.merge(examples_inversion) { |key, value| value.length }
      entropy(example_subset) - attribute_values(example_subset,attribute).inject(0.0) do |sum, attribute_value|
        sum + (occurrences[attribute_value]/set_size) * entropy(examples_inversion[attribute_value])
      end
    end

    def classifications(example_subset)
      example_subset.map {|example| @examples[example]}.compact
    end

    def classification_map(example_subset)
      classification_map = {}
      example_subset.each {|example| classification_map[example] = @examples[example]}
      classification_map
    end

    def attribute_values(example_subset, attribute)
      example_subset.map {|example| example.method(attribute.to_sym).call}.compact
    end

    def attribute_map(example_subset, attribute)
      example_map = {}
      example_subset.each {|example| example_map[example] = example.method(attribute.to_sym).call}
      example_map
    end

    def invert_with_dups(hash)
      inversion = {}
      hash.values.each {|value| inversion[value] = []}
      hash.keys.each {|key| inversion[hash[key]] << key}
      inversion
    end    
  end
end
