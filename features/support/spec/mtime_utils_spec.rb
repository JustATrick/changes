require 'mtime_utils'

TMP_DIR = 'tmp/spec'

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    FileUtils.cd(TMP_DIR)
  end
end

describe "parent_directories" do
  it "returns a list of all directories in the hierarchy of a relative path" +
     "in order of outermost down to innermost" do
    expect(parent_directories('a/b/c/d/e'))
        .to eq(['a', 'a/b', 'a/b/c', 'a/b/c/d'])
  end
end

describe "non_existent" do
  it "returns a list of only directories that don't exist, preserving order" do
    FileUtils.mkdir_p(['a', 'b', 'c/d'])
    to_test = ['e', 'a', 'f', 'b', 'c/d/g', 'c', 'c/d']
    expect(non_existent(to_test)).to eq(['e', 'f', 'c/d/g'])
  end
end

describe "create_file" do
  before(:each) do
    @target_dir = 'a/b'
    @nested_file = File.join(@target_dir, 'c')
  end

  context "when the target directory exists" do
    before(:each) do
      FileUtils.mkdir_p(@target_dir)
    end

    it "creates a file" do
      create_file(@nested_file)
      expect(File.file?(@nested_file)).to be(true)
    end
  end

  context "when the target directory does not exist" do
    it "raises an error" do
      expect { create_file(@nested_file) }.to raise_error
    end
  end
end

describe "mtime_earlier_than" do
  before(:each) do
    earlier_files = ['a', 'b', 'c']
    later_files = ['d', 'e', 'f']
    earlier_dirs = ['g', 'h', 'i']
    later_dirs = ['j', 'k', 'l']
    (earlier_files + later_files).each do |file|
      File.open(file, 'w') { }
    end
    FileUtils.mkdir(earlier_dirs + later_dirs)
    @all = earlier_files + later_files + earlier_dirs + later_dirs
    @earlier = earlier_files + earlier_dirs
    later = later_files + later_dirs
    @specified_time = Time.new(2014)
    update_mtime(@earlier, earlier_than(@specified_time))
    update_mtime(later, later_than(@specified_time))
  end

  it "returns only those files and directories with mtime earlier than " +
     "the one specified" do
    expect(mtime_earlier_than(@all, @specified_time)).to eq(@earlier)
  end
end

describe "create_with_mtime" do

  context "creating a directory" do
    it "sets the directory's mtime" do
      time = Time.new(2013)
      create_with_mtime('a/c', time)
      expect(File.mtime('a')).to eq(time)
    end
  end

  context "adding a file to an existing directory" do
    it "sets the directory's mtime when the new file's mtime is older " +
       "than the directory's" do
      FileUtils.mkdir('a')
      new_time = later_than(File.mtime('a'))
      create_with_mtime('a/c', new_time)
      expect(File.mtime('a')).to eq(new_time)
    end

    it "doesn't change the directory's mtime when the new file's " +
       "mtime is earlier than the directory's" do
      FileUtils.mkdir('a')
      original_time = File.mtime('a')
      create_with_mtime('a/c', earlier_than(original_time))
      expect(File.mtime('a')).to eq(original_time)
    end
  end
end
