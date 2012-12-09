#delegate :parse_json, :to => JsonSpec::Helpers



RSpec::Matchers.define :render_json_meta do
  match do |response|
    if response.content_type.to_s.include?("application/json")
      response_json = JSON.parse(response.body)
      response_json.has_key?("meta")
    else
      false
    end
  end

  failure_message_for_should do |response|
    if response.content_type.to_s.include?("application/json")
      "Expected response to have a JSON meta, but it wasn't JSON"
    else
      "Expected response to have a JSON meta, but the JSON looked different"
    end
  end
end

RSpec::Matchers.define :render_json_meta_error_with_code do |code|
  match do |response|
    if response.content_type.to_s.include?("application/json")
      response_json = JSON.parse(response.body)
      if response_json.has_key?("meta") and response_json["meta"].has_key?("errors")
        response_json["meta"]["errors"].first["code"] == code
      else
        @error = "JSON doesn't have meta.errors key'"
        false
      end
    else
      @error = "Not JSON"
      false
    end
  end

  failure_message_for_should do |response|
    if @error
      "Expected response to have a JSON meta error, but #{@error}"
    else
      response_json = JSON.parse(response.body)
      "Expected response to have a JSON meta error with code #{code}, but it had #{response_json["meta"]["errors"].first["code"]}"
    end
  end
end

RSpec::Matchers.define :render_json_meta_warning_with_code do |code|
  match do |response|
    if response.content_type.to_s.include?("application/json")
      response_json = JSON.parse(response.body)
      if response_json.has_key?("meta") and response_json["meta"].has_key?("warnings")
        response_json["meta"]["warnings"].first["code"] == code
      else
        @warning = "JSON doesn't have meta.warnings key'"
        false
      end
    else
      @warning = "Not JSON"
      false
    end
  end

  failure_message_for_should do |response|
    if @warning
      "Expected response to have a JSON meta warning, but #{@warning}"
    else
      response_json = JSON.parse(response.body)
      "Expected response to have a JSON meta warning with code #{code}, but it had #{response_json["meta"]["warnings"].first["code"]}"
    end
  end
end

RSpec::Matchers.define :have_error_with_code do |code|
  match do |response_body|
    matcher = JsonSpec::Matchers::BeJsonEql.new({'code' => code}.to_json).at_path('meta/errors/0').excluding('message', 'description', 'index')
    matcher.matches?(response_body)
  end
end

RSpec::Matchers.define :have_warning_with_code do |code|
  match do |response_body|
    matcher = JsonSpec::Matchers::BeJsonEql.new({'code' => code}.to_json).at_path('meta/warnings/0').excluding('message', 'description')
    matcher.matches?(response_body)
  end
end

RSpec::Matchers.define :have_errors_or_warnings do |code|
  match do |response_body|
    JsonSpec::Matchers::HaveJsonPath.new('meta/errors').matches?(response_body) ||
        JsonSpec::Matchers::HaveJsonPath.new('meta/warnings').matches?(response_body)
  end
end

RSpec::Matchers.define :have_warnings_only do |code|
  match do |response_body|
    JsonSpec::Matchers::HaveJsonPath.new('meta/warnings').matches?(response_body) &&
        !JsonSpec::Matchers::HaveJsonPath.new('meta/errors').matches?(response_body)
  end
end

RSpec::Matchers.define :have_value_at_path do |value, path|
  match do |response_body|
    pp self.class.to_s
    JsonSpec::Helpersparse_json(response_body, path) == value
  end
end

RSpec::Matchers.define :be_a_paginated_collection_of do |klass|
  match do |collection|
    collection.respond_to?(:current_page) && collection.first.kind_of?(klass)
  end
end

RSpec::Matchers.define :all_have_status do |status|
  match do |list|
    statuses = list.map(&:status).uniq
    statuses.length == 1 && statuses.first == status
  end
end

RSpec::Matchers.define :have_errors_only do |code|
  match do |response_body|
    !JsonSpec::Matchers::HaveJsonPath.new('meta/warnings').matches?(response_body) &&
        JsonSpec::Matchers::HaveJsonPath.new('meta/errors').matches?(response_body)
  end
end
