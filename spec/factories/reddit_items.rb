FactoryBot.define do
  factory :reddit_item do
    sequence(:reddit_id) { |n| "t3_#{n}" }
    item_type { :post }
    title { "My game finally has a working save system" }
    body { "After months of bugs, saving and loading finally works end to end." }
    author { "some_gamedev" }
    score { 42 }
    permalink { "https://www.reddit.com/r/gamedev/comments/example/" }
    posted_at { 3.days.ago }

    trait :comment do
      item_type { :comment }
      title { nil }
      sequence(:reddit_id) { |n| "t1_#{n}" }
      association :post, factory: :reddit_item
      parent_reddit_id { post.reddit_id }
      body { "Congrats, that's a huge milestone!" }
    end
  end
end
