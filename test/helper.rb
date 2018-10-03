require "xmlsimple"

def gen_bridge_metadata(header_file_name, option = {})
  version = RUBY_VERSION.sub(/^(\d+\.\d+)(\..*)?$$/, "\\1")
  command = "RUBYLIB='../DSTROOT/System/Library/BridgeSupport/ruby-#{version}' ruby ../gen_bridge_metadata.rb --format complete"
  output_path = "/tmp/bs_test.bridgesupport"
  full_command = "#{command} -c '-I. -I./header #{option[:cflags]}' ./header/#{header_file_name} -o #{output_path}"
  system full_command
  raise "Could not create BridgeSupport file\nCommand: #{full_command}" unless File.exists? output_path
  XmlSimple.xml_in(open(output_path))
end

def xcode_developer_path
  @xcode_developer_path ||= `xcode-select -p`.strip
  @xcode_developer_path
end
