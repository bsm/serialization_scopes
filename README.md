Serialization Scopes
====================

Define scopes for XML/JSON serialization of your ActiveRecord models.

### In your models

Serialization Scopes extends ActiveRecord and provides a `serialization_scope`
class method for defining custom scopes. Example:

    # Column names: id, title, body, date, personal_notes, comments_count, author_id
    class Article < ActiveRecord::Base
      has_many :comments

      serialization_scope :author, :except => [:comments_count]
      serialization_scope :reader, :only => [:title, :body, :date], :include => [:comments]
    end

### Scoping serialization output

Scopes can be applied as options to the *usual* `#to_xml` and `#to_json`
methods. Examples:

Apply the default scope. This can be overridden in models via
`serialization_scope :default, ...`:

    Article.first.to_json
    # => {"id":1,"title":"Hello","body":"World","date":"2010-01-01","personal_notes":"Author's notes","comments_count":3,"author_id":1}

Apply a custom scope:

    Article.first.to_json(:scope => :author)
    # => {"id":1,"title":"Hello","body":"World","date":"2010-01-01","personal_notes":"Author's notes","author_id":1}

Custom scopes can still be extended/overridden:

    Article.first.to_json(:scope => :author, :only => [:title])
    # => {"title":"Hello"}

### In your controllers

Serialization Scopes comes with a responder which you can include to your own.
Create your own responder:

    # lib/my_responder.rb
    class MyResponder < ActionController::Responder
      include SerializationScopes::Responder
    end

And then you need to configure your application to use it:

    # app/controllers/application_controller.rb
    require "my_responder"

    class ApplicationController < ActionController::Base
      self.responder = MyResponder
    end

In your controllers, then simply define a protected `serialization_scope`
method. Example:

    # app/controllers/articles_controller.rb
    class ArticlesController < ApplicationController
      respond_to :html, :xml, :json

      def show
        @article = Article.find params[:id]
        respond_with @article
      end

      protected

      	def serialization_scope
      	  @article && @article.author == current_user ? :author : :reader
      	end

    end

## License

(The MIT License)

Copyright (c) 2011 Dimitrij Denissenko

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
