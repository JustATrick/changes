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
    write_file(file, '') unless File.file?(file)
  end
end

def latest_mtime_of(files)
  files.map { |f| File.mtime(f) }.max
end

def enforce_mtime_order(first, second)
  first_files = [*first]
  second_files = [*second]
  ensure_files_exist(first_files + second_files)
  in_current_dir do
    update_mtime(second_files, later_than(latest_mtime_of(first_files)))
  end
end

Given(/^file "(.*?)" is modified before file "(.*?)"$/) do |first, second|
  enforce_mtime_order(first, second)
end

Given(/^file "(.*?)" is modified after file "(.*?)"$/) do |second, first|
  enforce_mtime_order(first, second)
end

Given(/^a directory named "(.*?)" with no file modified after file "(.*?)"$/) do |directory, last|
  files = ['top-level', File.join('sub-dir', 'nested')]
  paths = files.map { |file| File.join(directory, file) }
  enforce_mtime_order(paths, last)
end
