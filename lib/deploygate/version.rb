module DeployGate
  VERSION = '0.9.0'
  VERSION_CODE = Gem::Version.new(VERSION).segments.reverse.each_with_index.map { |v, i| 100 ** i * v }.reduce(&:+)
end
