module SanitizeAttributes
  module ClassMethods
    
    attr_accessor :default_sanitization_method_for_class
    
    def sanitizable_attributes #:nodoc:
      self.sanitizable_attribute_hash.keys
    end

    def sanitization_method_for_attribute(attribute) #:nodoc:
      index = self.sanitizable_attribute_hash[attribute]
      self.sanitization_block_array[index] if index
    end
  end
end