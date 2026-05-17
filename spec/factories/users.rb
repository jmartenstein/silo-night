FactoryBot.define do

  factory :show do
    sequence(:name) { |n| "Show #{n}" }
    uri_encoded { "show+#{name.parameterize}" }

    transient do
      runtime { "30 minutes" }
      poster_path { "/path/to/poster.jpg" }
    end

    trait :with_metadata do
      after(:create) do |show, evaluator|
        create(:show_metadata, 
               show: show, 
               payload: { 
                 "name" => show.name,
                 "runtime" => evaluator.runtime, 
                 "poster_path" => evaluator.poster_path 
               })
      end
    end
  end

  factory :show_metadata do
    provider_name { "tmdb" }
    sequence(:external_id) { |n| "tmdb_#{n}" }
    payload { { "runtime" => "30 minutes", "poster_path" => "/path/to/poster.jpg" } }
    association :show
  end

  factory :user do
    sequence(:name) { |n| "user#{n}" }
    config { "{ \"days\": \"m,w,f\", \"time\": \"15m\" }" }
    schedule { "{}" }

    trait :admin do
      config { "{ \"admin\": true, \"days\": \"m,w,f\", \"time\": \"15m\" }" }
    end
  end

end
