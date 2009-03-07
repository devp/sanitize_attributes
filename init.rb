require 'sanitize_attributes'
ActiveRecord::Base.class_eval { extend SanitizeAttributes }