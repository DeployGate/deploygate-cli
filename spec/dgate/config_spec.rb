describe Dgate::Config do
  describe "#write" do
    it "write data" do
      write_data = {
          :name => 'test',
          :token => 'token'
      }
      allow(File).to receive(:open).and_return(StringIO.new("", "w+"))
      Dgate::Config.write(write_data)

      file = File.open(Dgate::Config.file_path)
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
      data = Dgate::Config.read

      expect(data).to eq(JSON.parse(write_data))
    end
  end
end
