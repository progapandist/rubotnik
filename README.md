> :warning: Hooray! Rubotnik is now a gem that can generate a project for you and serve it from localhost or Heroku. There's been some API changes since it has been a boilerplate. If you are looking for an old README and rubotnik-boilerplate's code you can find it [here](https://github.com/progapandist/rubotnik/tree/boilerplate-legacy).

# Rubotnik

Tiny "bot-end" Ruby framework with intuitive DSL to quickly build, test and deploy a Messenger chatbot 🤖.

Only minimal Ruby knowledge is required. Perfect for pet projects, classrooms and building bot MVPs from scratch while having a complete freedom over what your bot can do ([ChatFuel](https://chatfuel.com/) is great, but what if you actually _want_ to code?). Probably not the best solution for commercial projects at the moment—Rubotnik is yet to prove its worth in production.

This is how you greet your users with Rubotnik:

```ruby
Rubotnik.route :message do
  bind 'hi', 'hello', 'bonjour' do
    say 'Hello from your new bot!'
  end
end
```

Rubotnik is zero-configuration, you can have a conversation with your bot on Messenger in __under 10 minutes__ (and most of that time you'll spend on Facebook and Facebook for Developers, creating a page and an "app" for the bot).

Rubotnik is built on top of an excellent [facebook-messenger gem](https://github.com/jgorset/facebook-messenger) by [Johannes Gorset](https://github.com/jgorset) that does all the heavy-lifting to actually interact with the Messenger Platform API. While `facebook-messenger` implements a client, `rubotnik` offers you a way to reason about your bot design without dozens of nested `if` and `case` statements. Rubotnik comes with a bare-bones architecture that ensures multiple connected users are served without delays or overlaps.

## What the heck is "bot-end"?

Exactly as with modern front-end, "bot-end" is a separate web application that can talk with your back-end through a (REST) API. Project generated with Rubotnik uses Puma as web server, contains its own `config.ru` and can be deployed to Heroku in a matter of minutes. And you can still use Heroku's free account, as "sleep time" is not a deciding factor in bot interactions.

Rubotnik currently __can not__ be integrated directly inside the Rails project (although thoughts on that are welcome) and does not have a database adapter of its own __on purpose__, to keep the boilerplate to the very minimum and extract conversational logic to a separate layer.

In other words:

> Rubotnik is perfect to consume existing APIs from a chatbot interface

__NB__: Rubotnik comes with [httparty](https://github.com/jnunemaker/httparty) library to make HTTP requests, but you can use any other tool by including it in the project's Gemfile.

## Installation

It is recommended to install [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli), [Ngrok](https://ngrok.com/) and [Bundler](http://bundler.io/) before you start.

```bash
$ gem install rubotnik
```

And then create your bot with:

```bash
$ rubotnik new PROJECT_NAME
```

Now you can `cd` to `PROJECT_NAME`, open it in your favorite editing and start hacking!

To start playing with your bot directly from Messenger (after you've [created](https://github.com/progapandist/rubotnik#setup) an app in Facebook Developer Console):

```bash
$ bundle install
$ heroku local
```

And in a new Terminal tab:

```bash
$ ngrok http 5000
```

## Usage

A project generated with `rubotnik new` will have a following simple structure:

```
.
├── Gemfile # contains a single dependency on "rubotnik" gem
├── Procfile # ready for Heroku
├── bot
│   ├── bot.rb # <-- YOUR STARTING POINT  
│   ├── commands
│   │   ├── commands.rb # define any commands as methods here
│   │   ├── location.rb # or here (contains example for handling user location)
│   │   └── ui_examples.rb # or here (contains examples for UI elements)
│   └── profile.rb # Welcome page, "Get Started" button and a menu for your bot
├── config
│   └── puma.rb # Puma settings
└── config.ru # it's a Rack app, after all!
```

All the magic happens inside `Rubotnik.route :message` and `Rubotnik.route :postback` blocks, this is where you can use Rubotnik's DSL to bind user messages to "commands" that your bot is going to execute.

A "command" is just a plain Ruby _method_ inside the `Commands` module that has access to `message` (or `postback`) and `user` objects. This is how you match incoming message to a command:

```ruby

# Will match any of the words and their variations
bind "hello", "hi", "bonjour", "привет", to: :my_method_for_greeting

# Will match only if all words are present (ignoring order)
bind "what", "time", "is", all: true, to: :tell_time

# Same logic for postbacks
bind "ACTION_BUTTON", to: :action_for_button

```

`bind` can also take a block for a simple response that does not merit its own method:

```ruby
bind "damn" do
  say "Watch your language, human!"
end
```

If none of the commands are matched, a `default` block will be invoked

```ruby
# Invoked if none of the commands recognized. Has to come last, after all binds
default do
  say "Come again?"
end
```

## Setup

* Login to [Facebook For Developers](https://developers.facebook.com/). In the top right corner, select _My apps > Add a new app_.

* Select a product _"Messenger"_

* Under _Token Generation_ in _Products > Messenger > Settings_ select a page for your bot, or create a new one. Copy the __Page Access Token__ and insert it in `.env` in the Rubotnik-generated project under `ACESS_TOKEN`

* While still in `.env`, come up with any string for `VERIFY_TOKEN` variable (or leave the default `verify_me`)

* From the Terminal, while being in the same folder as your project, open a new tab and run `heroku local`. It will load environment variables from `.env` and start Puma server on port 5000.

* Open another tab und run `ngrok http 5000` that will expose port 5000 to the Internet. (note, depending on your Ngrok installation, you may want to specify path to `ngrok` executable when running it).

* Copy the _Forwarding_ address from the ngrok tab. It should start with __https://__

* In the Facebook dashboard, while still under _Products > Messenger > Settings_, click _Setup Webhooks_. Under _Subscription Fields_ select _"messages"_ and _"messaging_postbacks"_.  Under _Callback URL_, paste your ngrok secure forwarding address and postpend it with `/webhook` (that's important!). Put your verification token under _Verify Token_

* Click _Verify and Save_. Once the modal closes, you will see that under _Webhooks_ section in the dashboard you can now _"Select a page to subscribe your webhook to the page events"_. Select your page and hit _"Subscribe"_.

* You're done! Now you can find your bot in Messenger under your page's name and start talking to it. Check with your generated project to see what commands are included for demonstration purposes. Start tweaking the bot to your liking!


## Debugging your bot

Debugging bots under Facebook Messenger Platorfm is not the most pleasant experience — if your client can not handle the `POST` request to your webhook from the API that contains a message relayed from user — Facebook will try resending the message again and again, before finally disabling your bot if it still can not return a 200 response. In order to save you from that trouble, Rubotnik sets `$DEBUG` environment variable to "true" while you're on localhost.

While in this mode, every `StandardError` exception raised by your bot's code will be forwarded as a bot response to the chat dialogue, ensuring the conversation flow is never broken. As a developer, you will be able to see what is wrong with your bot _while talking it_. I find it a very natural experience.

Note that Rubotnik does not reload the server on code change. Every time you want to add a new feature or modify an existing one—you will have to relaunch `heroku local` after code save.

Currently, Rubotnik has quite a verbose logging to `stdout` that will help you make sense of what's going on.

# Developing with Rubotnik

## Messages, postbacks and menus

Your starting point is `bot.rb` file that serves your bot, enables its persistent menu and a greeting screen, and provides top-level routing for messages and postbacks.

Received messages and postbacks are instances of `Facebook::Messenger::Incoming::Message` and `Facebook::Messenger::Incoming::Postback` objects of [facebook-messenger](https://github.com/hyperoslo/facebook-messenger) gem and have all the properties defined in its README.

```ruby

message.id         # => 'mid.1457764197618:41d102a3e1ae206a38'
message.sender     # => { 'id' => '1008372609250235' }
message.seq         # => 73
message.sent_at     # => 2016-04-22 21:30:36 +0200
message.text        # => 'Hello, bot!'
message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]

```

`profile.rb` contains constants that provide hash structures (mimicking JSON from Facebook docs) for payloads necessary to enable the "Start Button", "Welcome Screen" and "Persistent Menu" of your bot. Modify them to your liking. Note that it's better not to change them very often after enabling them, as Facebook caches interface elements.

You can enable them all or some of them by putting `# Rubotnik.set_profile(Profile::START_BUTTON, Profile::START_GREETING, Profile::SIMPLE_MENU)` in your code.

## Users

Every connected user will be given it's own `User` object that is stored in the hash in memory, while your bot is running. You can reference `user` or `@user` (both will work) from anywhere inside your code.

`user.id` will give you an unique identifier for connected user (assigned by Facebook), and `user.session` is a hash that can be used for storing any user-related data during the session. For instance, you can design a thread of conversation that will ask user for some information, keep bits of that information as different keys under `user.session` hash and make a POST call with httparty (included in your project) or any other tool to your application back-end to persist the data.

## Conversation threads

One of the most painful points in bot development is conversation branching. Rubotnik tries to make that a little bit more intuitive by allowing you to chain "command" methods together. Here's an example that you will find in the generated project.

In `bot.rb`:

```ruby
Rubotnik.route :message do
  bind 'how', 'do', 'you', all: true, to: :start_conversation, reply_with: {
     text: "I'm doing fine! You?",
     quick_replies: [['Good!', 'OK'], ['Not so well', 'NOT_OK']]
  }
end
```

Any message from user that has any combination of words "how", "do" and "you" (e.g. "How are you doing?", "How do  you do?") will trigger a response defined under `reply_with`. `text` is a text of the response and `quick_replies` is an optional array of quick replies (maximum 11) that will be attached to your bot's message like this:

![quick replies](./docs/quick_replies.PNG)

Any further user action will now be handled by `start_conversation` command under Commands module. If the user chooses to ignore "quick replies" hints and just types something in the message box, that will be a regular `message.text`, if he clicks on one of supplied quick replies, that will result in a received `message` with two properties: `message.text # => "Good!"` and `message.quick_reply # => "OK"`. Now you can handle it in `start_conversation`:

```ruby
def start_conversation
  message.typing_on # simulate "typing"
  case message.quick_reply # switch on quick_reply property
  when 'OK'
    say "Glad you're doing well!"
    # end conversation, further input will be handled by top level bindings
    # defined under Rubotnik.route :message
    stop_thread
  when 'NOT_OK'
    say "Too bad. What happened?"
    next_command :appear_nice # pass the control further down the thread
  else
    say "🤖"
    # it's always a good idea to have an else, quick replies don't
    # prevent user from typing any message in the dialogue
    stop_thread
  end
  message.typing_off
end

def appear_nice
  message.typing_on
  case message.text
  when /job/i then say "We've all been there"
  when /family/i then say "That's just life"
  else
    say "It shall pass"
  end
  message.typing_off
  stop_thread # end conversation
end
```

This is the breakdown of the sequence of events:

* User sends _"How do you do"_ =>   
* `Rubotnik.route :message` binding to `start_conversation` command is invoked with a `reply_with` option =>   
* Your bot replies with "I'm doing fine!" and attaches quick replies "Good!" and "Not so well" to the message =>
* User selects "Good!" =>
* A user message with `message.text` "Good!" and `message.quick_reply` "OK" is handled by `start_conversation` method. You can switch on any or both properties =>
* Method either passes control to a next method with `next_command` or stops interaction (returning user to the "top level" of conversation) with `stop_thread`


## Helpers

Rubotnik gives you a number of helper methods (defined [here](https://github.com/progapandist/rubotnik/blob/master/lib/rubotnik/helpers.rb):

* `say`: `say "Hi"` or `say "Choose a pill", quick_replies: %w[Red Blue]` will immediately send a message to the user. `quick_replies` accepts either an array of strings (then `payload` option is automatically set to text in ALL CAPS), an array of string arrays (`['Reply Text', 'REPLY_PAYLOAD']`), or an array of hashes that follow Facebook's [format](https://developers.facebook.com/docs/messenger-platform/send-messages/quick-replies):

```ruby
[
  {
    content_type: "text",
    title: "<BUTTON_TEXT>",
    image_url: "http://example.com/img/red.png",
    payload: "<STRING_SENT_TO_WEBHOOK>"
  },
  {...}
]
```

* `show` takes an instance of `UI` element and sends it to the connected user.

* `text_message?` allows you to check if the message received from the user contains text (and isn't a GIF, a sticker or anything else). Useful for implementing sanity checks.

* `message_contains_location?` checks if the user has shared a location with your bot. Then you can access its coordinates with `message.attachments`.

* `get_user_info(*fields)` takes a list of fields good for [Graph API User](https://developers.facebook.com/docs/graph-api/reference/v2.2/user) and makes a call to the Graph referencing connected user's id and requesting specified fields. Returns a hash with user data. Keys are symbols.

```ruby
get_user_info(:first_name, :last_name) # => { first_name: "John", last_name: "Doe" }  
```   

* `next_command :command_name` and `stop_thread` are used to control conversation flow.

## Supported UI elements

### Button Template

`UI::FBButtonTemplate` takes two arguments: string for the text message and an array of hashes for buttons. See [types of buttons available](https://developers.facebook.com/docs/messenger-platform/send-api-reference/buttons) in Messenger Platform docs.

```ruby
TEXT = "Look, I'm a message and I have some buttons attached!"
BUTTONS = [
  {
    type: :web_url,
    url: 'https://medium.com/@progapanda',
    title: "Andy's Medium"
  },
  {
    type: :postback,
    payload: 'BUTTON_TEMPLATE_ACTION',
    title: 'Useful Button'
  }
]

# create template object and send it to connected user
template = UI::FBButtonTemplate.new(TEXT, BUTTONS)
show(template)
```

If you have a button of type 'postback', you will be responsible to implementing the trigger for that action under `Rubotnik.route :postback` as `bind 'BUTTON_TEMPLATE_ACTION', to: :do_smth_on_button_click`.

![button template](./docs/button_template.png)

### Generic Template

[Generic template](https://developers.facebook.com/docs/messenger-platform/send-api-reference/generic-template) is a way to send the user a carousel of items, each consisting of an image, a title, a description and up to 3 action buttons. Each card can be made clickable and link to a website. Constructing Generic Template involves building a long nested JSON (refer to Facebook docs to see what keys are available) and Rubotnik tries to abstract it at least a little bit. You only need to build hashes for the `elements` array of the original documentation. Create your structure and save it in a constant:

```ruby
# A carousel with two items (platform supports up to 10)
CAROUSEL = [
  {
    title: 'Random image',
    # Horizontal image should have 1.91:1 ratio
    image_url: 'https://unsplash.it/760/400?random',
    subtitle: "That's a first card in a carousel",
    default_action: {
      type: 'web_url',
      url: 'https://unsplash.it'
    },
    buttons: [
      {
        type: :web_url,
        url: 'https://unsplash.it',
        title: 'Website'
      }
    ]
  },
  {
    title: 'Another random image',
    # Horizontal image should have 1.91:1 ratio
    image_url: 'https://unsplash.it/600/315?random',
    subtitle: "And here's a second card. You can add up to 10!",
    default_action: {
      type: 'web_url',
      url: 'https://unsplash.it'
    },
    buttons: [
      {
        type: :web_url,
        url: 'https://unsplash.it',
        title: 'Website'
      }
    ]
  }
]
```

Then you can create an instance of `UI::FBCarousel` by passing your template to the constructor. Then you can send it to the user.

```ruby
carousel = UI::FBCarousel.new(CAROUSEL)
show(carousel)
```

Here is the the result:

![carousel](./docs/carousel.png)

### Image Attachment

You can send an image to the user. Note that image won't have any text, but you can send a regular message along with it.


```ruby
img_url = 'https://unsplash.it/600/400?random'
image = UI::ImageAttachment.new(img_url)
show(image)
```

## Other events

Events other then `message` and `postback` are currently not supported.

# Deployment

Once you have designed your bot and tested in on localhost, it's time to send it to the cloud, so it live its life without being tethered to your machine. Assuming you already have a Heroku account and Heroku CLI tools installed, here's pretty much the whole process:

```bash
$ git init   # if haven't done before
$ git add . && git commit -m "Ready to deploy!"
$ heroku create YOUR_APP_NAME
$ heroku config:set ACCESS_TOKEN=your_own_page_token
$ heroku config:set VERIFY_TOKEN=your_own_verify_token
$ git push heroku master
```

Now don't forget to go back to your Facebook developer console and change the address of your webhook from your ngrok's URL to the Heroku one. That's it!

### :tada: You're live! :tada:

## Coming next

* Proper implementation of logging (for now it's just `p` and `puts` statements sprinkled around the code) with ability to choose a logging level.

* More powerful DSL for parsing user input and binding it to commands.   

* NLP integration with Wit.AI (that allow for more things then the built-in NLP capabilities of Messenger platform, including a wrapper around Wit's interactive learning methods) is in the works and will be added to the gem some time in 2018...

## Contributing

Im a still a relatively new Ruby developer (I started coding in 2015 while looking for a break from my 10+ years career as a TV reporter) and this is my first attempt at OSS. Any contribution will be more than welcome! Rubotnik is still in the early stage of development, so it's your chance to make a difference!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests (currently project has no tests, but you're welcome to land a helping hand). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
