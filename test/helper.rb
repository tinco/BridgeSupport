require "xmlsimple"

def gen_bridge_metadata(header_file_name, option = {})
  version = RUBY_VERSION.sub(/^(\d+\.\d+)(\..*)?$$/, "\\1")
  command = "RUBYLIB='../DSTROOT/System/Library/BridgeSupport/ruby-#{version}' ruby ../gen_bridge_metadata.rb --format complete"
  output_path = "/tmp/bs_test.bridgesupport"
  system "#{command} -c '-I. -I./header #{option[:cflags]}' ./header/#{header_file_name} -o #{output_path}"
  hash = XmlSimple.xml_in(open(output_path))
end