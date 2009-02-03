module SanitizeAttributes

  def sanitize_attributes(*args)
    include InstanceMethods
    extend ClassMethods

    cattr_accessor :sanitizable_attributes
  
    self.sanitizable_attributes ||= []
    self.sanitizable_attributes += args
    self.sanitizable_attributes.uniq!

    before_save :sanitize!
      
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
  end
    
  module InstanceMethods
    # sanitize! is the method that is called when a model is saved.
    # It can be called ot manually sanitize attributes.
    def sanitize!
      self.class.sanitizable_attributes.each do |attr_name|
        cleaned_text = process_text_via_sanitization_method(self.send(attr_name))
        self.send((attr_name.to_s + '='), cleaned_text)
      end
    end
    
    private
      def process_text_via_sanitization_method(txt)
        m = self.class.default_sanitization_method_for_class || SanitizeAttributes::default_sanitization_method
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