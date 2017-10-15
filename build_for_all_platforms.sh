#!/bin/bash

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

rm -rf OBJROOT/.BS_INCLUDE.made
rm -rf OBJROOT/.BS_RUBY.made
rm -rf OBJROOT/.DSTROOT.made
rm -rf DSTROOT

rbenv shell 2.0.0-p648
rm -rf OBJROOT/swig
make

rbenv shell 2.3.3
rm -rf OBJROOT/swig
make
