module SanitizeAttributes
  def sanitize_attributes(*args, &block)
    include InstanceMethods
    extend ClassMethods
        
    unless @sanitize_hook_already_defined
      before_save :sanitize!
      @sanitize_hook_already_defined = true
    end
    
    cattr_accessor :sanitizable_attribute_hash
    cattr_accessor :sanitization_block_array

    self.sanitizable_attribute_hash ||= {}
    self.sanitization_block_array ||= []
    
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
  
  class << self
    attr_accessor :default_sanitization_method
    
    def define_default_sanitization_method(&block)
      self.default_sanitization_method = block
    end
  end
  
  module ClassMethods
    attr_accessor :default_sanitization_method_for_class
    
    def define_default_sanitization_method_for_class(&block)
      self.default_sanitization_method_for_class = block
    end
    
    def sanitizable_attributes
      self.sanitizable_attribute_hash.keys
    end

    def get_sanitization_method_for_attribute(attr)
      i = self.sanitizable_attribute_hash[attr]
      self.sanitization_block_array[i] if i
    end
  end
  
  module InstanceMethods   
    # sanitize! is the method that is called when a model is saved.
    # It can be called ot manually sanitize attributes.
    def sanitize!
      self.class.sanitizable_attributes.each do |attr_name|
        cleaned_text = process_text_via_sanitization_method(self.send(attr_name), attr_name)
        self.send((attr_name.to_s + '='), cleaned_text)
      end
    end
    
    private
      def process_text_via_sanitization_method(txt, attr_name = nil)
        return nil if txt.nil?
        m =  self.class.get_sanitization_method_for_attribute(attr_name) || # attribute level
             self.class.default_sanitization_method_for_class || # class level
             SanitizeAttributes::default_sanitization_method     # global
        if m && m.is_a?(Proc)
          m.call(txt)
        else
          raise SanitizeAttributes::NoSanitizationMethodDefined
        end
      end
  end
  
  # Thrown when sanitize! is called without a defined sanitization method at the class or global level
  class NoSanitizationMethodDefined < StandardError ; end
  
end