# an example of chained sequence of commands while gathering the data
module Questionnaire
  def start_questionnaire(message, user)
    if message.quick_reply == "START_QUESTIONNAIRE"
      user.set_command(:first_question)
      say(user, "What is your name?")
      p user.current_command
    else
      user.reset_command
    end
  end

  def first_question(message, user)
    p user.current_command
    message.reply(text: message.text)
    user.reset_command
  end
end
