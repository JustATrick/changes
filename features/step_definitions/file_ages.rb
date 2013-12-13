Given(/^"(.*?)" is modified before "(.*?)"$/) do |_, modified|
  append_to_file(modified, 'modified')
end
