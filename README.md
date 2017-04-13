#  Rubotnik
### All you need to launch your Ruby bot for Facebook Messenger right now.

*"We are the robots / Ya tvoi sluga / Ya tvoi rabotnik"  — Kraftwerk*

**Rubotnik** is a minimalistic boilerplate and a *microframework proof-of-concept* that allows you to launch your functional bot on a Messenger Platform in a matter of minutes. It is a companion to ingenious [facebook-messenger](https://github.com/hyperoslo/facebook-messenger) gem and piggybacks on its `Bot.on :event` triggers.


**Rubotnik** comes with a simple backbone architecture that ensures multiple users are served without delays or overlaps. It also provides a single shared namespace for everything your bot can do, so your bot's "commands" can be easily bound to incoming messages (or [postbacks](https://developers.facebook.com/docs/messenger-platform/webhook-reference/postback)) through intuitive DSL, like so (strings are treated as case-insensitive regexps):

```ruby

# Will match any of the words
bind "hello", "hi", "bonjour", to: :my_method_for_greeting

# Will match only if all words are present (ignoring order)
bind "what", "time", "is", all: true, to: :tell_time

# Same logic for postbacks
bind "ACTION_BUTTON", to: :action_for_button

```

The main promise of **Rubotnik** is to speed up bot development using Ruby language.  

**Rubotnik** does not depend on any database out of the box and runs on Rack, so it functions as a completely separate web app (100% prepped for [Heroku](https://heroku.com)) that can be easily extended to work with your main project through the REST API. The default server is Puma, but you can use any other Rack webserver for production or development (just note the minimal in-memory storage and dispatch for users does not support parallelism through processes, and a Puma server can only run with **one "worker"**, but multiple threads).

[Sinatra](http://www.sinatrarb.com/) is also enabled by default, and you can use its familiar syntax to define new webhooks for incoming API calls.  

A buil-in set of convenience classes makes working with Messenger Platform less tedious (you don't need to hardcode huge nested JSONs/hashes anymore to use basic interface features, just call one of the builder classes inside **UI** module).   

*DISCLAIMER:* *I am a new programmer and a recent [Le Wagon](https://www.lewagon.com/) graduate, passionate about all things Ruby. This is my first attempt at framework design and OSS. I welcome any discussion that can either push this project forward (and turn it into a separate gem), or prove its worthlessness.*  

## Installation

## Directory structure

## Facebook set up  

## Development on localhost with 'heroku local' and ngrok

## Conventions for commands

## Routing

## UI convenience classes

## Production  

## Missing features (for now)
