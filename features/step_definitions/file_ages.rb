Given(/^"(.*?)" is modified before "(.*?)"$/) do |early, later|
  in_current_dir do
    File.utime(File.atime(early), File.mtime(early) + 10, later)
  end
end
