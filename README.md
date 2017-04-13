*"We are the robots / Ya tvoi sluga / Ya tvoi rabotnik"  — Kraftwerk*

#  Rubotnik
### All you need to launch your own Ruby bot for Facebook Messenger right now.

**Rubotnik is a minimalistic boilerplate** and *a microframework proof-of-concept* that allows you to launch your functional bot on a Messenger Platform in a matter of minutes. It is a companion to ingenious [facebook-messenger](https://github.com/hyperoslo/facebook-messenger) gem and piggybacks on its `Bot.on :event` triggers. The main promise of **Rubotnik** is to speed up bot development in Ruby and provide a more natural mental model for bot-user interactions.

**Rubotnik** comes with a bare-bones architecture that ensures multiple users are served without delays or overlaps. It also provides a single shared namespace for everything your bot can do, so your bot's "commands" can be easily bound to incoming messages (or [postbacks](https://developers.facebook.com/docs/messenger-platform/webhook-reference/postback)) through intuitive DSL, like so (strings are treated as case-insensitive regexps):

```ruby

# Will match any of the words
bind "hello", "hi", "bonjour", to: :my_method_for_greeting

# Will match only if all words are present (ignoring order)
bind "what", "time", "is", all: true, to: :tell_time

# Same logic for postbacks
bind "ACTION_BUTTON", to: :action_for_button

```

"Talking" to the connected user is as obvious as:

```ruby
say "Hello!"
```

You can provide hints to the user in the form of quick replies:

```ruby

replies = UI::QuickReplies.build(["Yes", "YES"], ["No", "NO"])
# Builds an array of Hashes:
# [{:content_type=>"text", :title=>"Yes", :payload=>"YES"},
# {:content_type=>"text", :title=>"No", :payload=>"NO"}]

say "Do you want to see more?", quick_replies: replies
# Creates and sends this Hash through Facebook Messenger Platform API:
#  {
#   recipient: {
#     id: "USER_ID"
#   },
#   message: {
#     text: "Do you want to see more?",
#     "quick_replies":[
#       {
#         content_type: "text",
#         title: "Yes",
#         payload: "YES"
#       },
#       {
#         content_type: "text",
#         title: "No",
#         payload: "NO"
#       }
#     ]
#   }
# }

```
Implementing conversation threads is like composing a movie script. Your bot is in constant dialogue with the user: each command starts by handling user's answer to your previous question and ends with posing a new one:

```ruby
# bot.rb
bind "questionnaire", to: :start_questionnaire, start_thread: {
                                                  message: "What's your name?"
                                                }

# commands.rb
def start_questionnaire
  # Assuming that the @message is user's answer to your previous message
  say "Hello, #{@message.text}"
  say "How old a are you?"
  next_command :handle_age_and_ask_more
end

def handle_age_and_ask_more
  # ...
end
```

**Rubotnik** does not depend on any database out of the box and runs on Rack, so it functions as a completely separate web app (100% prepped for [Heroku](https://heroku.com)) that can be easily extended to work with your main project through the REST API. The default server is Puma, but you can use any other Rack webserver for production or development (just note the minimal in-memory storage and dispatch for users does not support parallelism through processes, and a Puma server can only run with **one "worker"**, but multiple threads).

[Sinatra](http://www.sinatrarb.com/) is also enabled by default, and you can use its familiar syntax to define new webhooks for incoming API calls.  

A buil-in set of convenience classes makes working with Messenger Platform less tedious (you don't need to hardcode huge nested JSONs/hashes anymore to use basic interface features, just call one of the builder classes inside **UI** module).   

*DISCLAIMER:* *I am a new programmer and a recent [Le Wagon](https://www.lewagon.com/) graduate, passionate about all things Ruby. This is my first attempt at framework design and OSS. I welcome any discussion that can either push this project forward (and turn it into a separate gem), or prove its worthlessness. Please, star this repo if you want me to carry on.*  

## Installation
Assuming you are going to use this boilerplare as a starting point for your own bot:

```bash
git clone git@github.com:progapandist/rubotnik-boilerplate.git

mv rubotnik-boilerplate YOUR_PROJECT_NAME

cd YOUR_PROJECT_NAME

rm -rf .git # to delete boilerplate's git history
git init # to start tracking your own project

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
├── bot.rb # <= !!! YOUR STARTING POINT !!!
├── commands # everything in this folder will become
             # private methods for Dispatch classes
│   ├── commands.rb # write your commands as methods here
│   ├── questionnaire.rb # or in one of associated modules
│   └── show_ui_examples.rb
├── config
│   └── puma.rb # a configuration file for Puma
├── config.ru
├── demo # Constants for UI elements used in the demo.
         # you are free to delete this folder  
│   └── sample_elements.rb
├── helpers # general helpers mixed into bot.rb
            # and accessible from everywhere inside the boilerplate   
│   └── helpers.rb
├── privacy_policy.pdf  # replace with your own for FB approval
├── rubotnik # an embryo for the framework
│   ├── bot_profile.rb
│   ├── message_dispatch.rb
│   ├── persistent_menu.rb # design your persistent menu here
│   ├── postback_dispatch.rb
│   ├── rubotnik.rb
│   ├── user.rb # User model, define your own containers for state
│   └── user_store.rb # in-memory storage for users
└── ui # convenience classes to build UI elemens
    ├── fb_button_template.rb
    ├── fb_carousel.rb
    ├── image_attachment.rb
    ├── quick_replies.rb
    └── ui.rb

```

# Set up

## Facebook set up pt. 1. Tokens and environment variables.

## Develop and test on localhost

Make sure you have [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli). Run `heroku local` to start bot server on localhost. By default, it will run on port 5000. Run [ngrok](https://ngrok.com/) on the same port:

```
ngrok http 5000
```
This will expose your localhost for external connections through an URL like `https://92832de0.ngrok.io` (the name will change every time you restart ngrok, so better keep it running in a separate terminal tab)

## Facebook set up pt. 2. Webhook.

# Working with boilerplate

## Helpers

## Routing

## Conventions for commands. @user and @message. Threads.

## UI convenience classes

# Deployment

## Missing and planned features
