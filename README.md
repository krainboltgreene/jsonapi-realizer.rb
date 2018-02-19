# jsonapi-marshal

  - [![Build](http://img.shields.io/travis-ci/krainboltgreene/jsonapi-marshal.svg?style=flat-square)](https://travis-ci.org/krainboltgreene/jsonapi-marshal)
  - [![Downloads](http://img.shields.io/gem/dtv/jsonapi-marshal.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-marshal)
  - [![Version](http://img.shields.io/gem/v/jsonapi-marshal.svg?style=flat-square)](https://rubygems.org/gems/jsonapi-marshal)


TODO: Write a gem description


## Using

``` ruby
class Photo
  include ActiveModel::Model

  attr_accessor :id
  attr_accessor :title
  attr_accessor :src
  attr_accessor :photographer
end

class People
  include ActiveModel::Model

  attr_accessor :id
  attr_accessor :name
  attr_accessor :posts
end
```

``` ruby
class PhotoMarshal < JSONAPI::Marshal::Resource
  represents :photos, class_name: "Photo"

  has_one :photographer, as: :people

  has :title
  has :src
end

class PeopleMarshal < JSONAPI::Marshal::Resource
  represents :people, class_name: "People"

  has :name
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
