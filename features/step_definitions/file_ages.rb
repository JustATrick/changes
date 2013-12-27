Given(/^file "(.*?)" is modified before file "(.*?)"$/) do |first, second|
  in_current_dir do
    ensure_files_exist(second)
    create_with_mtime(first, earlier_than(mtime_of(second)))
  end
end

Given(/^file "(.*?)" is modified after file "(.*?)"$/) do |second, first|
  in_current_dir do
    ensure_files_exist(first)
    create_with_mtime(second, later_than(mtime_of(first)))
  end
end

Given(/^a directory named "(.*?)" with no file modified after file "(.*?)"$/) do |directory, last|
  in_current_dir do
    ensure_files_exist(last)
    create_with_mtime(
      paths_for_directory(directory),
      earlier_than(mtime_of(last))
    )
  end
end

Given(/^a directory named "(.*?)" with one file modified after file "(.*?)"$/) do |directory, anchor|
  in_current_dir do
    ensure_files_exist(anchor)
    create_with_mtime(
      paths_for_directory(directory),
      earlier_than(mtime_of(anchor))
    )
    create_with_mtime(
      File.join(directory, 'deeply', 'nested'),
      later_than(mtime_of(anchor))
    )
  end
end
