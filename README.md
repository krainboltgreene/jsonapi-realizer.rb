# jsonapi-realizer

  - [![Build](http://img.shields.io/travis-ci/krainboltgreene/jsonapi-realizer.rb.svg?style=flat-square)](https://travis-ci.org/krainboltgreene/jsonapi-realizer.rb)
  - [![Downloads](http://img.shields.io/gem/dtv/jsonapi-realizer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-realizer)
  - [![Version](http://img.shields.io/gem/v/jsonapi-realizer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-realizer)


This library handles incoming [json:api](https://www.jsonapi.org) payloads and turns them, via an adapter system, into native data models. While designed with rails in mind, this library doesn't require rails to use.


- [ ] Detail include(JSONAPI::Realizer::Controller)
- [ ] Basic ActionController::API
- [ ] rescue_from JSONAPI::Realizer::Error::MissingAcceptHeader, with: :missing_accept_header
- [ ] rescue_from JSONAPI::Realizer::Error::InvalidAcceptHeader, with: :invalid_accept_header


## Using

In order to use this library you'll want to have some models:


``` ruby
class Profile < ApplicationRecord
  has_many :photos
end
```

``` ruby
class Photo < ApplicationRecord
  belongs_to :photographer, class_name: "Profile"
end
```

*Note: They don't have to be ActiveRecord models, but we have built-in support for that library (via an adapter).*

Second you'll need some realizers:

``` ruby
class ProfileRealizer
  include JSONAPI::Realizer::Resource

  type :profiles, class_name: "Profile", adapter: :active_record

  has_many :photos, class_name: "PhotoRealizer"

  has :name
end
```

``` ruby
class PhotoRealizer
  include JSONAPI::Realizer::Resource

  type :photos, class_name: "Photo", adapter: :active_record

  has_one :photographer, as: :profiles, class_name: "ProfileRealizer"

  has :title
  has :src
end
```

Now that we have these we can invoke them in the controller:

``` ruby
class PhotosController < ApplicationController
  def create
    realizer = PhotoRealizer.new(
      :intent => :create,
      :parameters => params,
      :headers => request.headers
    )

    realizer.object.save!

    render json: realizer.object.to_json
  end

  def index
    realizer = PhotoRealizer.new(
      :intent => :index,
      :parameters => params,
      :headers => request.headers
    )

    render json: realizer.object.to_json
  end
end
```

Notice that we have to handle creating the model ourselves with `realizer.object.save!`. `jsonapi-realizer` doesn't act on a request, it only prepares you to act on the request.


### Adapters

There are two core adapters:

  0. `:active_record`, which assumes an ActiveRecord-like interface.
  0. `:memory`, which assumes a `STORE` Hash-like on the model class.

An adapter must provide the following interfaces:

  0. `find_many(scope)`, describes how to find many records
  0. `find_one(scope, id)`, describes how to find one record
  0. `filtering(scope, filters)`, describes how to filter records by a set of properties
  0. `sorting(scope, sorts)`, describes how to sort records
  0. `paginate(scope, per, offset)`, describes how to page records
  0. `write_attributes(model, attributes)`, describes how to write a set of properties
  0. `write_relationships(model, relationships)`, describes how to write a set of relationships
  0. `include_relationships(scope, includes)`, describes how to eager include related models

You can also provide custom adapter interfaces like below:

``` ruby
JSONAPI::Realizer.configuration do |let|
  let.adapter_mappings = {
    active_record_postgres_pagination: PostgresActiveRecordPaginationAdapter
  }
end
```

``` ruby
module PostgresActiveRecordPaginationAdapter < JSONAPI::Realizer::Adapter::ActiveRecord
  def paginate(scope, per, offset)
    scope.offset(offset).limit(per)
  end
end
```

``` ruby
class PhotoRealizer
  include JSONAPI::Realizer::Resource

  type :photos, class_name: "Photo", adapter: :active_record_postgres_pagination
end
```

### rails

If you want to use jsonapi-realizer in development mode you'll want to turn on `eager_loading` (by setting it to `true` in `config/environments/development.rb`) or by adding `app/realizers` to the `eager_load_paths`.


### rails and pundit and jsonapi-serializers

While this gem contains nothing specifically targeting rails or pundit or [jsonapi-serializers](https://github.com/fotinakis/jsonapi-serializers) (a fantastic gem) I've already written some seamless integration code. This root controller will handle exceptions in a graceful way and also give you access to a clean interface for serializing:

``` ruby
module V1
  class ApplicationController < ::ApplicationController
    include Pundit

    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index

    rescue_from JSONAPI::Realizer::Error::MissingAcceptHeader, with: :missing_accept_header
    rescue_from JSONAPI::Realizer::Error::InvalidAcceptHeader, with: :invalid_accept_header
    rescue_from Pundit::NotAuthorizedError, with: :access_not_authorized

    private def missing_accept_header
      head :not_acceptable
    end

    private def invalid_accept_header
      head :not_acceptable
    end

    private def access_not_authorized
      head :unauthorized
    end

    private def pundit_user
      current_account
    end

    private def serialize(realization)
      JSONAPI::Serializer.serialize(
        if realization.respond_to?(:models) then realization.models else realization.model end,
        is_collection: realization.respond_to?(:models),
        meta: serialized_metadata,
        links: serialized_links,
        jsonapi: serialized_jsonapi,
        fields: serialized_fields(realization),
        include: serialized_includes(realization),
        namespace: ::V1
      )
    end

    private def serialized_metadata
      {
        api: {
          version: "1"
        }
      }
    end

    private def serialized_links
      {
        discovery: {
          href: "/"
        }
      }
    end

    private def serialized_jsonapi
      {
        version: "1.0"
      }
    end

    private def serialized_fields(realization)
      realization.fields if realization.fields.any?
    end

    private def serialized_includes(realization)
      realization.includes if realization.includes.any?
    end
  end
end
```

You can see this resource controller used below:

``` ruby
module V1
  class AccountsController < ::V1::ApplicationController
    def index
      realization = JSONAPI::Realizer.index(
        policy(Account).sanitize(:index, params),
        headers: request.headers,
        scope: policy_scope(Account),
        type: :accounts
      )

      authorize realization.relation

      render json: serialize(realization)
    end

    def create
      realization = JSONAPI::Realizer.create(
        policy(Account).sanitize(:create, params),
        headers: request.headers,
        scope: policy_scope(Account)
      )

      authorize realization.relation

      render json: serialize(realization)
    end
  end
end
```

### jsonapi-home

I'm already using jsonapi-realizer and it's sister project jsonapi-serializers in a new gem of mine that allows services to be discoverable: [jsonapi-home](https://github.com/krainboltgreene/jsonapi-home.rb).


## Installing

Add this line to your application's Gemfile:

    $ bundle add jsonapi-realizer

Or install it yourself with:

    $ gem install jsonapi-realizer


## Contributing

  1. Read the [Code of Conduct](/CONDUCT.md)
  2. Fork it
  3. Create your feature branch (`git checkout -b my-new-feature`)
  4. Commit your changes (`git commit -am 'Add some feature'`)
  5. Push to the branch (`git push origin my-new-feature`)
  6. Create new Pull Request
