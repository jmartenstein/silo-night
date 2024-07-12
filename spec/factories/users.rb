FactoryBot.define do

  factory :show do
    id { 2 }
    runtime{ "5-7 minutes" }
  end

  factory :user do

    id { 3 }
    name { "user1" }
    config { "{ \"days\": \"m,w,f\", \"time\": \"15m\" }" }
    schedule { "{ \"Wednesday\": [\"foo\"] }" }

  end

end
