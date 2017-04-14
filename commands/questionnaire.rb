# Showcases a chained sequence of commands that gather the data
# and store it in the answers hash inside the User instance.
module Questionnaire
  # State 'module_function' before any method definitions so
  # commands are mixed into Dispatch classes as private methods.
  module_function

  def start_questionnaire
    if @message.quick_reply == 'START_QUESTIONNAIRE' || @message.text =~ /yes/i
      say "Great! What's your name?"
      say "(type 'Stop' at any point to exit)"
      next_command :handle_name_and_ask_gender
    else
      say "No problem! Let's do it later"
      stop_thread
    end
  end

  def handle_name_and_ask_gender
    # Fallback functionality if stop word used or user input is not text
    fall_back && return
    @user.answers[:name] = @message.text
    replies = UI::QuickReplies.build(%w[Male MALE], %w[Female FEMALE])
    say "What's your gender?", quick_replies: replies
    next_command :handle_gender_and_ask_age
  end

  def handle_gender_and_ask_age
    fall_back && return
    @user.answers[:gender] = @message.text
    reply = UI::QuickReplies.build(["I'd rather not say", 'NO_AGE'])
    say 'Finally, how old are you?', quick_replies: reply
    next_command :handle_age_and_stop
  end

  def handle_age_and_stop
    fall_back && return
    @user.answers[:age] = if @message.quick_reply == 'NO_AGE'
                            'hidden'
                          else
                            @message.text
                          end
    stop_questionnaire
  end

  def stop_questionnaire
    stop_thread
    show_results
    @user.answers = {}
  end

  def show_results
    say "OK. Here's what we now about you so far:"
    name = @user.answers.fetch(:name, 'N/A')
    gender = @user.answers.fetch(:gender, 'N/A')
    age = @user.answers.fetch(:age, 'N/A')
    text = "Name: #{name}, " \
           "gender: #{gender}, " \
           "age: #{age}"
    say text
    say 'Thanks for your time!'
  end

  # NOTE: A way to enforce sanity checks (repeat for each sequential command)
  def fall_back
    say 'You tried to fool me, human! Start over!' unless text_message?
    return false unless !text_message? || stop_word_used?('Stop')
    stop_questionnaire
    puts 'Fallback triggered!'
    true # to trigger return from the caller on 'and return'
  end

  # specify stop word
  def stop_word_used?(word)
    !(@message.text =~ /#{word.downcase}/i).nil?
  end
end
