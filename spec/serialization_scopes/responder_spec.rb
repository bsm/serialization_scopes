require 'spec_helper'

describe SerializationScopes::Responder do

  class FakeResponder

    def display(*args)
      args.extract_options!
    end

    def controller
      @controller ||= FakeController.new
    end
  end

  class ActualResponder < FakeResponder
    include SerializationScopes::Responder
  end

  class FakeController
    def serialization_scope
      :author
    end
    protected :serialization_scope
  end

  it 'should apply scopes by default' do
    ActualResponder.new.display(nil, {}).should == { :scope => :author }
  end

end
