module Dwarf
  module Proxies
    class Base < BasicObject
      attr_accessor :classification
      def initialize(example, classification)
        @example = example
        @classification = classification
      end
      
      def method_missing(method, *args, &block)
        @example.send(method, *args, &block)
      end

      def ==(instance)
        @example == instance || super(instance)
      end

      def feature_names
        raise ::NotImplementedError
      end

      def feature_value(feature_name)
        raise ::NotImplementedError
      end
    end
  end
end
