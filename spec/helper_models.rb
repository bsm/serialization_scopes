class SomeModel < ActiveRecord::Base
  def self.columns
    @columns ||= [
      ActiveRecord::ConnectionAdapters::Column.new('id', nil, 'integer'),
      ActiveRecord::ConnectionAdapters::Column.new('name', nil, 'string'),
      ActiveRecord::ConnectionAdapters::Column.new('secret', nil, 'string')
    ]
  end

  has_many :others, :class_name => 'AnotherModel', :foreign_key => :some_id

  serialization_scope :default, :only => [:id, :name], :methods => :currency
  serialization_scope :admin, :only => [:id, :secret]
  serialization_scope :excepted, :except => [:secret]
  serialization_scope :wow_root, :root => 'wow-root'
  serialization_scope :nested, :only => [:id, :name], :methods => :another

  after_initialize    :set_defaults

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
  def self.columns
    @columns ||= [
      ActiveRecord::ConnectionAdapters::Column.new('id', nil, 'integer'),
      ActiveRecord::ConnectionAdapters::Column.new('some_id', nil, 'integer'),
      ActiveRecord::ConnectionAdapters::Column.new('description', nil, 'string')
    ]
  end

  belongs_to :some, :class_name => 'SomeModel', :foreign_key => :some_id

  serialization_scope :default, :only => :description
  after_initialize    :set_defaults

  def set_defaults
    self.description = 'val'
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
