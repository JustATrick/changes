def later_than(time)
  a_bit = 10
  time + a_bit
end

def update_mtime(filename, new_mtime)
  File.utime(File.atime(filename), new_mtime, filename)
end

def enforce_mtime_order(first, second)
  write_file(first, '')
  write_file(second, '')
  in_current_dir do
    update_mtime(second, later_than(File.mtime(first)))
  end
end

Given(/^file "(.*?)" is modified before file "(.*?)"$/) do |first, second|
  enforce_mtime_order(first, second)
end

Given(/^file "(.*?)" is modified after file "(.*?)"$/) do |second, first|
  enforce_mtime_order(first, second)
end

Given(/^a directory named "(.*?)" with no file modified after file "(.*?)"$/) do |directory, last|
  files = ['top-level', 'sub-dir/nested']
  files.map { |file| "#{directory}/#{file}" }.each do |f|
    enforce_mtime_order(f, last)
  end
end
