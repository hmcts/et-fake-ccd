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

or if you want to specify which json schema file you want to use for validation (no default
is provided as it changes in CCD regularly using the config file), you can either specify the otion
'create_case_schema' as shown below OR you can specify the environment variable ET_FAKE_CCD_CREATE_CASE_SCHEMA instead.

The 'master' definition of this file is here https://raw.githubusercontent.com/hmcts/et-ccd-export/develop/spec/json_schemas/case_create.json
so use wget or curl etc.. or just a browser to download it if you want real life validation.

```
et_fake_ccd start --create_case_schema=<path_to_file>
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

* Use the lead claimant name "Force ErrorForbidden"

#### Force a 403 error for just the first time

* Use the lead claimant name "Force ErrorForbidden-<n>" (replace <n> with a number unique to your test)

#### Force a 504 error
* Use the lead claimant name "Force ErrorGatewayTimeout"
* Use the lead claimant title of "Mr" to only force the error on the first occurence
* Use the lead claimant title of "Mrs" to force the error on every occurence

#### Force a 502 error
* Use the lead claimant name "Force ErrorBadGateway"
* Use the lead claimant title of "Mr" to only force the error on the first occurence
* Use the lead claimant title of "Mrs" to force the error on every occurence

#### Force a 422 error
* Use the lead claimant name "Force ErrorUnprocessableEntity"
* Use the lead claimant title of "Mr" to only force the error on the first occurence
* Use the lead claimant title of "Mrs" to force the error on every occurence

### Improved Deliberate Error Control

The above deliberate error mechanism worked, it does not give quite enough control.

A new system has therefore been developed that you can use instead of it.

This uses special configuration settings in the 'External System' in the admin.

There are 2 key entries

1. 'extra_headers'
2. 'send_request_id'

#### extra_headers

'extra_headers' should contain a JSON encoded value of a hash.  Each entry in the hash is a header
to add to every request to this fake ccd server.

##### force_failures header

The force_failures header should contain a hash which looks like this

```json
    {
      "idam_stage": { ..spec.. },
      "token_stage": { ..spec.. },
      "data_stage": { ..spec.. }
    } 

```

The 4 different stages give control of when the error will happen

The 'idam_stage' is the stage of the transaction when an IDAM token is requested.
However, this does not happen all of the time because IDAM tokens are cached, so
you will not necessarily see one request per transaction.

The 'token_stage' is used in most transactions such as case creation
where a 'token' is the starting stage - which then allows the case
to be created against this token.

The 'documents' stage is used in transactions that require documents uploading before the
case is created.

The 'data_stage' is used in most transactions and means the actual data
creation.

The '..spec..' is the same irrespective of which stage and is described below:

```json
    [a, b, c]
```

a, b, c (you can specify as many as you want here, not just 3)
are http response codes for the 'nth' request.  i.e. the first argument
is for the first request, the 2nd for the 2nd etc..
The special value of 0 means allow the normal response and do not force an
error - allowing for patterns such as error on the 1st, 2nd and 5th.

Any non zero value is the http status code to respond with.

#### send_request_id

'send_request_id' should be set to 'true' to enable a request identifier to be sent with every
request to this fake ccd server.  This identifier is unique to a particular export from the main system,
so it will persist even across retries of the same export.

This is then used to assist in special rules where errors are forced on the 'nth' request for example.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/et_fake_ccd.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
