# jsonapi-realizer

  - [![Build](http://img.shields.io/travis-ci/krainboltgreene/jsonapi-realizer.svg?style=flat-square)](https://travis-ci.org/krainboltgreene/jsonapi-realizer)
  - [![Downloads](http://img.shields.io/gem/dtv/jsonapi-realizer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-realizer)
  - [![Version](http://img.shields.io/gem/v/jsonapi-realizer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-realizer)


This library handles incoming [json:api](https://www.jsonapi.org) payloads and turns them, via an adapter system, into data models for your business logic.

## Using

In order to use this library you'll want to have some models:

``` ruby
class Photo < ApplicationRecord
  belongs_to :photographer, class_name: "Profile"
end

class Profile < ApplicationRecord
  has_many :photos
end
```

*They don't have to be ActiveRecord* models, but we have built-in support for that library (adapter-based). Second you'll need some realizers:

``` ruby
class PhotoRealizer
  include JSONAPI::Realizer::Resource

  register :photos, class_name: "Photo", adapter: :active_record

  has_one :photographer, as: :profiles

  has :title
  has :src
end

class ProfileRealizer
  include JSONAPI::Realizer::Resource

  register :profiles, class_name: "Profile", adapter: :active_record

  has_many :photos

  has :name
end
```

You can define special properties on attributes and relationships realizers:

``` ruby
has_many :doctors, as: :users, includable: false

has :title, selectable: false
```

Once you've designed your resources, we just need to use them! In this example, we'll use controllers from Rails:

``` ruby
class PhotosController < ApplicationController
  def create
    realization = JSONAPI::Realizer.create(params, headers: request.headers)

    ProcessPhotosService.new(realization.model)

    render json: JSONAPI::Serializer.serialize(realization.model)
  end

  def index
    realization = JSONAPI::Realizer.index(params, headers: request.headers, type: :photos)

    render json: JSONAPI::Serializer.serialize(realization.models, is_collection: true)
  end
end
```

Notice that we pass `realization.model` to `ProcessPhotosService`, that's because `jsonapi-realizer` doesn't do the act of saving, creating, or destroying! We just ready up the records for you to handle (including errors).

### Policies

Most times you will want to control what a person sees when they as for your data. We have created interfaces for this use-case and we'll show how you can use pundit (or any PORO) to constrain your in/out.

First up is the policy itself:

``` ruby
class PhotoPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case
      when relation.with_role_state?(:administrator)
        relation
      when requester.with_onboarding_state?(:completed)
        relation.where(photographer: requester)
      else
        relation.none
      end
    end

    def sanitize(action, params)
      case action
      when :index
        params.permit(:fields, :include, :filter)
      else
        params
      end
    end
  end

  def index?
    requester.with_onboarding_state?(:completed)
  end
end
```

``` ruby
class PhotoRealizer
  include JSONAPI::Realizer::Resource

  register :photos, class_name: "Photo", adapter: :active_record

  has_one :photographer, as: :profiles

  has :title
  has :src
end
```

``` ruby
class PhotosController < ApplicationController
  def index
    # See: pundit for `policy_scope()`
    realization = JSONAPI::Realizer.index(
      policy(Photo).sanitize(:index, params),
      headers: request.headers,
      type: :posts,
      relation: policy_scope(Photo)
    )

    # See: pundit for `authorize()`
    authorize(realization.relation)

    render json: JSONAPI::Serializer.serialize(realization.models, is_collection: true)
  end
end
```

### Adapters

There are two core adapters:

  0. `:active_record`, which assumes an ActiveRecord-like interface.
  0. `:memory`, which assumes a `STORE` Hash-like on the model class.

An adapter must provide the following interfaces:

  0. `find_via`, describes how to find the model
  0. `find_many_via`, describes how to find many models
  0. `assign_attributes_via`, describes how to write a set of properties
  0. `assign_relationships_via`, describes how to write a set of relationships
  0. `includes_via`, describes how to eager include related models
  0. `sparse_fields_via`, describes how to only return certain fields

You can also provide custom adapter interfaces like below, which will use `active_record`'s `find_many_via`, `assign_relationships_via`, `update_via`, `includes_via`, and `sparse_fields_via`:

``` ruby
class PhotoRealizer
  include JSONAPI::Realizer::Resource

  register :photos, class_name: "Photo", adapter: :active_record

  adapter.find_via do |model_class, id|
    model_class.where { id == id or slug == id }.first
  end

  adapter.assign_attributes_via do |model, attributes|
    model.update_columns(attributes)
  end

  has_one :photographer, as: :profiles

  has :title
  has :src
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

I'm already using jsonapi-realizer and it's sister project jsonapi-serializers in a new gem of mine that allows services to be discoverable: [jsonapi-home](https://github.com/krainboltgreene/jsonapi-home).

### Notes

A successful JSON:API request can be annotated as:

```
JSONAPIRequest -> (BusinessLayer -> JSONAPIRequest -> (Record | Array<Record>)) -> JSONAPIResponse
```

The `jsonapi-serializers` library provides this shape:

```
JSONAPIRequest -> (Record | Array<Record>) -> JSONAPIResponse
```

But it leaves fetching/creating/updating/destroying the records up to you! This is where jsonapi-realizer comes into play, as it provides this shape:

```
BusinessLayer -> JSONAPIRequest -> (Record | Array<Record>)
```


## Installing

Add this line to your application's Gemfile:

    gem "jsonapi-realizer", "4.1.0"

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install jsonapi-realizer


## Contributing

  1. Read the [Code of Conduct](/CONDUCT.md)
  2. Fork it
  3. Create your feature branch (`git checkout -b my-new-feature`)
  4. Commit your changes (`git commit -am 'Add some feature'`)
  5. Push to the branch (`git push origin my-new-feature`)
  6. Create new Pull Request
