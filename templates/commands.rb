module Commands
  # You can write all your commands as methods here

  # If the command is bound with reply_with specified,
  # you have to deal with user response to the last message and react on it.
  def start_conversation
    # Quick replies are accessible through message object's quick_reply property,
    # by default it's the quick reply text in ALL CAPS
    # you can also react on the text itself
    message.typing_on
    case message.quick_reply
    when 'OK'
      say "Glad you're doing well!"
      stop_thread
    when 'NOT_OK'
      say "Too bad. What happened?"
      next_command :appear_nice
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
    stop_thread # future messages from user will be handled from top-level bindings
  end
end
