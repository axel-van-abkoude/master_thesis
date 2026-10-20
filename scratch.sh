#!/bin/bash
# Gen Directory
name="scratch"
mkdir -p tmp
dir=$(mktemp -d "tmp/${name}_XXXXXXXXX")
exit_code=$?
if [ $exit_code -ne 0 ]; then echo "Failed to generate directory (code: $exit_code)"; exit 1; fi
echo "$dir"

# Compile Experiment
./build/sac2c_p -profile a -o "$dir/$name" << 'EOF_SAC'
#define INIT _r = 0;
#define HIDE(_a) _r = _add_SxS_(_r,_toi_S_(_sel_VxA_(_mul_SxV_(0,_shape_A_((_a))),_hideValue_SxA_(_r,(_a)))));
#define EXIT return _r;
#define DATA(...) (with {} : genarray(__VA_ARGS__,0d))

use sacprelude_p: {sel};
inline double +(double l, double r) { return _add_SxS_(l,r); }
inline double *(double l, double r) { return _mul_SxS_(l,r); }
inline double sum(double[1:shp] arr)
{ return with {([0] <= iv < shp) : arr[iv];} : fold(+, 0d); }

noinline double[m,p] matmul(double[m,n] a, double[n,p] b)
{ return {[i,j] -> sum({[k] -> a[i,k] * b[k,j]})}; }

noinline double[*] inc(double[*] a)
{ return { iv -> a[iv] + 1d }; }

int main() {
  INIT
//HIDE(inc(DATA([1000000])))
//HIDE(inc(DATA([2000000])))
  HIDE(matmul(DATA([1000,1000]),DATA([1000,1000])))
  EXIT
}
EOF_SAC
exit_code=$?
if [ $exit_code -ne 0 ]; then echo "Compilation Failed (code: $exit_code)"; exit 1; fi
echo "Compilation Succes."

# Run Experiment
$dir/$name &> $dir/log
exit_code=$?
cat $dir/log
if [ $exit_code -ne 0 ]; then exit 1; fi
exit 0
