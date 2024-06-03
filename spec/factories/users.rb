FactoryBot.define do
  factory :user do
    id { 3 }
    name { "test1" }
    config { "{ \"days\": \"m,w,f\", \"time\": \"15m\" }" }
    schedule { "{ \"Wednesday\": [\"foo\"] }" }
  end
end
