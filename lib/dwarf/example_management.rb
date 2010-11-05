module Dwarf
  module ExampleManagement

    def classification_map(example_subset, classifications)
      classification_map = {}
      example_subset.each {|example| classification_map[example] = classifications[example]}
      classification_map
    end

    def invert_with_dups(hash)
      inversion = { }
      hash.values.each {|value| inversion[value] = []}
      hash.keys.each {|key| inversion[hash[key]] << key}
      inversion
    end    

    def eval_attribute(example,attribute)
      example.method(attribute.to_sym).call
    end

    def attribute_map(example_subset, attribute)
      example_map = {}
      example_subset.each {|example| example_map[example] = eval_attribute(example, attribute)}
      example_map
    end

    def filter_classifications(classifications,example_subset)
      example_subset.map {|example| classifications[example]}.uniq
    end  

  end
end
