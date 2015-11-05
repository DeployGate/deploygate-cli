describe DeployGate::Config::Base do
  before do
    allow(DeployGate::Config::Base).to receive(:file_path).and_return(File.join(SPEC_FILE_PATH, 'test_files/.dg/base'))
  end

  describe "#write" do
    it "write data" do
      write_data = {
          :name => 'test',
          :token => 'token'
      }
      allow(File).to receive(:open).and_return(StringIO.new("", "w+"))
      DeployGate::Config::Base.write(write_data)

      file = File.open(DeployGate::Config::Base.file_path)
      expect(file.string).to eq(write_data.to_json.to_s)
    end
  end

  describe "#read" do
    it "read data" do
      write_data = {
          :name => 'test',
          :token => 'token'
      }.to_json.to_s
      allow(File).to receive(:open).and_return(StringIO.new(write_data))
      data = DeployGate::Config::Base.read

      expect(data).to eq(JSON.parse(write_data))
    end
  end
end
