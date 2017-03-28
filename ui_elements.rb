# Also known as 'generic template'
# https://developers.facebook.com/docs/messenger-platform/send-api-reference/generic-template

module UIElements

  class FBCarousel
    def initialize(opts = {})
      @template = {
        # TODO: Do we need to provide an id at init?
        recipient: { id: opts[:id]},
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'generic',
              elements: parse_elements(opts[:elements])
            }
          }
        }
      }
    end

    # TODO: Don't allow to send if we don't have an id or a single proper element
    def send(id)
      # Bot.deliver()
    end

    # MAKE METHODS BELOW PRIVATE AFTER TESTING

    # "elements":[
    #        {
    #         "title":"Welcome to Peter\'s Hats",
    #         "image_url":"https://petersfancybrownhats.com/company_image.png",
    #         "subtitle":"We\'ve got the right hat for everyone.",
    #         "default_action": {
    #           "type": "web_url",
    #           "url": "https://peterssendreceiveapp.ngrok.io/view?item=103",
    #           "messenger_extensions": true,
    #           "webview_height_ratio": "tall",
    #           "fallback_url": "https://peterssendreceiveapp.ngrok.io/"
    #         },
    #         "buttons":[
    #           {
    #             "type":"web_url",
    #             "url":"https://petersfancybrownhats.com",
    #             "title":"View Website"
    #           },{
    #             "type":"postback",
    #             "title":"Start Chatting",
    #             "payload":"DEVELOPER_DEFINED_PAYLOAD"
    #           }
    #         ]

    # [title: String, image_url: String, subtitle: String, default_url: String, buttons: []]
    def parse_elements(elements)
      # elements_hash = {}
      # elements.each do |element|
      #
      # end
    end

    # [type: :web_url, url: String, title: String]
    # [type: :postback, title: String, payload: String]
    def parse_buttons(buttons)
      return {} if buttons.nil? || buttons.empty?
      
    end

  end

  def carousel(id)
    Bot.deliver(
    {
      recipient: { id: id },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements: [
              {
                title: 'test title',
                buttons: [
                  {
                    type: "postback",
                    title: "test button",
                    payload: "PAYLOAD"
                  }
                ]
              }
            ]
          }
        }
      }
    }, access_token: ENV['ACCESS_TOKEN'])
  end

end
