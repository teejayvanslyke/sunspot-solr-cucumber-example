Given(/^there is a brand named "([^"]*)"$/) do |name|
  Brand.create!(name: name)
end
