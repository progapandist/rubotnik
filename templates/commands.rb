module Commands
  # You will write all your commands as methods here

  # If the command is bound with opening_message specified,
  # you have to deal with incoming message and react on it.
  def ask
    @message.typing_on
    if @message.quick_reply == 'YES'
      say "Thank you, I'm touched!"
    else
      say "Guess you can't please everyone, huh?"
    end
    @message.typing_off 
    stop_thread # you have to stop thread or pass control further
  end
end
