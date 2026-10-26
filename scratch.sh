#!/bin/bash
#SBATCH --time=0-01:00:00
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
if [ ! -z $SLURM_JOB_ID ]
then echo "Running under SLURM"
  if ! nvidia-smi -L; then exit 1; fi
  target=cuda
  e="000"
else echo "Running locally"
  target=seq_checks
  e="0"
fi

TARGET=$target make -f Makefile.local build
cd build

cat > Scratch.sac << EOF_MAIN
use ControlFlow: { TheControlFlow };
use Util:all;
use Matmul:all;
#define ZEROS(...) (with {} : genarray(__VA_ARGS__,0d))

int main() {
  for(i = 0; i < 10; i = i + 1) {
    _ = matmul_nocuda(ZEROS([1${e},1${e}]),ZEROS([1${e},1${e}]));
    _ = matmul_nocuda(ZEROS([10${e},1${e}]),ZEROS([1${e},1${e}]));
    _ = matmul_nocuda(ZEROS([100${e},1${e}]),ZEROS([1${e},1${e}]));
    _ = matmul_cuda(ZEROS([1${e},1${e}]),ZEROS([1${e},1${e}]));
    _ = matmul_cuda(ZEROS([10${e},1${e}]),ZEROS([1${e},1${e}]));
    _ = matmul_cuda(ZEROS([100${e},1${e}]),ZEROS([1${e},1${e}]));
  }
  return 0;
}
EOF_MAIN

../bin/sac2c_p -t $target -o Scratch_$target Scratch.sac \
  -profile fc

if [ $? -ne 0 ]; then exit 2; fi

if [ ! -z $SLURM_JOB_ID ]
then ./Scratch_$target
else unset DEBUGINFOD_URLS
gdb -n -q -ex "rb _matmul_" -ex "r" ./Scratch_$target
fi
