module SanitizeAttributes
  module InstanceMethods
        
    # sanitize! is the method that is called when a model is saved.
    # It can be called to manually sanitize attributes.
    def sanitize!
      self.class.sanitizable_attributes.each do |attr_name|
        cleaned_text = process_text_via_sanitization_method(self.send(attr_name), attr_name)
        self.send((attr_name.to_s + '='), cleaned_text)
      end
    end
        
    private
      def process_text_via_sanitization_method(txt, attr_name = nil)
        return nil if txt.nil?
        sanitization_method =  self.class.sanitization_method_for_attribute(attr_name) || # attribute level
             self.class.default_sanitization_method_for_class || # class level
             SanitizeAttributes::default_sanitization_method     # global
        if sanitization_method && sanitization_method.is_a?(Proc)
          sanitization_method.call(txt)
        else
          raise SanitizeAttributes::NoSanitizationMethodDefined
        end
      end
  end
end