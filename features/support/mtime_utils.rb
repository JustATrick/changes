DELTA = 10

def later_than(time)
  time + DELTA
end

def earlier_than(mtime)
  mtime - DELTA
end

def parent_directories_it(parents, dir)
  if (dir == '.')
    parents.reverse
  else
    parent_directories_it(parents << dir, File.dirname(dir))
  end
end

def parent_directories(file)
  parent_directories_it([], File.dirname(file))
end

def non_existent(directories)
  directories.select do |dir|
    not File.directory?(dir)
  end
end

def create_file(file)
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

def mtime_earlier_than(file_or_dir_names, mtime)
  file_or_dir_names.select do |node|
    mtime_of(node) < mtime
  end
end

def create_with_mtime(files, mtime)
  [*files].each do |file|
    if File.file?(file)
      raise "File '#{file}' was already created. Changing its mtime now " +
            "might ruin timing relationships set up earlier."
    end
    parents = parent_directories(file)
    parents_to_create = non_existent(parents)
    FileUtils.mkdir(parents_to_create)
    create_file(file)
    parents_to_update = parents_to_create + mtime_earlier_than(parents, mtime)
    update_mtime(parents_to_update << file, mtime)
  end
end
