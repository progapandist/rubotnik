*"We are the robots / Ya tvoi sluga / Ya tvoi rabotnik"  — Kraftwerk*

# Rubotnik
### All you need to launch your own functional Ruby bot for Facebook Messenger FAST

It's as easy as:

1. Clone the boilerplate.
2. Customize message bindings and commands for your bot.
3. Push your bot to Heroku and review it with Facebook.
4. You're live!

**Rubotnik is a minimalistic boilerplate** and *a microframework proof-of-concept* that allows you to launch your functional bot on a Messenger Platform in a matter of minutes. It is a companion to ingenious [facebook-messenger](https://github.com/hyperoslo/facebook-messenger) gem and piggybacks on its `Bot.on :event` triggers. The main promise of **Rubotnik** is to speed up bot development in Ruby and provide a more natural mental model for bot-user interactions.

**Rubotnik** is also **very** beginner friendly :baby: :baby_bottle: 

**Rubotnik** comes with a bare-bones architecture that ensures multiple users are served without delays or overlaps. It also provides a single shared namespace for everything your bot can do, so your bot's "commands" can be easily bound to incoming messages (or [postbacks](https://developers.facebook.com/docs/messenger-platform/webhook-reference/postback)) through intuitive DSL, like so (strings are treated as case-insensitive regexps):

```ruby

# Will match any of the words
bind "hello", "hi", "bonjour", to: :my_method_for_greeting

# Will match only if all words are present (ignoring order)
bind "what", "time", "is", all: true, to: :tell_time

# Same logic for postbacks
bind "ACTION_BUTTON", to: :action_for_button

```

**Note**: multiple commands may be matched from a single message, in that case commands
will be executed in order of matching.  

"Talking" to the connected user is as straightforward as it gets:

```ruby
say "Hello!"
```

You can provide hints to the user in the form of quick replies:

```ruby

replies = UI::QuickReplies.build(["Yes", "YES"], ["No", "NO"])
# Builds an array of hashes:
# [{:content_type=>"text", :title=>"Yes", :payload=>"YES"},
# {:content_type=>"text", :title=>"No", :payload=>"NO"}]

say "Do you want to see more?", quick_replies: replies
# Creates and sends this hash through Facebook Messenger Platform API:
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
**Implementing conversation threads** is like composing a movie script. Your bot is in constant dialogue with the user: each command starts by handling user's answer to your previous question and ends with posing a new one:

```ruby
# bot.rb
bind "nice to meet you", to: :handle_name_and_ask_age, start_thread: {
                                                  message: "What's your name?"
                                                }

# commands.rb
def handle_name_and_ask_age
  # @message references an incoming message from the user
  # We assume it's a reaction to your previous message
  name = @message.text
  # ... do something with the data ...
  say "Hello, #{name}!"
  say "How old are you?"
  next_command :handle_age_and_ask_smth_else
end

def handle_age_and_ask_smth_else
  # ...
end
```

**Rubotnik** does not depend on any database out of the box and runs on Rack, so it functions as a **self-contained web app** (primed for [Heroku](https://heroku.com)). It can work with your main project through the REST API and use its database for persistence. The default server is Puma, but you can use any other Rack webserver for production or development (note that the minimal in-memory user store and message dispatch does not support parallelism through processes, a Puma server can only run with **one "worker"**, multiple *threads* are fine).

[Sinatra](http://www.sinatrarb.com/) is enabled inside the boilerplate by default, and you can use its familiar syntax to define new webhooks for incoming API calls.  

A built-in set of convenience classes makes working with Messenger Platform less tedious (you don't need to hardcode huge nested JSONs/hashes anymore to use basic interface features, just call one of the builder classes inside **UI** module).  

_**DISCLAIMER:** I am a new programmer and a recent [Le Wagon](https://www.lewagon.com/) graduate, passionate about all things Ruby. This is my first attempt at framework design and OSS. I welcome any discussion that can either push this project forward (and turn it into a separate gem), or prove its worthlessness. Please, star this repo if you want me to carry on._

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

# Setup

## Facebook setup pt. 1. Tokens and environment variables.

Login to [Facebook For Developers](https://developers.facebook.com/). In the top right corner, click on your avatar and select **"Add a new app"**

![create app](./docs/fb_app_create.png)

In the resulting dashboard, under PRODUCTS/Messenger/Settings, scroll to **"Token Generation"** and either select an existing page for your bot (if you happen to have one) or create a new one.

![generate token](./docs/token_generation.png)

Copy **Page Access Token** and keep it at hand.

Create a file named `.env` on the root level of the boilerplate. Create another file called `.gitignore` and add this single line of code:

```
.env
```
Save the `.gitignore` file. Now open your `.env` and put two tokens (one you've just generated and another you need to come up with and save for later) inside:

```ruby
ACCESS_TOKEN=your_page_access_token_from_the_dashboard
VERIFY_TOKEN=come_up_with_any_string_you_will_use_at_next_step

```

From now on, they can be referenced inside your program as `ENV['ACCESS_TOKEN']` and `ENV['VERIFY_TOKEN']`.

**Note:**
*Rubotnik stores its environment variables (aka config vars) locally in .env file (here goes the standard reminder to never check this file into remote repository) `heroku local` loads its contents automatically, so you don't need to worry about setting them manually. If you don't want to use `heroku local` and prefer an old good `rackup`, make sure to uncomment `require 'dotenv/load'` on top of `bot.rb` so variables will be loaded in your local environment by [dotenv](https://github.com/bkeepers/dotenv) gem. If you do so, don't forget to comment it out again before pushing to Heroku for production. In production, you will have to set your config variables by hand, either in your dashboard, or by using `heroku config:set VARIABLE_NAME=value` command in the terminal.*

## Running on localhost

Make sure you have [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli). Run `heroku local` to start bot server on localhost. Provided you set up your token correctly, you should see something like this:

![server starts](./docs/server_start.png)

By default, bot will run on port 5000. Start [ngrok](https://ngrok.com/) on the same port:

```
ngrok http 5000
```
This will expose your localhost for external connections through an URL like `https://92832de0.ngrok.io` (the name will change every time you restart ngrok, so better keep it running in a separate terminal tab). Make note of the URL that start with `https://`, you will give to Facebook in the next step.

![ngrok running](./docs/ngrok.png)

## Facebook setup pt. 2. Webhooks.

Now that your bot is running on your machine, we need to connect it to the Messenger Platform. Go back to your dashboard. Right under **Token Generation** find **Webhooks** and click "Setup Webhooks". In the URL field put your HTTPS ngrok address ending with `/webhook`, provide the verify token you came up with earlier and under Subscription Fields tick *messages* and *messaging_postbacks*. Click **"Verify and Save"**.

![webhook setup](./docs/webhook_setup.png)

Congrats! Your bot is connected to Facebook! You can start working on it.  

# Working with Boilerplate

Your starting point is `bot.rb` file that serves your bot, enables its persistent menu and a greeting screen, and provides top-level routing for messages and postbacks.

**Greeting screen** (the one with 'Get Started' button and a welcome message) can be configured inside `rubotnik/bot_profile.rb`.

**Persistent menu** (note it supports nesting) can be defined inside `rubotnik/persistent_menu.rb`.

Follow the logic of the provided examples, you can also refer to Facebook documentation (just note that all the examples there are raw JSONs as the API accepts them, some parts of them have already been abstracted out on facebook-messenger gem level).  

The most important thing in `bot.rb` happens inside of blocks fed to `Bot.on :messages` and `Bot.on :postbacks` call

## Helpers

## Routing

## Conventions for commands. @user and @message. Threads.

## UI convenience classes

# Deployment

## Missing and planned features

- [ ] Support for other types of Messenger Platform events like *optins* and *referrals*
- [ ] Support for other Messenger UI elements like *List Template*
- [ ] Integration with NLU services like Wit.ai and API.ai

Most of all, I'll appreciate any help with turning **Rubotnik** into a proper gem with generators for folder structure and other grown-up things.

---

MIT License

Copyright (c) 2016-2017 Andrei Baranov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
