require 'mtime_utils'

TMP_DIR = 'tmp/spec'

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    FileUtils.cd(TMP_DIR)
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
