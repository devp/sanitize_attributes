require "#{File.dirname(__FILE__)}/test_helper"

ActiveRecord::Schema.define do
  create_table :articles do |t|
    t.column :title, :string
    t.column :body, :string
    t.column :review, :string
  end
end

ActiveRecord::Schema.define do
  create_table :albums do |t|
    t.column :title, :string
    t.column :artist, :string
    t.column :rating, :string
  end
end

class Article < ActiveRecord::Base
  sanitize_attributes :title, :body
end

class Album < ActiveRecord::Base
  sanitize_attributes :title, :artist
end

class SanitizeAttributesTest < Test::Unit::TestCase

  context "Two classes with #sanitizable_attributes in their defnition" do
    should "not share the same sanitizable_attributes" do
      assert_not_equal Album.sanitizable_attributes, Article.sanitizable_attributes
    end
  end
  
  context "#sanitize_attributes" do
    should "mark expected attributes as sanitizable" do
      assert_equal Set.new([:title, :body]), Set.new(Article.sanitizable_attributes)
    end
    
    should "not create duplicates entries" do
      Article.sanitize_attributes :title
      assert_equal Set.new([:title, :body]), Set.new(Article.sanitizable_attributes)
    end
  end
  
  context "given an undefined sanitization methods" do
    setup do
      SanitizeAttributes.default_sanitization_method = nil
      Article.default_sanitization_method_for_class = nil
    end
    
    should "raise NoSanitizationMethodDefined on #save!" do
      assert_raise(SanitizeAttributes::NoSanitizationMethodDefined) do
        Article.create!(:title => "This Article")
      end
    end
  end
    
  context "given a defined default sanitization method" do
    setup do
      SanitizeAttributes.default_sanitization_method = lambda{|s| s.generic_sanitize}
      Album.default_sanitization_method_for_class = nil
      Article.default_sanitization_method_for_class = nil
    end
    
    should "use the default method on #save!, changing only the sanitizable attribute" do
      title = "This Article"
      title.expects(:generic_sanitize).returns("sanitized")
      article = Article.new(:title => title, :review => "do not change")
      assert article.save!
      assert_equal "sanitized", article.title
      assert_equal "do not change", article.review
    end
    
    should "not sanitize nil attributes" do
      title = nil
      body = "Lorem Ipsum"
      title.expects(:generic_sanitize).never
      body.expects(:generic_sanitize).once
      article = Article.new(:title => title, :body => body)
      assert article.save!
    end
    
    context "and defined class-level sanitization methods" do
      setup do
        Album.default_sanitization_method_for_class = lambda{Album.album_sanitizer}
        Article.default_sanitization_method_for_class = lambda{Article.article_sanitizer}
      end
      
      should "use the appropriate method for each class" do
        Album.expects(:album_sanitizer).times(2)
        Album.create!(:title => "This Album", :artist => "Rock Star", :rating => "great")
    
        Article.expects(:article_sanitizer).times(2)
        Article.create!(:title => "This Article", :body => "Lorem Ipsum", :review => "awesome")
      end
      
      context "and further attribute-level sanitization" do
        setup do
          Album.sanitize_attributes :artist do
            Album.artist_sanitizer
          end
        end
        
        teardown do
          Album.sanitize_attributes :artist # unsetting the attribute-specific block
        end
        
        should "use the appropriate method for each attribute" do
          Album.expects(:album_sanitizer).once
          Album.expects(:artist_sanitizer).once
          Album.create!(:title => "This Album", :artist => "Rock Star", :rating => "great")
        end        
      end
    end
    
  end
    
end