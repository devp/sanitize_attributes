require 'sanitize_attributes/macros'
require 'sanitize_attributes/class_methods'
require 'sanitize_attributes/instance_methods'

module SanitizeAttributes
  include Macros
  
  class << self
    attr_accessor :default_sanitization_method    
    
    def hook!
      ActiveSupport.on_load(:active_record) { extend SanitizeAttributes }
    end
  end
  
  # Thrown when sanitize! is called without a defined sanitization method at the class or global level
  class NoSanitizationMethodDefined < StandardError ; end  

  if defined?(Rails)
    class Railtie < Rails::Railtie
      initializer("sanitize_attirbutes") { SanitizeAttributes.hook! }
    end
  end
end
