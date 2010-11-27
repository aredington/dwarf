module Dwarf
  module ExampleManagement

    def classification_map(example_subset)
      classification_map = {}
      example_subset.each {|example| classification_map[example] = example.classification}
      classification_map
    end

    def invert_with_dups(hash)
      inversion = { }
      hash.values.each {|value| inversion[value] = []}
      hash.keys.each {|key| inversion[hash[key]] << key}
      inversion
    end    

    def attribute_map(example_subset, attribute)
      example_map = {}
      example_subset.each {|example| example_map[example] = example.feature_value(attribute)}
      example_map
    end

    def filter_classifications(example_subset)
      example_subset.map {|example| example.classification}.uniq
    end  

  end
end
