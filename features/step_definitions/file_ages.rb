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

Given(/^file "(.*?)" is modified before file "(.*?)"$/) do |first, second|
  write_file(first, '')
  write_file(second, '')
  enforce_mtime_order(first, second)
end

Given(/^"(.*?)" is modified before "(.*?)"$/) do |first, second|
  enforce_mtime_order(first, second)
end

Given(/^"(.*?)" is modified after "(.*?)"$/) do |second, first|
  enforce_mtime_order(first, second)
end

Given(/^a directory named "(.*?)" with no file modified after "(.*?)"$/) do |directory, last|
  files = ['top-level', 'sub-dir/nested']
  files.map { |file| "#{directory}/#{file}" }.each do |f|
    write_file(f, '')
    enforce_mtime_order(f, last)
  end
end
