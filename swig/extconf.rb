require 'rbconfig'
require 'mkmf'

CLANGHOME = ENV['CLANGHOME']
LLVMCONFIG = ["#{CLANGHOME}/usr/local/bin/llvm-config", '/usr/local/bin/llvm-config'].find(lambda{'llvm-config'}) {|f| File.exists?(f)}
$ARCH_FLAG = ARCHFLAGS = (ENV['ARCHFLAGS'].nil? || ENV['ARCHFLAGS'].length == 0) ? '-arch x86_64' : ENV['ARCHFLAGS']
DEBUGFLAGS = '-g'
OPTIMIZEFLAGS = ENV['RC_XBS'] == 'YES' ? '-Os' : ''

extension = 'bridgesupportparser'

[
    'clangCodeGen',
    'clangAnalysis',
    'clangARCMigrate',
    'clangRewriteFrontend',
    'clangSema',
    'clangSerialization',
    'clangFrontend',
    'clangEdit',
    'clangDriver',
    'clangAST',
    'clangParse',
    'clangLex',
    'clangBasic',
    'LLVMCore',
    'LLVMSupport',
    'LLVMBitWriter',
    'LLVMBitReader',
    'LLVMCodeGen',
    'LLVMAnalysis',
    'LLVMTarget',
    'LLVMMC',
    'LLVMMCParser',
    'LLVMOption',
].reverse.each {|l| $libs = append_library($libs, l)}

with_cppflags("#{DEBUGFLAGS} #{OPTIMIZEFLAGS} #{ARCHFLAGS} -mmacosx-version-min=10.9 -Wno-reserved-user-defined-literal -I#{CLANGHOME}/usr/local/include #{`#{LLVMCONFIG} --cxxflags`}") {true}
with_cflags("#{DEBUGFLAGS} #{OPTIMIZEFLAGS} #{ARCHFLAGS} -mmacosx-version-min=10.9 -fno-rtti #{`#{LLVMCONFIG} --cflags`}") {true}
with_ldflags("#{DEBUGFLAGS} #{OPTIMIZEFLAGS} #{ARCHFLAGS} -mmacosx-version-min=10.9 #{`#{LLVMCONFIG} --ldflags`.gsub(/ *-[DO][^ ]*/, '')}") {true}

$srcs = ["#{extension}.cpp", "#{extension}_wrap.cpp"]
$objs = ["#{extension}.o", "#{extension}_wrap.o"]
$cleanfiles << "#{extension}_wrap.cpp"

create_makefile(extension)

# HACK This next part is a fix because Apple neglected to correctly set the
# Ruby header dir in the RbConfig for at least MacOS 10.14
macos_version = `/usr/bin/sw_vers -productVersion`.split(".").map(&:to_i)
ruby_framework_prefix = RbConfig::CONFIG['prefix']
is_system_ruby = ruby_framework_prefix.start_with? "/System"
if is_system_ruby && macos_version[0] > 9 &&
    (macos_version[0] == 10 && macos_version[1] >= 14) ||
    macos_version[0] > 10
  sdk_prefix = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX#{macos_version.join(".")}.sdk"
  ruby_sdk_include = sdk_prefix + ruby_framework_prefix + "/include"
  ruby_header_dir = "#{ruby_sdk_include}/#{RbConfig::CONFIG["RUBY_VERSION_NAME"]}"
  if File.exists? ruby_header_dir + "/ruby.h"
    STDERR.puts "INFO extconf.rb: Using #{ruby_header_dir} for Ruby headers."
    # HACK I tried configuring this through RbConfig, but failed, mkmf is a mess
    makefile = File.read("Makefile")
    File.write("Makefile", makefile.gsub(/topdir = .*$/, "topdir = #{ruby_header_dir}"))
  else
    STDERR.puts "WARNING extconf.rb: On MacOS > 9 but found no Ruby.framework in #{sdk_prefix}"
  end
end

open("Makefile", "a") do |mf|
    mf.puts <<EOF

BSP_HEADERS = classes.h #{extension}.h __xattr__.h
$(OBJS): $(BSP_HEADERS)

# #{extension}_wrap.cpp: $(BSP_HEADERS)
# #{extension}_wrap.cpp: #{extension}.i
#	swig -c++ -ruby -o $@ $<

#{extension}_wrap.o: #{extension}_wrap.cpp
	$(CXX) $(INCFLAGS) -DSWIG $(CPPFLAGS) $(CXXFLAGS) -c $<

EOF
end
