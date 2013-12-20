DELTA = 10

def later_than(time)
  time + DELTA
end

def earlier_than(mtime)
  mtime - DELTA
end

def create_file(file)
    FileUtils.mkdir_p(File.dirname(file))
    File.open(file, 'w') { }
end

def update_mtime(filenames, new_mtime)
  [*filenames].each do |f|
    File.utime(File.atime(f), new_mtime, f)
  end
end

def ensure_files_exist(files)
  [*files].each do |file|
    create_file(file) unless File.file?(file)
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

def mtime_of(file)
  File.mtime(file)
end

def create_with_mtime(files, mtime)
  [*files].each do |file|
    if File.file?(file)
      raise "File '#{file}' was already created. Changing its mtime now " +
            "might ruin timing relationships set up earlier."
    end
    create_file(file)
    update_mtime(file, mtime)
  end
end

Given(/^file "(.*?)" is modified before file "(.*?)"$/) do |first, second|
  in_current_dir do
    ensure_files_exist(second)
    create_with_mtime(first, earlier_than(mtime_of(second)))
  end
end

Given(/^the following files were modified before file "(.*?)":$/) do |second, table|
  in_current_dir do
    ensure_files_exist(second)
    create_with_mtime(table.raw.flatten, earlier_than(mtime_of(second)))
  end
end

Given(/^file "(.*?)" is modified after file "(.*?)"$/) do |second, first|
  in_current_dir do
    ensure_files_exist(first)
    create_with_mtime(second, later_than(mtime_of(first)))
  end
end

Given(/^a directory named "(.*?)" with no file modified after file "(.*?)"$/) do |directory, last|
  files = ['top-level', File.join('sub-dir', 'nested')]
  created_directories = [directory, File.join(directory, 'sub-dir')]
  paths = files.map { |file| File.join(directory, file) }
  in_current_dir do
    ensure_files_exist(last)
    create_with_mtime(paths, earlier_than(mtime_of(last)))
    update_mtime(created_directories, earlier_than(mtime_of(last)))
  end
end
