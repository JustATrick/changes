def later_than(time)
  a_bit = 10
  time + a_bit
end

def update_mtime(filenames, new_mtime)
  [*filenames].each do |f|
    File.utime(File.atime(f), new_mtime, f)
  end
end

def ensure_files_exist(files)
  files.each do |file|
    FileUtils.mkdir_p(File.dirname(file))
    File.open(file, 'w') { } unless File.file?(file)
  end
end

def latest_mtime_of(files)
  files.map { |f| File.mtime(f) }.max
end

def enforce_mtime_order(first, second)
  first_files = [*first]
  second_files = [*second]
  in_current_dir do
    ensure_files_exist(first_files + second_files)
    update_mtime(second_files, later_than(latest_mtime_of(first_files)))
  end
end

Given(/^file "(.*?)" is modified before file "(.*?)"$/) do |first, second|
  enforce_mtime_order(first, second)
end

Given(/^the following files were modified before file "(.*?)":$/) do |second, table|
  enforce_mtime_order(table.raw.flatten, second)
end

Given(/^file "(.*?)" is modified after file "(.*?)"$/) do |second, first|
  enforce_mtime_order(first, second)
end

Given(/^a directory named "(.*?)" with no file modified after file "(.*?)"$/) do |directory, last|
  files = ['top-level', File.join('sub-dir', 'nested')]
  paths = files.map { |file| File.join(directory, file) }
  enforce_mtime_order(paths, last)
end
