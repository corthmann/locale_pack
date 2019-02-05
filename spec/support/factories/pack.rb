FactoryBot.define do
  factory :pack, class: LocalePack::Pack do
    id { locale ? "#{name}_#{locale}" : name }
    name { 'test' }
    digest { '1234' }
    locale { nil }

    factory :pack_with_locale do
      locale { :da }
    end
  end
end
