module UI
  # https://developers.facebook.com/docs/messenger-platform/send-api-reference/quick-replies
  class QuickReplies
    def self.build(*replies)
      replies.map do |reply|
        case reply
        when Hash then build_from_hash(reply)
        when Array then build_from_array(reply)
        else
          raise ArgumentError, 'Arguments should be hashes or arrays of two'
        end
      end
    end

    def self.location
      [{ content_type: 'location' }]
    end

    private_class_method def self.build_from_hash(reply)
      unless reply.key?(:content_type)
        reply[:content_type] = 'text'
        error_msg = "type 'text' should have a payload"
        raise ArgumentError, error_msg unless reply.key?(:payload)
      end
      reply
    end

    private_class_method def self.build_from_array(reply)
      error_msg = 'Only accepts arrays of two elements'
      raise ArgumentError, error_msg if reply.length != 2
      { content_type: 'text', title: reply[0].to_s, payload: reply[1].to_s }
    end
  end
end
