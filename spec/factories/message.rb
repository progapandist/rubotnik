# frozen_string_literal: true

FactoryBot.define do
  factory :message, class: Facebook::Messenger::Incoming::Message do
    skip_create
    initialize_with { new(attributes.stringify_keys) }

    transient do
      sender_id 1
      text 'bla'
    end

    sender { { 'id' => sender_id } }
    message { { 'text' => text } }
  end
end
