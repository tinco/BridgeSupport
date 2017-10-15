#!/bin/bash

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

rbenv shell 2.0.0-p648
rm -rf DSTROOT
rm -rf OBJROOT/swig
make

rbenv shell 2.3.3
rm -rf OBJROOT/swig
make
