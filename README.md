# Activerecord::WrappedTransaction

Wrap transactions in an object-oriented way so that you can tell if an individual transaction
succeeded, rolled back, or was cancelled.

Supported versions and databases:

* Rails 5 and 6
* MySQL, PostgreSQL, and SQLite
* Ruby 2.4, 2.5, 2.6, 2.7

## Installation

Add this line to your application's Gemfile:

```ruby
gem "activerecord-wrapped_transaction", "~> 0.9"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-wrapped_transaction -v "~> 0.9"

## Usage

Contrived example:

```ruby
ActiveRecord::Base.include ActiveRecord::WrappedTransaction

wrapped_result = ActiveRecord::Base.wrapped_transaction do |context|
  user = User.create! attributes 

  failable_result = OptionalThing.wrapped_transaction requires_new: true do
    # This can fail, but we'll let it
    OptionalThing.create! user: user, foo: "bar"
  end

  failable_result.rolled_back? # => true

  # There is also a shorthand that uses the optional context helper
  # This creates a new transaction layer that has requires_new: true
  # set implicitly.
  other_failable = context.maybe do
	Something.explodes!
  end

  other_failable.rolled_back? # => true

  cancelled = context.maybe do |inner_context|
	inner_context.cancel! "arbitrarily"
  end

  cancelled.cancelled? # => true
  cancelled.rolled_back? # => true
  cancelled.cancellation_reason # => "arbitrarily"

  # return our result
  user
end

wrapped_result.result # => user
wrapped_result.success? # => true
wrapped_result.rolled_back? # => false
```

You can pass the same options you would to `ActiveRecord::Base.transaction`: `requires_new`, `isolation`, `joinable`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scryptmouse/activerecord-wrapped_transaction. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
