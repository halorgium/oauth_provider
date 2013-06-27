# OAuth Provider library in Ruby

1. Getting the library setup
1. Creating a provider
1. Adding a consumer
1. Issuing a request token
1. Authorizing a request token
1. Upgrading a request token to an access token
1. Confirming access for an access token

## Getting the library setup

You can currently only download the source and build a gem. 
It will be put on rubyforge once it is more feature-some. 

``` sh
git clone git://github.com/halorgium/oauth_provider.git
rake package
```

## Getting the library setup

Create a provider to allow you to interact issue request tokens etc. 
There are several backends to allow you to use this for real and in testing. 

The in-memory backend is best for testing, it allows you to not have the 
overhead of a database. 

``` ruby
provider = OAuthProvider.create(:in_memory)
```

The DataMapper backend is currently the only real backend, you can provide a 
repository which will allow you to use a different database connection. 

``` ruby
provider = OAuthProvider.create(:data_mapper, :some_oauth_repository)
```

## Adding a consumer

To add a consumer to the provider, you need to provide a callback URL. 

``` ruby
consumer = provider.add_consumer("http://myconsumer.com/token")
```

You should store the consumer shared key in your database so you can associate 
your users with the tokens they own. 

``` ruby
Consumer.create("My Consumer", consumer.shared_key)
```

## Issuing a request token

Now you can issue a request token, this will save the token for later access. 
You need to pass in the raw request object which your web framework uses and 
require the correct request-proxy. 

Rails (ActionController): 
``` ruby
require 'oauth/request_proxy/action_controller_request'
```
XMPP4R: 
``` ruby
require 'oauth/request_proxy/jabber_request'
```
Net::HTTP: 
``` ruby
require 'oauth/request_proxy/net_http'
```
Sinatra/Merb (Rack): 
``` ruby
require 'oauth/request_proxy/rack_request'
```

Once that file is required, you can ask the provider to issue a token. 

``` ruby
user_request = provider.issue_request(request)
```

You should save this token in your database to connect this token with a 
particular user. 

``` ruby
current_user.tokens.create(:consumer_shared_key => user_request.consumer.shared_key,
                           :shared_key => user_request.shared_key)
```

This object allows you to access the `query_string` which should be returned 
to the consumer. 
This is the form: `oauth_token=ABCDE&oauth_token_secret=SECRET123`

``` ruby
user_request.query_string
```

Now it is up to the consumer to redirect the user to your authorization 
screen. To locate the token which corresponds with the shared key (usually 
the `oauth_token` parameter in the request) you need to 

## Authorizing a request token

Once you have determined that the user wishes to authorize the request. You 
should display the consumer information to the user. 

An example ERB view might be: 

``` erb
<p>You are about to authorize <%= token.consumer.name %> to access your account %></p>
<p>Do you want this to happen?</p>
<p><a href="/authorize?oauth_token=<%= token.shared_key %>Authorize it</a>
```

At this point, you can also store any access control information to allow this 
consumer to perhaps only have read-access to the user's information. 

Then in the `authorize` action you would tell the provider to authorize this 
request token and redirect back to the consumer callback URL. 

``` ruby
user_request.authorize
redirect_to user_request.callback
```

## Upgrading a request token to an access token

Now that the request token is authorized by the user, the consumer can upgrade 
this token to an access token. 

``` ruby
user_access = provider.upgrade_request(request)
```

If the request token is not yet authorized, an exception will be raised. The 
exception class is `OAuthProvider::UserRequestNotAuthorized`. 

If the request token is authorized, the request token will be destroyed and 
a access token will be generated and returned. 

Now you can save this into your database. 

``` ruby
token = current_user.tokens.find_by_shared_key(user_access.request_shared_key)
token.update_attributes(:access => true, :shared_key => user_access.shared_key)
```

And return the query string back to the consumer

``` ruby
user_access.query_string
```

## Confirming access for an access token

At this point, the consumer should have a valid access token and can make API 
requests. You can ask the provider to confirm that the access token is valid. 

``` ruby
user_access = provider.confirm_access(request)
```

Now you can find the user token which corresponds to the shared key. 

``` ruby
token = current_user.tokens.first(:access => true, :shared_key => user_access.shared_key)
```

You are now ready to respond to the API request as needed!
