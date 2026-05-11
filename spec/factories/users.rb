FactoryBot.define do

  factory :show do
    name { "Some Show" }
  end

  factory :user do
    name { "user1" }
    config { "{ \"days\": \"m,w,f\", \"time\": \"15m\" }" }
    schedule { "{ \"Wednesday\": [\"foo\"] }" }

    trait :admin do
      config { "{ \"admin\": true, \"days\": \"m,w,f\", \"time\": \"15m\" }" }
    end
  end

end
