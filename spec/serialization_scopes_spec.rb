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
    expect(via_xml(some_record)).to eq({ "some_model" => { "name" => "Any", "currency" => "USD", "id" => some_record.id }})
  end

  it 'should scope to_json' do
    expect(via_json(some_record)).to eq({ "name" => "Any", "currency" => "USD", "id" => some_record.id })
  end

  it 'should apply default scope' do
    expect(via_json(other_record)).to eq({ "description" => "Other" })
  end

  it 'should allow to bypass default scope' do
    expect(via_json(some_record, :scope => false)).to eq({ "name" => "Any", "id" => some_record.id, "secret" => "key" })
  end

  it 'should allow to apply additional restrictions' do
    expect(via_json(some_record, :only => :name)).to eq({ "name" => "Any", "currency" => "USD" })
    expect(via_json(some_record, :methods => [])).to eq({ "name" => "Any", "id" => some_record.id })
  end

  it 'should not allow loosening scopes' do
    expect(via_json(some_record, :only => [:id, :secret]).keys).not_to include("secret")
    expect(via_json(some_record, :methods => [:discount, :currency]).keys).not_to include("discount")
    expect(via_json(some_record, :scope => :excepted, :except => :id).keys).not_to include("secret")
  end

  it 'should have separate behaviours for different scopes' do
    expect(via_json(some_record, :scope => :admin)).to eq({ "id" => some_record.id, "secret" => "key" })
  end

  it 'should fallback to default scope if invalid scope is given' do
    expect(via_json(some_record, :scope => :invalid)).to eq({ "name" => "Any", "currency" => "USD", "id" => some_record.id })
  end

  it "should pass through options it doesn't know about" do
    expect(some_record.to_xml(:root => "wow-root")).to include('<wow-root>')
    expect(some_record.to_xml(:scope => :wow_root)).to include('<wow-root>')
  end

  it 'should use default serialization scope when serialized as part of another object' do
    expect(via_json(:k => some_record)).to eq({ 'k' => { "name" => "Any", "currency" => "USD", "id" => some_record.id } })
  end

  it 'should pass the scope to the nested object so that they can use own settings' do
    expect(via_json(some_record, :scope => :nested)['another']).to eq({ 'description' => 'Random' })
  end

  it 'should correctly apply scopes to nested includes' do
    some_record.others.create :description => "New", :rank => 100
    expect(via_json(some_record, :include => :others)).to eq({ "name"=>"Any", "id"=>1, "currency"=>"USD", "others"=>[{ "description" => "New" }] })
  end

  it 'should propagate scopes to nested includes' do
    some_record.others.create :description => "New", :rank => 100
    expect(via_json(some_record, :include => :others, :scope => :admin)).
      to eq({ "id"=>1, "secret"=>"key", "others"=>[{ "description" => "New", "rank" => 100 }] })
  end

  it 'should inherit serialization options correctly' do
    expect(SomeModel.send(:serialization_scopes)[:default]).to eq({:only=>[:id, :name], :methods=>:currency})
    expect(SubModel.send(:serialization_scopes)[:default]).to eq({:only=>[:id, :name], :methods=>:currency})

    expect(SomeModel.send(:serialization_scopes)[:admin]).to eq({:only=>[:id, :secret]})
    expect(SubModel.send(:serialization_scopes)[:admin]).to eq({:only=>[:id, :secret, :token]})
  end

  it 'should correctly inherit serialization' do
    expect(via_json(sub_record)).to eq({ "name"=>"Any", "id"=>1, "currency"=>"USD" })
  end

  describe "additional option arguments" do

    it 'should not fail when passed nil options' do
      some_record.to_json(nil)
    end

    it 'should not tamper options' do
      original = {}
      expect { some_record.to_json(original) }.not_to change { original }
    end

    it 'should not tamper nested options' do
      original = { :only => :id, :key => { :other => :value } }
      expect { some_record.to_json(original) }.not_to change { original }
    end

  end
end
