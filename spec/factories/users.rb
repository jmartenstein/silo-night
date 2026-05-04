FactoryBot.define do

  factory :show do
    runtime{ "5-7 minutes" }
  end

  factory :user do

    name { "user1" }
    config { "{ \"days\": \"m,w,f\", \"time\": \"15m\" }" }
    schedule { "{ \"Wednesday\": [\"foo\"] }" }

  end

end
