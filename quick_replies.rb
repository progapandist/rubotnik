module UIElements

  class QuickReplies

    # TODO: account for content_type: "location" and "image_url"

    # Takes an array of hashes with keys :title, :payload
    # or :content_type (defaults to "text" if omitted)
    # Can also be invoked with a list of arguments
    # that can be either hashes of the same form,
    # or arrays of two elements in form ["title", "PAYLOAD"] (simplified syntax),
    # or mixed.
    # Number of quick replies is limited to 11 by Messenger API

    def initialize(array_replies = [], *args_replies)
      @replies = array_replies unless array_replies.empty?
    end

    def build
      @replies.map do |reply|
        case reply
        when Hash then build_from_hash(reply)
        when Array then build_from_array(reply)
        else
          raise ArgumentError, "Arguments should be hashes or arrays of two"
        end
      end
    end

    private

    def build_from_hash(reply)
      reply[:content_type] = "text" unless reply.key?(:content_type)
      error_msg = "type 'text' should have a payload"
      raise ArgumentError, error_msg  unless reply.key?(:payload)
      reply
    end

    def build_from_array(reply)
      error_msg = "Only accepts arrays of two elements"
      raise ArgumentError, error_msg if reply.length != 2
      { content_type: 'text', title: reply[0].to_s, payload: reply[1].to_s }
    end

  end

  # p  QuickReplies.new({title: "Yes", payload: "YES"}, ["No", "NO"]).build
end
