require 'test/unit'
require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

require "#{File.dirname(__FILE__)}/../init"

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :nachos do |t|
      t.column :foo, :string
      t.column :bar, :string
      t.column :baz, :string      
      t.column :fleem, :string
    end
  end
end  

def teardown_db
  ActiveRecord::Base.connection.drop_table(:nachos)
end

class Nacho < ActiveRecord::Base
  sanitize_attributes :foo
  sanitize_attributes :foo, :bar
  sanitize_attributes :baz
end

class RandomExceptionA < StandardError ; end
class RandomExceptionB < StandardError ; end

class SanitizeAttributesTest < Test::Unit::TestCase

  def setup
    setup_db
    # reinit the sanitization methods
    SanitizeAttributes.define_default_sanitization_method{|txt| txt.chop}
    Nacho.default_sanitization_method_for_class = nil
  end

  def teardown
    teardown_db
  end
  
  def test_proper_attributes_are_marked_as_sanitizable
    assert_equal [:foo, :bar, :baz], Nacho.sanitizable_attributes
  end
  
  def test_sanitizable_attributes_are_sanitized
    bad_string = "hello <script>alert(1)</script> world"
    n = Nacho.new(:foo => bad_string, :bar => bad_string, :baz=> bad_string, :fleem => bad_string)
    assert n.save!
    [:foo, :bar, :baz].each do |sym|
      assert_not_equal n.send(sym), bad_string
    end
    assert_equal bad_string, n.fleem
  end

  def test_definition_of_sanitization_methods
    SanitizeAttributes.default_sanitization_method = nil
    assert_raise(SanitizeAttributes::NoSanitizationMethodDefined){Nacho.create!}
    SanitizeAttributes.define_default_sanitization_method{ raise RandomExceptionA }
    assert_raise(RandomExceptionA){Nacho.create!}
    Nacho.define_default_sanitization_method_for_class{ raise RandomExceptionB }
    assert_raise(RandomExceptionB){Nacho.create!}
  end

end