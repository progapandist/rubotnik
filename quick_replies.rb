module UIElements

  class QuickReplies
    # [{title: String, payload: String}, {title: String, payload: String}]
    # Takes an array of hashes
    # TODO: Check if the number of QR exceeded
    def initialize(replies)
      @replies = replies
      @replies = [replies] if replies.class == Hash
    end

    def build
      @replies.map do |reply|
        reply[:content_type] = "text" unless reply.key?(:content_type)
        # TODO: raise exception of content_type is text and no payload provided
        reply
      end
    end
  end
end
