require 'rbconfig'
require 'mkmf'

CLANGHOME = ENV['CLANGHOME'] || File.expand_path('../OBJROOT/clang-39/darwin-x86_64/ROOT/usr/local/')
LLVMCONFIG = ["#{CLANGHOME}/bin/llvm-config", '/usr/local/bin/llvm-config'].find(lambda{'llvm-config'}) {|f| File.exists?(f)}
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

with_cppflags("-mmacosx-version-min=10.9 -Wno-reserved-user-defined-literal -I#{CLANGHOME}/include #{`#{LLVMCONFIG} --cxxflags`}") {true}
with_cflags("#{DEBUGFLAGS} #{OPTIMIZEFLAGS} #{ARCHFLAGS} -mmacosx-version-min=10.9 -DDISABLE_SMART_POINTERS -fno-rtti #{`#{LLVMCONFIG} --cflags`}") {true}
with_ldflags("#{DEBUGFLAGS} #{OPTIMIZEFLAGS} #{ARCHFLAGS} -mmacosx-version-min=10.9 #{`#{LLVMCONFIG} --ldflags`.gsub(/ *-[DO][^ ]*/, '')}") {true}

$srcs = ["#{extension}.cpp", "#{extension}_wrap.cpp"]
$objs = ["#{extension}.o", "#{extension}_wrap.o"]
$cleanfiles << "#{extension}_wrap.cpp"

create_makefile(extension)

open("Makefile", "a") do |mf|
    mf.puts <<EOF

BSP_HEADERS = classes.h #{extension}.h __xattr__.h
$(OBJS): $(BSP_HEADERS)

#{extension}_wrap.cpp: $(BSP_HEADERS)
#{extension}_wrap.cpp: #{extension}.i
	swig -c++ -ruby -o $@ $<

#{extension}_wrap.o: #{extension}_wrap.cpp
	$(CXX) $(INCFLAGS) -DSWIG $(CPPFLAGS) $(CXXFLAGS) -c $<

EOF
end
