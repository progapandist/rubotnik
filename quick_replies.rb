module UIElements
  class QuickReplies

    # TODO: account for content_type: "location" and "image_url"

    # Takes a list of arguments (splat on a call if passing an array!)
    # that can be hashes with keys :title, :payload,
    # :content_type (defaults to "text" if omitted)
    # OR arrays of two elements in form ["title", "PAYLOAD"] (simplified syntax),
    # OR both types, mixed.
    # Number of quick replies is limited to 11 by Messenger API

    def initialize(*replies)
      @replies = replies
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
      raise ArgumentError, error_msg unless reply.key?(:payload)
      reply
    end

    def build_from_array(reply)
      error_msg = "Only accepts arrays of two elements"
      raise ArgumentError, error_msg if reply.length != 2
      { content_type: 'text', title: reply[0].to_s, payload: reply[1].to_s }
    end

  end
end
