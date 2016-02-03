require 'jsonpath'
require 'erb'

When /^I send JSON$/ do
  @headers ||= {}
  @headers['Content-Type'] = 'application/json'
end

When /^I accept "(.*?)"$/ do |type|
  @headers ||= {}
  @headers['Accept'] = type
end

When /^I send the file "(.*?)" as "(.*?)"$/ do |filename, param|
  @files = {}
  @files[param] = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', filename), "image/jpeg")
end

Given /^I set the request header "(.*?)" to "(.*?)"$/ do |name, value|
  @headers ||= {}
  @headers[name] = ERB.new(value).result(binding)
end

When /^I send a (GET|POST|PUT|DELETE) request (?:for|to) "([^"]*)"(?: with the following:)?$/ do |*args|
  method = args.shift
  url = ERB.new(args.shift).result(binding)
  input = args.shift

  @headers ||= {}

  opts = @headers.merge(
    method: method.downcase.to_sym,
  )

  unless input.nil?
    if input.class == Cucumber::Ast::Table
      opts[:params] = input.rows_hash
    else
      opts[:params] = JSON.parse(ERB.new(input).result(binding))
    end
  end

  if @files && @files.any?
    opts[:params] ||= {}
    opts[:params].merge! @files
  end

  request url, opts
  @headers = {}
end


Then /^the response status should be "(.*?)"$/ do |code|
  last_response.status.should == code.to_i
end

Then /^show me the response$/ do
  if last_response.headers['Content-Type'] =~ /json/
    begin
      json_response = JSON.parse(last_response.body)
      puts JSON.pretty_generate(json_response)
    rescue
      puts last_response.body
    end
  elsif last_response.headers['Content-Type'] =~ /xml/
    puts Nokogiri::XML(last_response.body)
  else
    puts last_response.headers
    puts last_response.body
  end
end

Then /^the JSON response should (not)?\s?have "([^"]*)" with the text "([^"]*)"$/ do |negative, json_path, text|
  json    = JSON.parse(last_response.body)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
  text    = ERB.new(text).result(binding)
  if self.respond_to?(:should)
    if negative.present?
      results.join.should_not include(text)
    else
      results.join.should include(text)
    end
  else
    if negative.present?
      assert !results.include?(text)
    else
      assert results.include?(text)
    end
  end
end

Then /^the XML response should have "([^"]*)" with the text "([^"]*)"$/ do |xpath, text|
  parsed_response = Nokogiri::XML(last_response.body)
  elements        = parsed_response.xpath(xpath)
  text            = ERB.new(text).result(binding)
  if self.respond_to?(:should)
    elements.should_not be_empty, "could not find #{xpath} in:\n#{last_response.body}"
    elements.find { |e| e.text == text }.should_not be_nil, "found elements but could not find #{text} in:\n#{elements.inspect}"
  else
    assert !elements.empty?, "could not find #{xpath} in:\n#{last_response.body}"
    assert elements.find { |e| e.text == text }, "found elements but could not find #{text} in:\n#{elements.inspect}"
  end
end

Then 'the JSON response should be:' do |json|
  expected = JSON.parse(ERB.new(json).result(binding))
  actual = JSON.parse(last_response.body)

  if self.respond_to?(:should)
    actual.should == expected
  else
    assert_equal actual, response
  end
end

Then /^the JSON response should have "([^"]*)" with a length of (\d+)$/ do |json_path, length|
  json = JSON.parse(last_response.body)
  results = JsonPath.new(json_path).on(json)
  if self.respond_to?(:should)
    results.length.should == length.to_i
  else
    assert_equal length.to_i, results.length
  end
end

Then /^the JSON response should have a length of (\d+)$/ do |length|
  json = JSON.parse(last_response.body)
  json.length.should == length.to_i
end

When(/^I follow the redirect$/) do
  follow_redirect!
end

Then /^the JSON response should render nothing$/ do
  last_response.body.length.should == 0
end
