require 'mtime_utils'

TMP_DIR = 'tmp/spec'

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    FileUtils.cd(TMP_DIR)
  end
end

describe "create_file" do
  context "when no parent directories exist" do
    context "when creating a nested file" do
      before(:each) do
        @nested_file = 'a/b/c'
        @created_dirs = create_file(@nested_file)
      end

      it "creates the file and the parent directories" do
        expect(File.file?(@nested_file)).to be(true)
      end

      it "returns the list of created dirs" do
        expect(@created_dirs).to eq([File.join('a'), File.join('a', 'b')])
      end
    end
  end

  context "when one of the parent directories exists" do
    before(:each) do
      FileUtils.mkdir('a')
      @nested_file = 'a/b/c'
      @created_dirs = create_file(@nested_file)
    end

    it "returns only the dirs that were created" do
      expect(@created_dirs).to eq([File.join('a', 'b')])
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
       "than the directory's"

    it "doesn't change the directory's mtime when the new file's " +
       "mtime is earlier than the directory's"
  end
end
