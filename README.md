# jsonapi-marshal

  - [![Build](http://img.shields.io/travis-ci/krainboltgreene/jsonapi-marshal.svg?style=flat-square)](https://travis-ci.org/krainboltgreene/jsonapi-marshal)
  - [![Downloads](http://img.shields.io/gem/dtv/jsonapi-marshal.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-marshal)
  - [![Version](http://img.shields.io/gem/v/jsonapi-marshal.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-marshal)


This library handles incoming [json:api](https://www.jsonapi.org) payloads and turns them, via an adapter system, into data models for your business logic.


## Using

``` ruby
class Photo < ApplicationRecord
  belongs_to :photographer, class_name: "Profile"
end

class Profile < ApplicationRecord
  has_many :photos
end

class PhotoMarshal
  include JSONAPI::Marshal::Resource

  adapter JSONAPI::Marshal::ActiveRecord

  represents :photos, class_name: "Photo"

  has_one :photographer, as: :profiles

  has :title
  has :src
end

class ProfileMarshal
  include JSONAPI::Marshal::Resource

  adapter JSONAPI::Marshal::ActiveRecord

  represents :profiles, class_name: "Profile"

  has_many :photos, as: :photos

  has :name
end
```

``` ruby
class PhotosController < ApplicationController
  def create
    @record = JSONAPI::Marshal.create(params, headers: request.headers)
  end
end
```


## Installing

Add this line to your application's Gemfile:

    gem "jsonapi-marshal", "1.0.0"

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install jsonapi-marshal


## Contributing

  1. Read the [Code of Conduct](/CONDUCT.md)
  2. Fork it
  3. Create your feature branch (`git checkout -b my-new-feature`)
  4. Commit your changes (`git commit -am 'Add some feature'`)
  5. Push to the branch (`git push origin my-new-feature`)
  6. Create new Pull Request
