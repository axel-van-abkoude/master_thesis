#!/bin/bash
#SBATCH --time=0-01:00:00
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
mkdir -p src
cat > src/Main.sac << 'EOF_MAIN'
use Lib:all;
use Inc:all;
use Matmul:all;
use ControlFlow:all;
use sacprelude_p: {sel};
#define ZEROS(...) (with {} : genarray(__VA_ARGS__,0d))

int main() {
  for(i = 0; i < 10000; i = i + 1) {
    //_ = inc_nocuda(ZEROS([1000000]));
    //_ = inc_cuda(ZEROS([1000000]));
    _ = matmul_nocuda(ZEROS([10000,10000]),ZEROS([10000,10000]));
    _ = matmul_cuda(ZEROS([10000,10000]),ZEROS([10000,10000]));
  }
  return 0;
}
EOF_MAIN

cat > src/control_flow.c << 'EOF_TOUCH'
void *createControlFlow(void) { return (void*)0; }
void touch(void *obj) { }
EOF_TOUCH

cat > src/ControlFlow.sac << 'EOF_CLASS'
#pragma safe
class ControlFlow;
external classtype;
export all;
objdef ControlFlow TheControlFlow = createControlFlow();
external ControlFlow createControlFlow();
    #pragma linkobj "control_flow.o"
    #pragma linksign [1]

external void touch(ControlFlow& obj);
    #pragma linkobj "control_flow.o"

inline void touch() { touch(TheControlFlow); }
EOF_CLASS

cat > src/Inc.sac << 'EOF_INC'
module Inc;
use sacprelude_p: {sel};
use Lib:all;
use ControlFlow: {touch};
export all;

noinline double[*] inc_cuda(double[*] a) {
  touch();
  return with {
    (. <= iv <= .) : a[iv] + 1d;
  } : modarray(a);
}

noinline double[*] inc_nocuda(double[*] a) {
  touch();
  return with {
    #pragma nocuda
    (. <= iv < .) : a[iv] + 1d;
  } : modarray(a);
}
EOF_INC

cat > src/Matmul.sac << 'EOF_MATMUL'
module Matmul;
use sacprelude_p: {sel};
use Lib:all;
use ControlFlow: {touch};
export all;

noinline double[m,p] matmul_cuda(double[m,n] a, double[n,p] b) {
  touch();
  return with {
    (. <= [i,j] <= .) : sum({[k] -> a[i,k] * b[k,j]});
  } : genarray([m,p],0d);
}

noinline double[m,p] matmul_nocuda(double[m,n] a, double[n,p] b) {
  touch();
  return with {
    #pragma nocuda
    (. <= [i,j] <= .) : sum({[k] -> a[i,k] * b[k,j]});
  } : genarray([m,p],0d);
}
EOF_MATMUL

cat > src/Lib.sac << 'EOF_LIB'
module Lib;
use sacprelude_p: {sel};
export all;
inline double +(double l, double r) { return _add_SxS_(l,r); }
inline double *(double l, double r) { return _mul_SxS_(l,r); }
inline int +(int l, int r) { return _add_SxS_(l,r); }
inline bool <(int l, int r) { return _lt_SxS_(l,r); }
inline double sum(double[1:shp] arr) { return with {([0] <= iv < shp) : arr[iv];} : fold(+, 0d); }
EOF_LIB

if [ ! -z $SLURM_JOB_ID ]
then echo "Running under SLURM"
  if ! nvidia-smi -L; then exit 1; fi
  target=cuda
else echo "Running locally"
  target=seq
fi

echo "Building sac2c to bin"
if ! make -f Makefile.local bin -j8; then exit 2; fi

echo "Compiling src to build"
mkdir -p build
gcc -c -o build/control_flow.o src/control_flow.c
./bin/sac2c_p -t $target -o build src/ControlFlow.sac
./bin/sac2c_p -t $target -o build src/Lib.sac
./bin/sac2c_p -t $target -o build src/Inc.sac
./bin/sac2c_p -t $target -o build src/Matmul.sac
cp src/Main.sac build/Main.sac
cd build
../bin/sac2c_p \
-t $target \
-o $target \
-profile fc \
Main.sac

echo "Running ... ($target)"
./$target
#if [ ! -z $SLURM_JOB_ID ]
#then ./$target | tee -a $target.log
#else gdb -ex "b SACf__MAIN__main" -ex "r" ./$target
#fi

exit 0

