#!/bin/bash
make sac2c -j8
TARGET=cuda_mt make lib

cd build
../bin/sac2c_p -t $target -o $target -profile f << EOF_MAIN
use ControlFlow: all;
int main() {
  for(i = 0; i < 10; i = i + 1) {
    touch();
  }
  return 0;
}
EOF_MAIN
if [ $? -ne 0 ]; then exit 1; fi

./$target

