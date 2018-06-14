FactoryGirl.define do
  factory :laboratory do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    deadline { Faker::Date.forward }
    done false
    user
  end
end