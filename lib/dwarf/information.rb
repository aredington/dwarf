module Dwarf
  module Information

    class<< self    
      include ExampleManagement

      def entropy(example_subset)
        seen_classifications = filter_classifications(example_subset)
        return 0.0 if seen_classifications.length == 1
        set_size = example_subset.length.to_f
        examples_inversion = invert_with_dups(classification_map(example_subset))
        occurrences = occurrences(examples_inversion)
        sum_over(seen_classifications) do |classification|
          frequency = occurrences[classification]/set_size
          - frequency *  Math.log(frequency,seen_classifications.length)
        end
      end

      def information_gain(example_subset, attribute)
        filtered_example_subset = filter_for_missing_attribute(example_subset, attribute)
        unfiltered_information_gain(filtered_example_subset, attribute)
      end

      def unfiltered_information_gain(example_subset, attribute)
        set_size = example_subset.length.to_f
        examples_inversion = invert_with_dups(attribute_map(example_subset,attribute))
        occurrences = occurrences(examples_inversion)
        heterogeneous_entropy = entropy(example_subset)
        seen_attribute_values = attribute_values(example_subset,attribute)
        heterogeneous_entropy -
          sum_over(seen_attribute_values) do |attribute_value|
          frequency = occurrences[attribute_value]/set_size
          frequency * entropy(examples_inversion[attribute_value])
        end
      end

      private

      def sum_over(collection)
        collection.inject(0.0) do |sum, classification|
          sum + yield(classification)
        end
      end

      def occurrences(examples_inversion)
        examples_inversion.merge(examples_inversion) { |key, value| value.length.to_f }
      end
      
      def filter_for_missing_attribute(example_subset, attribute)
        example_subset.reject { |example| example.feature_value(attribute).nil? }
      end

      def attribute_values(example_subset, attribute)
        example_subset.map {|example| example.feature_value(attribute)}.uniq
      end

    end
    
  end
  
end
