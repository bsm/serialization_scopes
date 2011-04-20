require File.expand_path(File.dirname(__FILE__) + '/helper')

describe SerializationScopes do

  before do
    ActiveRecord::Base.stub!(:establish_connection)
  end

  class SomeModel < ActiveRecord::Base
    serialization_scope :default, :only => [:id, :name], :methods => :currency
    serialization_scope :admin, :only => [:id, :secret]
    serialization_scope :excepted, :except => [:secret]
    serialization_scope :wow_root, :root => 'wow-root'
    serialization_scope :nested, :only => [:id, :name], :methods => :another
    after_initialize    :set_defaults

    def self.columns
      @columns ||= [
        ActiveRecord::ConnectionAdapters::Column.new('id', nil, 'integer'),
        ActiveRecord::ConnectionAdapters::Column.new('name', nil, 'string'),
        ActiveRecord::ConnectionAdapters::Column.new('secret', nil, 'string')
      ]
    end

    def set_defaults
      self.id     = 1
      self.name   = 'Any'
      self.secret = 'key'
    end

    def currency
      'USD'
    end

    def another
      AnotherModel.new
    end
  end

  class SubModel < SomeModel
    serialization_scope :admin, :only => [:id, :secret, :token]

    def token
      "ABCD"
    end
  end

  class AnotherModel < ActiveRecord::Base
    serialization_scope :default, :only => :name
    after_initialize    :set_defaults

    def self.columns
      @columns ||= [
        ActiveRecord::ConnectionAdapters::Column.new('id', nil, 'integer'),
        ActiveRecord::ConnectionAdapters::Column.new('name', nil, 'string')
      ]
    end

    # Method override
    def to_json(options={})
      super(options)
    end

    def set_defaults
      self.name = 'val'
    end
  end

  class SomeResource < ActiveResource::Base
    self.site = 'http://example.com'

    schema do
      integer 'id'
      string 'name', 'secret'
    end

    serialization_scope :default, :only => [:id, :name]
  end

  it 'should constraint to_xml' do
    SomeModel.new.to_xml.should == %(<?xml version="1.0" encoding="UTF-8"?>
<some-model>
  <name>Any</name>
  <id type="integer">1</id>
  <currency>USD</currency>
</some-model>
)
  end

  def serialize(object, options = {})
    ActiveSupport::JSON.decode(object.to_json(options))
  end

  def as_hash(options = {})
    serialize(SomeModel.new, options)
  end

  it 'should constraint to_json' do
    as_hash.should == { "name" => "Any", "currency" => "USD", "id" => 1 }
  end

  it 'should allow further restrictions' do
    as_hash(:only => :name).should == { "name" => "Any", "currency" => "USD" }
    as_hash(:methods => []).should == { "name" => "Any", "id" => 1 }
  end

  it 'should deny extensions if (default) scope is selected' do
    as_hash(:only => [:id, :secret]).should == { "id" => 1, "currency" => "USD" }
  end

  it 'should have separate behaviours for different scopes' do
    as_hash(:scope => :admin).should == { "id" => 1, "secret" => "key" }
  end

  it 'should fallback to default scope if invalid scope is given' do
    as_hash(:scope => :invalid).should == { "name" => "Any", "currency" => "USD", "id" => 1 }
  end

  def options_for(custom_options)
    SomeModel.send(:scoped_serialization_options, custom_options)
  end

  it 'should not relax the specified column list (when list is set by :only option)' do
    options_for(:scope => :default, :only => [:id, :secret])[:only].should == [:id]
    options_for(:scope => :default, :only => :secret)[:only].should == []
    options_for(:scope => :default, :methods => [:some_method, :currency])[:methods].should == [:currency]
  end

  it 'should restrict the specified column list (when list is set by :except option)' do
    options_for(:scope => :excepted, :except => :id)[:except].should == [:id, :secret]
  end

  it "should pass through options it doesn't know about" do
    SomeModel.new.to_xml(:root => "wow-root").should include('<wow-root>')
    SomeModel.new.to_xml(:scope => :wow_root).should include('<wow-root>')
  end

  it 'should use default serialization scope when serialized as part of another object' do
    serialize(:k => SomeModel.new).should == { 'k' => { "name" => "Any", "currency" => "USD", "id" => 1 } }
  end

  it 'should not fail when passed nil options' do
    options_for(nil).should == { :only => [:id, :name], :methods => :currency }
  end

  it 'should keep scope option' do
    options_for(:scope => :nested)[:scope].should == :nested
  end

  it 'should pass the scope to the nested object so that they can use own settings' do
    as_hash(:scope => :nested)['another'].should == { 'name' => 'val' }
  end

  it 'should be enabled on ActiveResource models' do
    res = SomeResource.new(:id => 1, :name => 'a name', :secret => 'some secret')
    serialize(res).should == { 'some_resource' => { 'id' => 1, 'name' => 'a name' } }
  end

  it 'should allow custom serialization methods' do
    serialize(AnotherModel.new).should == {'name' => 'val'}
  end

  it 'should inherit scopes correctly' do
    serialize(AnotherModel.new).should == {'name' => 'val'}
  end

  it 'should not tamper options' do
    original = {}
    SomeModel.new.to_json(original)
    original.should == {}
  end

  it 'should not tamper nested options' do
    SomeModel.serialization_scopes[:admin].should == {:only=>[:id, :secret]}
    SubModel.serialization_scopes[:admin].should == {:only=>[:id, :secret, :token]}
  end

end