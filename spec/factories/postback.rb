# frozen_string_literal: true

FactoryBot.define do
  factory :postback, class: Facebook::Messenger::Incoming::Postback do
    skip_create
    initialize_with { new(attributes.stringify_keys) }

    transient do
      sender_id 1
      payload 'bla'
    end

    sender { { 'id' => sender_id } }
    postback { { 'payload' => payload } }
  end
end
