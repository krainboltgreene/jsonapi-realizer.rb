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

    render json: JSONAPI::Serializer.serialize(record)
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
    realization = JSONAPI::Realizer.index(
      policy(Photo).sanitize(:index, params),
      headers: request.headers,
      type: :posts,
      relation: policy_scope(Photo)
    )

    # See: pundit for `policy_scope()`
    # See: pundit for `authorize()`
    render json: JSONAPI::Serializer.serialize(authorize(realization.models), is_collection: true)
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

    gem "jsonapi-realizer", "3.0.0"

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install jsonapi-realizer

### Rails

There's nothing extremely special about a rails application, but if you want to use jsonapi-realizer in development mode you'll probably want to turn on `eager_loading` (by setting it to `true` in `config/environments/development.rb`) or by adding `app/realizers` to the `eager_load_paths`.


## Contributing

  1. Read the [Code of Conduct](/CONDUCT.md)
  2. Fork it
  3. Create your feature branch (`git checkout -b my-new-feature`)
  4. Commit your changes (`git commit -am 'Add some feature'`)
  5. Push to the branch (`git push origin my-new-feature`)
  6. Create new Pull Request
