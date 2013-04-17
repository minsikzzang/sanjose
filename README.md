# Sanjose
** Google Cloud Message. **

Sanjose is a simple gem for sending Google Cloud Message.

## Installation

Add this line to your application's Gemfile:

    gem 'sanjose'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sanjose

## Usage

```ruby
GCM = Sanjose::Client.new
GCM.gcm_api_key = "AIzaSyApdin5fMuTSGtW-OTC9gJrm2qz1hJPUzk"

# An example of the registration id sent back when a device registers for notifications
registration_id = "APA91bH35MqYza3xfc2hfag6Rr8VQPSOmi2nrUOPABlFwowfVMZNHaBGBpx-zQ7nuv9qzCEosepUMPKyOrVn0UncZMa__E2sWuM2Q53fjJ5loqIY1QKCza3MkxAu1rvyhhzJP3meEqpmv-kjBuRTeWe_ysRUICupE-awrK1eiStmmm2Y_VBBSs4"

# Create a notification that alerts a message to the user.
notification = Sanjose::Notification.new(devices: [registration_id])
notification.collapse_key = "Hello, World!"
notification.data = {foo: "bar"}

# And... sent! That's all it takes.
GCM.push(notification)
```

## Contact

Min Kim

- http://github.com/minsikzzang
- http://twitter.com/minsikzzang
- minsikzzang@gmail.com

## License

Sanjose is available under the MIT license. See the LICENSE file for more info.
