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
          title: 'Sample UI elements',
          payload: 'SAMPLE_UI_ELEMENTS'
        },
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
#
  end
end


# # NOTE: We don't use facebook-messenger's Facebook::Messenger::Thread.set
# # because it doesn't support latest API updates by Facebook
#
# base_uri "https://graph.facebook.com/v2.6/me/messenger_profile?access_token="
#
# structure = {:persistent_menu=>
# [{:locale=>"default",
#   :composer_input_disabled=>true,
#   :call_to_actions=>
#    [{:title=>"My Account",
#      :type=>"nested",
#      :call_to_actions=>
#       [{:title=>"Pay Bill", :type=>"postback", :payload=>"PAYBILL_PAYLOAD"},
#        {:title=>"History", :type=>"postback", :payload=>"HISTORY_PAYLOAD"},
#        {:title=>"Contact Info", :type=>"postback", :payload=>"CONTACT_INFO_PAYLOAD"}]},
#     {:type=>"web_url",
#      :title=>"Latest News",
#      :url=>"http://petershats.parseapp.com/hat-news",
#      :webview_height_ratio=>"full"}]},
#  {:locale=>"zh_CN", :composer_input_disabled=>false}]}
#
#
# p post(ENV["ACCESS_TOKEN"], structure)
