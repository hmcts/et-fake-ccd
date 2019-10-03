# EtFakeCcd

This gem can either be used as part of a test suite, providing a rack endpoint which can be loaded using
webmock.

OR

It can be used as a standalone server

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'et_fake_ccd'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install et_fake_ccd

## Usage

To run the server, use the command

```
et_fake_ccd start
```

## Testing Using This Fake Server

In general, this server will try to act like the normal CCD server but only in terms of accepting
and storing data.
So, it stores the data that the application gives it and it allows that data to be read back so
that a test suite or a manual process can validate that data.

It also has some basic validation so that it behaves in a similar way to CCD, but due to the complexity of
CCD itself, this app can never reflect exactly how it validates.

So, for this reason, deliberate errors are added to this server.

### Testing Using Deliberate Errors

When you think about it, if there was a way in the application to force an error, the developer 
would fix it !  So, we have to rely on having some deliberate errors where the data will pass through
all the validation within the app, but this server then knows to respond as if it was an error.

This will allow a tester or a test suite to provide the magic values that will trigger certain 
error scenarios and prove that the app behaves as expected under these error conditions.

This allows for basic testing and is not intended to be real life - only real life will give you 
real life errors.

For example, lets say we chose the name "Fred Bloggs" (sorry, the real fred bloggs - you must get fed
up with people using your name) to always respond with a 403 error saying "Forbidden".

Obviously, you could not force the app to get a real forbidden error, so as a tester or a developer 
writing test code, you would know from this readme that Fred Bloggs always causes a 403 error,
therefore you would expect the exported case in the admin to be marked with an error as an example.

So, here is a list of deliberate errors that Im sure will increase in size :-

#### Force a 403 error every time

* Use the lead claimant name "Force Error403"

#### Force a 403 error for just the first time

* Use the lead claimant name "Force Error403-<n>" (replace <n> with a number unique to your test)

#### Force a 504 error
* Use the lead claimant name "Force Error504"
* Use the lead claimant title of "Mr" to only force the error on the first occurence
* Use the lead claimant title of "Mrs" to force the error on every occurence

#### Force a 502 error
* Use the lead claimant name "Force Error502"
* Use the lead claimant title of "Mr" to only force the error on the first occurence
* Use the lead claimant title of "Mrs" to force the error on every occurence

#### Force a 422 error
* Use the lead claimant name "Force Error422"
* Use the lead claimant title of "Mr" to only force the error on the first occurence
* Use the lead claimant title of "Mrs" to force the error on every occurence




## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/et_fake_ccd.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
