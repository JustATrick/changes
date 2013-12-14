def later_than(time)
  a_bit = 10
  time + a_bit
end

def update_mtime(filename, new_mtime)
  File.utime(File.atime(filename), new_mtime, filename)
end

def enforce_mtime_order(first, second)
  in_current_dir do
    update_mtime(second, later_than(File.mtime(first)))
  end
end

Given(/^"(.*?)" is modified before "(.*?)"$/) do |first, second|
  enforce_mtime_order(first, second)
end

Given(/^"(.*?)" is modified after "(.*?)"$/) do |second, first|
  enforce_mtime_order(first, second)
end
