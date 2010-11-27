module Dwarf
  module Proxies
    class ActiveRecord < Base
      def feature_names
        @example.attribute_names
      end
      
      def feature_value(feature_name)
        @example.method(feature_name.to_sym).call
      end

    end
  end
end
