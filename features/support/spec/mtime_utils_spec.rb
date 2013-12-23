require 'mtime_utils'

TMP_DIR = 'tmp/spec'

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    FileUtils.cd(TMP_DIR)
  end
end

describe "dependents_of" do
  it "returns a list of all filesystem entries that might be affected by a " +
     "change of mtime on a relative path, in order of outermost down to " +
     "innermost" do
    expect(dependents_of('a/b/c/d/e'))
        .to eq(['a', 'a/b', 'a/b/c', 'a/b/c/d', 'a/b/c/d/e'])
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
      original_time = Time.now - 10 # sometime in the past
      update_mtime('a', original_time)
      create_with_mtime('a/c', earlier_than(original_time))
      expect(File.mtime('a')).to eq(original_time)
    end
  end
end
