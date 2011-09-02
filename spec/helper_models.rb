ActiveRecord::Base.configurations["test"] = { 'adapter' => 'sqlite3', 'database' => ":memory:" }

RSpec.configure do |c|
  c.before(:each) do
    base = ActiveRecord::Base
    base.establish_connection(:test)
    base.connection.create_table :some_models do |t|
      t.string :name
      t.string :type
      t.string :secret
    end
    base.connection.create_table :other_models do |t|
      t.integer :some_id
      t.string :description
    end
  end
end

class SomeModel < ActiveRecord::Base
  has_many :others, :class_name => 'OtherModel', :foreign_key => :some_id

  serialization_scope :default, :only => [:id, :name], :methods => :currency
  serialization_scope :admin, :only => [:id, :secret]
  serialization_scope :excepted, :except => [:secret]
  serialization_scope :wow_root, :root => 'wow-root'
  serialization_scope :nested, :only => [:id, :name], :methods => :another

  def currency
    'USD'
  end

  def discount
    20
  end

  def another
    @another ||= others.create! :description => "Random"
  end
end

class SubModel < SomeModel
  serialization_scope :admin, :only => [:id, :secret, :token]

  def token
    "ABCD"
  end
end

class OtherModel < ActiveRecord::Base
  belongs_to :some, :class_name => 'SomeModel', :foreign_key => :some_id

  serialization_scope :default, :only => :description
end

class SomeResource < ActiveResource::Base
  self.site = 'http://example.com'

  schema do
    integer 'id'
    string 'name', 'secret'
  end

  serialization_scope :default, :only => [:id, :name]
end
