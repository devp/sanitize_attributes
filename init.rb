$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'sanitize_attributes'
ActiveRecord::Base.class_eval { extend SanitizeAttributes }