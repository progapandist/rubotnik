#  Rubotnik
### All you need to launch your Ruby bot for Facebook Messenger right now.

*"We are the robots / Ya tvoi sluga / Ya tvoi rabotnik"  — Kraftwerk*

**Rubotnik** is a minimalistic boilerplate and a *microframework proof-of-concept* that allows you to launch your functional bot on a Messenger Platform in a matter of minutes. It comes with a simple architecture to ensure multiple users will be served without delays or overlaps. It also provides a single shared namespace for all "commands" so  they can be bound to incoming messages (or [postbacks](https://developers.facebook.com/docs/messenger-platform/webhook-reference/postback)) through intuitive DSL, like so (strings are treated as case-insensitive regexps):

```ruby

# Will reply to any defined greeting
bind "hello", "hi", "bonjour", to: :my_method_for_greeting

# Will reply only if all words are present in the message
bind "what", "time", "is", all: true, to: :tell_time

# Same logic for postbacks
bind "ACTION_BUTTON", to: :action_for_button

```

**Rubotnik** does not depend on any database out of the box and runs on Rack, so it functions as a completely separate web app (100% prepped for [Heroku](https://heroku.com)) that can be easily extended to work with your main project through the REST API. The default server is Puma, but you can use any other Rack webserver for production or development (just note the minimal in-memory storage and dispatch for users does not support parallelism through processes, and a Puma server can only run with one worker and multiple threads).

[Sinatra](http://www.sinatrarb.com/) is also enabled by default, so you can use a familiar syntax to define webhooks for incoming API calls.  

A set of convenience classes makes working with Messenger Platform less tedious (you don't need to hardcode huge nested JSONs/hashes anymore to use basic interface features, just call one of the builder classes inside **UI** module).   

*DISCLAIMER:* *I am a new programmer and this is my first attempt at framework design. I welcome any discussion that can either push this project forward (and turn it into a separate gem), or prove its worthlessness.*  

## Installation

## Facebook set up  

## Development on localhost with 'heroku local' and ngrok

## Directory structure

## Routing

## UI convenience classes

## Production  

## Missing features (for now) 
