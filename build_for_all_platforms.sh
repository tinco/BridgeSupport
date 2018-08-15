#!/bin/bash

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

rbenv shell 2.0.0-p648
make rebuild

rbenv shell 2.3.7
rm -rf OBJROOT/swig
make
