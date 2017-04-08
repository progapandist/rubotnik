# Showcases a chained sequence of commands that gather the data
# and store it in the answers hash inside the User instance       .

module Questionnaire
  def start_questionnaire
    if @message.quick_reply == "START_QUESTIONNAIRE" || @message.text =~ /yes/i
      say "Great! What's your name?"
      say "(type 'Stop' at any point to exit)"
      next_command :ask_name
    else
      say "No problem! Let's do it later"
      stop_thread
    end
  end

  # Name
  def ask_name
    # Fallback functionality if stop word used or user input is not text
    fall_back and return
    @user.answers[:name] = @message.text
    replies = UI::QuickReplies.build(["Male", "MALE"], ["Female", "FEMALE"])
    say "What's your gender?", quick_replies: replies
    next_command :ask_gender
  end

  def ask_gender
    fall_back and return
    @user.answers[:gender] = @message.text
    reply = UI::QuickReplies.build(["I'd rather not say", "NO_AGE"])
    say "Finally, how old are you?", quick_replies: reply
    next_command :ask_age
  end

  def ask_age
    fall_back and return
    if @message.quick_reply == "NO_AGE"
      @user.answers[:age] = "hidden"
    else
      @user.answers[:age] = @message.text
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
    name, gender, age = @user.answers.values
    text = "Name: #{name.nil? ? "N/A" : name}, " +
           "gender: #{gender.nil? ? "N/A" : gender}, " +
           "age: #{age.nil? ? "N/A" : age}"
    say text
    say "Thanks for your time!"
  end

  # NOTE: A way to enforce sanity checks (repeat for each sequential command)
  def fall_back
    say "You tried to fool me, human! Start over!" unless text_message?
    if !text_message? || stop_word_used?("Stop")
      stop_questionnaire
      puts "Fallback triggered!"
      return true # to trigger return from the caller on 'and return'
    end
    return false
  end

  # specify stop word
  def stop_word_used?(word)
    !(@message.text =~ /#{word.downcase}/i).nil?
  end
end
