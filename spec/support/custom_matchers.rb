# frozen_string_literal: true

RSpec::Matchers.define :have_included do |expected|
  match do |actual|
    expect(actual.class).to include(expected)
  end
end

RSpec::Matchers.define :have_attr_accessor do |attribute_name|
  match do |actual|
    expect(actual.class.new).to respond_to(attribute_name)
    expect(actual.class.new).to respond_to("#{attribute_name}=")
  end
end

RSpec::Matchers.define :have_included_modules do |expected|
  match do |actual|
    entries = actual.class.included_modules.map(&:to_s).map { |class_name| class_name.gsub(/\#|<|>/, '') }
    expect(entries).to include(expected)
  end
end

RSpec::Matchers.define :have_where_values do |hash|
  match do |actual|
    expect(actual.where_values_hash.symbolize_keys).to eql(hash)
  end
end
