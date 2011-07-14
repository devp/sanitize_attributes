module SanitizeAttributes
  module Macros
    # sanitize_attributes is used to define sanitizable attributes within a model definition.
    def sanitize_attributes(*args, &block)
      if (args.last && args.last.is_a?(Hash))
        options = args.pop
      end
      options ||= {}
      unless @sanitize_hook_already_defined
        include InstanceMethods
        extend ClassMethods

        if options[:before_validation]
          before_validation :sanitize!
        else
          before_save :sanitize!
        end

        cattr_accessor :sanitizable_attribute_hash
        cattr_accessor :sanitization_block_array
        self.sanitizable_attribute_hash ||= {}
        self.sanitization_block_array ||= []

        @sanitize_hook_already_defined = true
      end

      if block
        self.sanitization_block_array << block
        block = self.sanitization_block_array.index(block)
      else
        block = nil
      end

      args.each do |attr|
        self.sanitizable_attribute_hash[attr] = block
      end

      true
    end
  end
end