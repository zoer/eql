# Eql
[![Build Status](https://travis-ci.org/zoer/eql.svg)](https://travis-ci.org/zoer/eql)
[![Code Climate](https://codeclimate.com/github/zoer/eql/badges/gpa.svg)](https://codeclimate.com/github/zoer/eql)
[![Version Eye](https://www.versioneye.com/ruby/eql/badge.png)](https://www.versioneye.com/ruby/eql)
[![Inline docs](http://inch-ci.org/github/zoer/eql.png)](http://inch-ci.org/github/zoer/eql)
[![Gem Version](https://badge.fury.io/rb/eql.svg)](http://badge.fury.io/rb/eql)

Eql provides an ability to create raw DB queries via ERB templates.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eql'
```

## Usage

### Simple usage

```erb
# queries/insert.sql.erb
<% each do |item| %>
  INSERT INTO items (category, name)
    VALUES (<%= item.values_at(:category, :name).map { |i| quote(i) }.join(', ') %>)
    ON CONFILICT (category, name) DO NOTHING;
<% end %>
```

```ruby
b = Eql.new('queries')
b.execute(:insert, [{category: 'cars', name: 'BMW'}, {category: 'cars', name: 'AUDI'}])
```

### Inline templates

```ruby
b = Eql.template <<-ERB
  SELECT products
    FROM customer c
      LEFT JOIN products p ON (c.id = p.customer_id)
    WHERE c.id = <%= quote(id) %>
ERB
b.execute_params(id: 74)
```

### Usage with Rails

```ruby
# config/initializers/eql.rb

Eql.configure do |config|
  config.path = Rails.root.join('app/queries')
  config.adapter = :active_record
  config.cache_templates = !Rails.env.development?
end
```

```erb
# app/queries/fresh_items.sql.erb
SELECT *
  FROM items
  WHERE outdated IS DISTINCT FROM TRUE
  LIMIT <%= limit %>
```

```ruby
  outdated = Eql.execute(:fresh_items, limit: 10)
```

### Create your own adapter

```ruby
class BashAdapter < Eql::Adapters::Base
  def self.match?(conn)
    conn == :my_bash
  end

  def command
    "bash << eof\n" \
      "#{render}\n" \
    "eof\n"
  end


  def execute
    `#{command}`
  end
end

Eql.register_adapter(:my_bash, BashAdapter)

b = Eql.new(nil, :my_bash)
b.template <<-COMMAND
  mkdir -p <%= folder %>
  find . -name *.rb -not *_spec.rb -type f -exec mv {} <%= folder %> \;
  ls folder/*
COMMAND
b.execute_params(folder: 'units')
```

### Adapters
Now implemented only `ActiveRecord` adapter. Please, fill free to contribute on
a new adapter.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zoer/eql.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
