# Showcases a chained sequence of commands that gather the data
# and store it in the @answers hash inside User class.

# CONVENTION:
# Every chained command should take (message, user) as parameters
# and either end with user.set_command(:next_method_name) or user.reset_command

module Questionnaire
  def start_questionnaire(message, user)
    if message.quick_reply == "START_QUESTIONNAIRE" || message.text =~ /yes/i
      user.set_command(:ask_name)
      say(user, "Great! What's your name?")
      say(user, "(type 'Stop' at any point to exit)")
      p user.current_command # debug
    else
      say(user, "No problem! Let's do it later")
      user.reset_command
    end
  end

  # Name
  def ask_name(message, user)
    p user.current_command # debug
    # Fallback functionality if stop word used or user input is not text
    fall_back(message, user) and return
    user.answers[:name] = message.text
    say(user, "What's your gender?", UIElements::QuickReplies.new(["Male", "MALE"],
                                                                  ["Female", "FEMALE"])
                                                                  .build)
    user.set_command(:ask_gender)
  end

  def ask_gender(message, user)
    p user.current_command
    fall_back(message, user) and return
    user.answers[:gender] = message.text
    replies = UIElements::QuickReplies.new(["I'd rather not say", "NO_AGE"]).build
    say(user, "Finally, how old are you?", replies)
    user.set_command(:ask_age)
  end

  def ask_age(message, user)
    p user.current_command
    fall_back(message, user) and return
    if message.quick_reply == "NO_AGE"
      user.answers[:age] = "hidden"
    else
      user.answers[:age] = message.text
    end
    stop_questionnaire(message, user)
  end

  def stop_questionnaire(message, user)
    user.reset_command
    show_results(message, user)
    user.answers = {}
  end

  def show_results(message, user)
    say(user, "OK. Here's what we now about you so far:")
    name, gender, age = user.answers.values
    text = "Name: #{name.nil? ? "N/A" : name}, " +
           "gender: #{gender.nil? ? "N/A" : gender}, " +
           "age: #{age.nil? ? "N/A" : age}"
    say(user, text)
    say(user, "Thanks for your time!")
  end

  def fall_back(message, user) # sanity check on each step
    say(user, "You tried to fool me, human! Start over!") unless is_text_message?(message)
    if !is_text_message?(message) || stop_word_used(message, "Stop")
      stop_questionnaire(message, user)
      return true # to trigger return from the caller on 'and return'
    end
    return false
  end

  # specify stop word
  def stop_word_used(message, word)
    !(message.text =~ /#{word.downcase}/i).nil?
  end
end
