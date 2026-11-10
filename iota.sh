#!/bin/bash
#SBATCH --time=0-01:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
target=cuda_mt
make sac2c -j8
TARGET=$target make lib -j8
cd build
../bin/sac2c_p -b20 -t$target -noprelude << 'EOF'
use ControlFlow: all;
noinline int[1000000] iota_cuda() { touch();
  return with {
    (. <= [i] <= .) : i;
  } : genarray([1000000],0);
}
noinline int[1000000] iota_nocuda() { touch();
  return with {
    #pragma nocuda
    (. <= [i] <= .) : i;
  } : genarray([1000000],0);
}
int main() {
  _ = iota_cuda();
  _ = iota_nocuda();
  return 0;
}
EOF
