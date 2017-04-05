class PersistentMenu
  def self.enable
    # Create persistent menu
    # TODO: Intoduce nesting for UI elements examples
    Facebook::Messenger::Thread.set({
      setting_type: 'call_to_actions',
      thread_state: 'existing_thread',
      call_to_actions: [
        {
          type: 'postback',
          title: 'Location lookup',
          payload: 'LOCATION'
        },
        {
          type: 'postback',
          title: 'Sample questionnaire',
          payload: 'QUESTIONNAIRE'
        }
      ]
    }, access_token: ENV['ACCESS_TOKEN'])
  end
end
