#  Rubotnik
### All you need to launch your own Ruby bot for Facebook Messenger right now.

*"We are the robots / Ya tvoi sluga / Ya tvoi rabotnik"  — Kraftwerk*

**Rubotnik is a minimalistic boilerplate** and *a microframework proof-of-concept* that allows you to launch your functional bot on a Messenger Platform in a matter of minutes. It is a companion to ingenious [facebook-messenger](https://github.com/hyperoslo/facebook-messenger) gem and piggybacks on its `Bot.on :event` triggers.


**Rubotnik** comes with a bare-bones architecture that ensures multiple users are served without delays or overlaps. It also provides a single shared namespace for everything your bot can do, so your bot's "commands" can be easily bound to incoming messages (or [postbacks](https://developers.facebook.com/docs/messenger-platform/webhook-reference/postback)) through intuitive DSL, like so (strings are treated as case-insensitive regexps):

```ruby

# Will match any of the words
bind "hello", "hi", "bonjour", to: :my_method_for_greeting

# Will match only if all words are present (ignoring order)
bind "what", "time", "is", all: true, to: :tell_time

# Same logic for postbacks
bind "ACTION_BUTTON", to: :action_for_button

```

The main promise of **Rubotnik** is to speed up bot development in Ruby.

**Rubotnik** does not depend on any database out of the box and runs on Rack, so it functions as a completely separate web app (100% prepped for [Heroku](https://heroku.com)) that can be easily extended to work with your main project through the REST API. The default server is Puma, but you can use any other Rack webserver for production or development (just note the minimal in-memory storage and dispatch for users does not support parallelism through processes, and a Puma server can only run with **one "worker"**, but multiple threads).

[Sinatra](http://www.sinatrarb.com/) is also enabled by default, and you can use its familiar syntax to define new webhooks for incoming API calls.  

A buil-in set of convenience classes makes working with Messenger Platform less tedious (you don't need to hardcode huge nested JSONs/hashes anymore to use basic interface features, just call one of the builder classes inside **UI** module).   

*DISCLAIMER:* *I am a new programmer and a recent [Le Wagon](https://www.lewagon.com/) graduate, passionate about all things Ruby. This is my first attempt at framework design and OSS. I welcome any discussion that can either push this project forward (and turn it into a separate gem), or prove its worthlessness.*  

## Installation
Assuming you are going to use this boilerplare as a starting point for your own bot:

```bash
git clone git@github.com:progapandist/rubotnik-boilerplate.git

mv rubotnik-boilerplate YOUR_PROJECT_NAME

cd YOUR_PROJECT_NAME

rm -rf .git # to delete boilerplate's git history
git init # to track your own project

bundle install
```

Now open the boilerplate in your favorite text editor and let's take a look at the structure

## Directory structure

```bash
.
├── Gemfile
├── Gemfile.lock
├── Procfile
├── README.md # this readme
├── bot.rb # your main starting point  
├── commands # everything in this folder will become private methods for MessageDispatch and PostbackDispatch 
│   ├── commands.rb # write your commands here
│   ├── questionnaire.rb # or in one of associated modules
│   └── show_ui_examples.rb
├── config
│   └── puma.rb
├── config.ru
├── demo
│   └── sample_elements.rb
├── helpers
│   └── helpers.rb
├── privacy_policy.pdf  # replace with your own for FB approval
├── rubotnik
│   ├── bot_profile.rb
│   ├── message_dispatch.rb
│   ├── persistent_menu.rb
│   ├── postback_dispatch.rb
│   ├── rubotnik.rb
│   ├── user.rb
│   └── user_store.rb
└── ui
    ├── fb_button_template.rb
    ├── fb_carousel.rb
    ├── image_attachment.rb
    ├── quick_replies.rb
    └── ui.rb

```

## Development on localhost with 'heroku local' and ngrok

## Facebook set up  

## Routing

## Conventions for commands

## UI convenience classes

## Deployment

## Missing features (for now)
