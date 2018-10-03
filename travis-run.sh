#!/usr/bin/env sh

make rebuild && \
  sudo make install DESTDIR=/Library/RubyMotion/BridgeSupport3 && \
  cd test && rake
