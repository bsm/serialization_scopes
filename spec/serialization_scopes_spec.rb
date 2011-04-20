require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SerializationScopes do

  before do
    conn = mock("Connection")
    conn.stub(:quote_table_name).and_return {|n| n }
    conn.stub(:quote).and_return {|n| n }

    ActiveRecord::Base.stub!(:establish_connection => nil, :connection => conn)
  end

  def serialize(object, options = {})
    ActiveSupport::JSON.decode(object.to_json(options))
  end

  def as_hash(options = {})
    serialize(SomeModel.new, options)
  end

  def options_for(custom_options)
    SomeModel.send(:scoped_serialization_options, custom_options)
  end

  it 'should scope to_xml' do
    Hash.from_xml(SomeModel.new.to_xml).should == { "some_model" => { "name" => "Any", "currency" => "USD", "id" => 1 }}
  end

  it 'should scope to_json' do
    as_hash.should == { "name" => "Any", "currency" => "USD", "id" => 1 }
  end

  it 'should apply default scope' do
    as_hash.should == { "name" => "Any", "currency" => "USD", "id" => 1 }
    serialize(AnotherModel.new).should == { "description" => "val" }
  end

  it 'should allow to bypass default scope' do
    as_hash(:scope => false).should == { "name" => "Any", "id" => 1, "secret" => "key" }
  end

  it 'should allow to apply additional restrictions' do
    as_hash(:only => :name).should == { "name" => "Any", "currency" => "USD" }
    as_hash(:methods => []).should == { "name" => "Any", "id" => 1 }
  end

  it 'should not allow loosening the scope' do
    as_hash(:only => [:id, :secret]).should == { "id" => 1, "currency" => "USD" }
  end

  it 'should have separate behaviours for different scopes' do
    as_hash(:scope => :admin).should == { "id" => 1, "secret" => "key" }
  end

  it 'should fallback to default scope if invalid scope is given' do
    as_hash(:scope => :invalid).should == { "name" => "Any", "currency" => "USD", "id" => 1 }
  end

  it "should not loosen the scoped 'only' attributes" do
    options_for(:scope => :default, :only => :secret)[:only].should == ["id", "name"]
  end

  it "should not loosen scoped 'methods'" do
    options_for(:scope => :default, :methods => [:some_method, :currency])[:methods].should == ["currency"]
  end

  it "should retain scoped 'expept' attributes" do
    options_for(:scope => :excepted, :except => :id)[:except].should == ["id", "secret"]
  end

  it "should pass through options it doesn't know about" do
    SomeModel.new.to_xml(:root => "wow-root").should include('<wow-root>')
    SomeModel.new.to_xml(:scope => :wow_root).should include('<wow-root>')
  end

  it 'should use default serialization scope when serialized as part of another object' do
    serialize(:k => SomeModel.new).should == { 'k' => { "name" => "Any", "currency" => "USD", "id" => 1 } }
  end

  it 'should keep scope option' do
    options_for(:scope => :nested)[:scope].should == :nested
  end

  it 'should pass the scope to the nested object so that they can use own settings' do
    as_hash(:scope => :nested)['another'].should == { 'description' => 'val' }
  end

  it 'should correctly apply scopes to nested includes' do
    model = SomeModel.new
    model.stub!(:others => [AnotherModel.new])
    serialize(model, :include => :others).should == { "name"=>"Any", "id"=>1, "currency"=>"USD", "others"=>[{ "description" => "val" }] }
  end

  it 'should be enabled on ActiveResource models' do
    res = SomeResource.new(:id => 1, :name => 'a name', :secret => 'some secret')
    serialize(res).should == { 'some_resource' => { 'id' => 1, 'name' => 'a name' } }
  end

  it 'should inherit serialization options correctly' do
    SomeModel.serialization_scopes[:admin].should == {:only=>[:id, :secret]}
    SubModel.serialization_scopes[:admin].should == {:only=>[:id, :secret, :token]}
  end

  describe "option arguments" do

    it 'should not fail when passed nil options' do
      options_for(nil).should == { :only => [:id, :name], :methods => :currency }
    end

    it 'should not tamper options' do
      original = {}
      SomeModel.new.to_json(original)
      original.should == {}
    end

    it 'should not tamper nested options' do
      original = { :only => :id }
      SomeModel.new.to_json(original)
      original.should == { :only => :id }
    end

  end

end