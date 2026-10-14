from cluster import comp_node, head_node
from dotenv import dotenv_values

TARGETS = [
	"seq",
	"seq_checks",
	"mt_pth",
	"cuda",
	"cuda_alloc",
	"cuda_core",
	"cuda_man",
	"cuda_manp",
	"cuda_reg",
]

BREAK_OPTIONS = [
	"cg:cpl",
]

SIZES = [
	2**17,
	2**18,
	2**19,
	2**20,
]

ITERATIONS = 1_000_000

def inc_all(bopts=BREAK_OPTIONS, sizes=SIZES[:1], iterations=ITERATIONS, targets=TARGETS):
	for bopt in bopts:
		for size in sizes:
			for target in targets:
				
				output = inc(bopt=bopt, size=size, iterations=iterations, target=target)

def inc(bopt=None, size=SIZES[0], iterations=ITERATIONS, target='cuda'):

	if not target in TARGETS: 
		print(target, "not a valid target.")
		print(TARGETS)
		return

	name = f'inc_{size}_{iterations}_{target}'

	par = f'''
#define I {iterations}
#define N {size}
'''

	src = " << 'END'" + par + '''
double[shp] inc(double[shp] a) {
  return { iv -> _add_SxS_(_sel_VxA_(iv,a),1d) };
}

int main() {
  x = with {} : genarray([N],0d);
  for(i = 0; _lt_SxS_(i,I); i = _add_SxS_(i,1)) {
    x =_hideValue_SxA_(i,inc(x));
  }
  return _toi_S_(_sel_VxA_([0],x));
}
END
'''

	# cg:cpl
	if not bopt == None:
		ret = head_node(f'./bin/sac2c -noprelude -t {target} -b {bopt} {src}')
		with open(dotenv_values()['LOCAL_ROOT']+'/tmp/'+name+"_"+bopt, 'w') as f:
			f.write(ret.stdout)
		return

	comp_node(f'''
#SBATCH --job-name={name}
#SBATCH --time=01:00:00

#SBATCH --gres=gpu:1
#SBATCH --cpus-per-gpu=1
#SBATCH --mem-per-gpu=8G

module load cuda/12.4
nvidia-smi

mkdir -p build && cd build
../bin/sac2c -t {target} -o {name} {src}
./{name}
''')
	return
