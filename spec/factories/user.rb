# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: Rubotnik::User do
    skip_create
    initialize_with { new(attributes[:id].to_s) }

    sequence(:id) { |n| n }

    trait :with_commands do
      transient do
        commands { [] }
      end

      after(:build) do |user, evaluator|
        evaluator.commands.each { |c| user.assign_command(c) }
      end
    end
  end
end
