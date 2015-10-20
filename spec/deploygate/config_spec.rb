describe DeployGate::Config do
  describe "#write" do
    it "write data" do
      write_data = {
          :name => 'test',
          :token => 'token'
      }
      allow(File).to receive(:open).and_return(StringIO.new("", "w+"))
      DeployGate::Config.write(write_data)

      file = File.open(DeployGate::Config.file_path)
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
      data = DeployGate::Config.read

      expect(data).to eq(JSON.parse(write_data))
    end
  end
end
