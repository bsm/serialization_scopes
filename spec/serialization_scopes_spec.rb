require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SerializationScopes do

  let :some_record do
    SomeModel.create! :name => 'Any', :secret => "key"
  end

  let :sub_record do
    SubModel.create! :name => 'Any', :secret => "key"
  end

  let :other_record do
    OtherModel.create! :description => 'Other', :some_id => some_record.id
  end

  let :some_resource do
    SomeResource.new :id => 1, :name => 'a name', :secret => 'some secret'
  end

  def via_xml(record, options = {})
    Hash.from_xml record.to_xml(options)
  end

  def via_json(record, options = {})
    ActiveSupport::JSON.decode record.to_json(options)
  end

  def options_for(custom_options)
    SomeModel.send(:scoped_serialization_options, custom_options)
  end

  it 'should scope to_xml' do
    via_xml(some_record).should == { "some_model" => { "name" => "Any", "currency" => "USD", "id" => some_record.id }}
  end

  it 'should scope to_json' do
    via_json(some_record).should == { "name" => "Any", "currency" => "USD", "id" => some_record.id }
  end

  it 'should apply default scope' do
    via_json(other_record).should == { "description" => "Other" }
  end

  it 'should allow to bypass default scope' do
    via_json(some_record, :scope => false).should == { "name" => "Any", "id" => some_record.id, "secret" => "key" }
  end

  it 'should allow to apply additional restrictions' do
    via_json(some_record, :only => :name).should == { "name" => "Any", "currency" => "USD" }
    via_json(some_record, :methods => []).should == { "name" => "Any", "id" => some_record.id }
  end

  it 'should not allow loosening scopes' do
    via_json(some_record, :only => [:id, :secret]).keys.should_not include("secret")
    via_json(some_record, :methods => [:discount, :currency]).keys.should_not include("discount")
    via_json(some_record, :scope => :excepted, :except => :id).keys.should_not include("secret")
  end

  it 'should have separate behaviours for different scopes' do
    via_json(some_record, :scope => :admin).should == { "id" => some_record.id, "secret" => "key" }
  end

  it 'should fallback to default scope if invalid scope is given' do
    via_json(some_record, :scope => :invalid).should == { "name" => "Any", "currency" => "USD", "id" => some_record.id }
  end

  it "should pass through options it doesn't know about" do
    some_record.to_xml(:root => "wow-root").should include('<wow-root>')
    some_record.to_xml(:scope => :wow_root).should include('<wow-root>')
  end

  it 'should use default serialization scope when serialized as part of another object' do
    via_json(:k => some_record).should == { 'k' => { "name" => "Any", "currency" => "USD", "id" => some_record.id } }
  end

  it 'should pass the scope to the nested object so that they can use own settings' do
    via_json(some_record, :scope => :nested)['another'].should == { 'description' => 'Random' }
  end

  it 'should correctly apply scopes to nested includes' do
    some_record.others.create :description => "New"
    via_json(some_record, :include => :others).should == { "name"=>"Any", "id"=>1, "currency"=>"USD", "others"=>[{ "description" => "New" }] }
  end

  it 'should inherit serialization options correctly' do
    SomeModel.send(:serialization_scopes)[:default].should == {:only=>[:id, :name], :methods=>:currency}
    SubModel.send(:serialization_scopes)[:default].should == {:only=>[:id, :name], :methods=>:currency}

    SomeModel.send(:serialization_scopes)[:admin].should == {:only=>[:id, :secret]}
    SubModel.send(:serialization_scopes)[:admin].should == {:only=>[:id, :secret, :token]}
  end

  it 'should correctly inherit serialization' do
    via_json(sub_record).should == { "name"=>"Any", "id"=>1, "currency"=>"USD" }
  end

  it 'should be enabled on ActiveResource models' do
    via_json(some_resource).should == { 'some_resource' => { 'id' => 1, 'name' => 'a name' } }
  end

  describe "additional option arguments" do

    it 'should not fail when passed nil options' do
      some_record.to_json(nil)
    end

    it 'should not tamper options' do
      original = {}
      lambda { some_record.to_json(original) }.should_not change { original }
    end

    it 'should not tamper nested options' do
      original = { :only => :id, :key => { :other => :value } }
      lambda { some_record.to_json(original) }.should_not change { original }
    end

  end
end