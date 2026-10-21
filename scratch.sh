#!/bin/bash
#SBATCH --time=0-01:00:00
#SBATCH --gres=gpu:1
#SBATCH --mem=8G

if [ -z $SLURM_JOB_ID ]
then target=seq; dir=tmp/local_$(date +%s)
else target=cuda; dir=tmp/${SLURM_JOB_NAME}_$(date +%s)
#target=seq
#target=cuda_alloc
#target=cuda_core
#target=cuda_man
#target=cuda_manp
#target=cuda_reg
#target=cudahybrid
if ! nvidia-smi -L; then exit 1; fi
fi
if ! make -f Makefile.local build -j8; then exit 2; fi
mkdir -p $dir
bin=$dir/$target

echo "Compiling ... ($bin)"
if ! ./build/sac2c_p \
-profile fc \
-t $target \
-o $bin \
<< 'EOF_SAC'
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
  HIDE(inc(DATA([ 1000000])))
  HIDE(inc(DATA([ 2000000])))
  HIDE(inc(DATA([ 3000000])))
  HIDE(inc(DATA([ 4000000])))
  HIDE(inc(DATA([ 5000000])))
  HIDE(inc(DATA([ 6000000])))
  HIDE(inc(DATA([ 7000000])))
  HIDE(inc(DATA([ 8000000])))
  HIDE(inc(DATA([ 9000000])))
  HIDE(inc(DATA([10000000])))
//HIDE(matmul(DATA([1000000,1000000]),DATA([1000000,1000000])))
//HIDE(matmul(DATA([2000000,2000000]),DATA([2000000,2000000])))
  EXIT
}
EOF_SAC
then exit 3; fi

echo "Running ... ($bin)"
$bin | tee -a $bin.log
exit 0
