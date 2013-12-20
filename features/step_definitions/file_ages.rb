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
