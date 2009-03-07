module SanitizeAttributes
  module Macros
    # sanitize_attributes is used to define sanitizable attributes within a model definition.
    def sanitize_attributes(*args, &block)

      unless @sanitize_hook_already_defined
        include InstanceMethods
        extend ClassMethods

        before_save :sanitize!

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