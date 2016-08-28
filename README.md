# Activerecord::WrappedTransaction

Wrap transactions in a way that lets you easily detect if the block succeeded or rolled back
for complex, procedural usage with an object interface.

It supports MySQL, PostgreSQL, and SQLite.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-wrapped_transaction'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-wrapped_transaction

## Usage

```ruby
ActiveRecord::Base.include ActiveRecord::WrappedTransaction

wrapped_result = ActiveRecord::Base.wrapped_transaction do
  # Do something
end

wrapped_result.result # 
wrapped_result.success?
wrapped_result.rolled_back?
```

You can pass the same options you would to `ActiveRecord::Base.transaction`: `requires_new`, `isolation`, `joinable`

## Todo

* Test coverage for multiple connections (should be supported, but not guaranteed)
* `Maybe` monad support for being able to execute complex logic more fluently.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scryptmouse/activerecord-wrapped_transaction. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

