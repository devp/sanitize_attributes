require 'sanitize_attributes/macros'
require 'sanitize_attributes/class_methods'
require 'sanitize_attributes/instance_methods'

module SanitizeAttributes
  include Macros
  
  class << self
    attr_accessor :default_sanitization_method    
  end
  
  # Thrown when sanitize! is called without a defined sanitization method at the class or global level
  class NoSanitizationMethodDefined < StandardError ; end  
end