# jsonapi-realizer

  - [![Build](http://img.shields.io/travis-ci/krainboltgreene/jsonapi-realizer.svg?style=flat-square)](https://travis-ci.org/krainboltgreene/jsonapi-realizer)
  - [![Downloads](http://img.shields.io/gem/dtv/jsonapi-realizer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-realizer)
  - [![Version](http://img.shields.io/gem/v/jsonapi-realizer.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-realizer)


This library handles incoming [json:api](https://www.jsonapi.org) payloads and turns them, via an adapter system, into data models for your business logic.

A successful JSON:API request can be annotated as:

```
JSONAPIRequest -> (BusinessLayer -> JSONAPIRequest -> (Record | Array<Record>)) -> JSONAPIResponse
```

The `jsonapi-serializers` library provides this shape:

```
JSONAPIRequest -> (Record | Array<Record>) -> JSONAPIResponse
```

But it leaves fetching/createing/updating/destroying the records up to you! This is where jsonapi-realizer comes into play, as it provides this shape:

```
BusinessLayer -> JSONAPIRequest -> (Record | Array<Record>)
```


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

  has_many :photos, as: :photos

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
    validate_parameters!
    authenticate_session!

    realization = JSONAPI::Realizer.create(params, headers: request.headers)

    ProcessPhotosService.new(realization.model)

    render json: JSONAPI::Serializer.serialize(record)
  end

  def index
    validate_parameters!
    authenticate_session!

    realization = JSONAPI::Realizer.index(params, headers: request.headers, type: :photos)

    # See: pundit for `authorize()`
    authorize realization.models

    # See: pundit for `policy_scope()`
    render json: JSONAPI::Serializer.serialize(policy_scope(record), is_collection: true)
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
  0. `create_via`, describes how to create the model
  0. `update_via`, describes how to update the model
  0. `includes_via`, describes how to eager include related models
  0. `sparse_fields_via`, describes how to only return certain fields

You can also provide custom adapter interfaces:

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

  adapter.create_via do |model|
    model.save!
    Rails.cache.write(model.cache_key, model)
  end

  has_one :photographer, as: :profiles

  has :title
  has :src
end
```


## Installing

Add this line to your application's Gemfile:

    gem "jsonapi-realizer", "2.0.0"

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
