DELTA = 10

def later_than(time)
  time + DELTA
end

def earlier_than(mtime)
  mtime - DELTA
end

def iterate_dependents_of(dependents, entry)
  if (entry == '.')
    dependents.reverse
  else
    iterate_dependents_of(dependents << entry, File.dirname(entry))
  end
end

def dependents_of(file)
  iterate_dependents_of([], file)
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

def mtime_of(file)
  File.mtime(file)
end

class MtimeAfterUpdate
  def initialize(entry, mtime)
    @entry = entry
    @mtime = File.exists?(entry) ? [mtime_of(entry), mtime].max : mtime
  end

  def apply_to_filesystem()
    update_mtime(@entry, @mtime)
  end
end

class MtimesAfterUpdate
  def initialize(entries, new_mtime)
    @entries = entries.map { |e| MtimeAfterUpdate.new(e, new_mtime) }
  end

  def apply_to_filesystem()
    @entries.each do |e|
      e.apply_to_filesystem()
    end
  end
end

def create_with_mtime(files, mtime)
  [*files].each do |file|
    if File.file?(file)
      raise "File '#{file}' was already created. Changing its mtime now " +
            "might ruin timing relationships set up earlier."
    end
    mtimes = MtimesAfterUpdate.new(dependents_of(file), mtime)
    create_file(file)
    mtimes.apply_to_filesystem()
  end
end

def paths_for_directory(directory_name)
  files = ['top-level', File.join('sub-dir', 'nested')]
  paths = files.map { |file| File.join(directory_name, file) }
end
