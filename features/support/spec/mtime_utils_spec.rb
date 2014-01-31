require 'mtime_utils'

TMP_DIR = File.absolute_path('tmp/spec')

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
    it "still creates a file" do
      create_file(@nested_file)
      expect(File.file?(@nested_file)).to be(true)
    end
  end
end

shared_examples "it creates a file" do
  it "creates the file" do
    expect(File.file?(filename)).to be(true)
  end

  it "sets the file's mtime" do
    expect(File.mtime(filename)).to eq(time)
  end
end

shared_context "creates a file" do
  let(:dirname) { 'a' }
  let(:filename) { File.join(dirname, 'c') }
  before(:each) do
    create_with_mtime(filename, time)
  end
end

describe "create_with_mtime" do
  context "when directory doesn't exist" do
    include_context "creates a file" do
      let(:time) { Time.new(2013) }
    end

    it_behaves_like "it creates a file"

    it "sets the directory's mtime" do
      expect(File.mtime(dirname)).to eq(time)
    end
  end

  context "when directory does exist" do
    # sometime in the past, so that if anything modified the dir's mtime to
    # some value of 'now', then we'd be able to detect it.
    let(:directory_time) { Time.now - 100 }
    before(:each) do
      FileUtils.mkdir(dirname)
      update_mtime(dirname, directory_time)
    end
    include_context "creates a file" do
      let(:time) { later_than(directory_time) }
    end

    it_behaves_like "it creates a file"

    it "leaves the directory's mtime unchanged" do
      expect(File.mtime(dirname)).to eq(directory_time)
    end
  end

  context "when target file already exists" do
    include_context "creates a file" do
      let(:time) { Time.new(2014) }
    end

    it "raises an error" do
      expect { create_with_mtime(filename, nil) }.
        to raise_error(/already created/)
    end
  end
end
