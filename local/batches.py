#!/usr/bin/env -S python3

BATCH_BUILD_SAC2C = '''
#SBATCH --job-name=build_sac
#SBATCH --time=0-00:30:00
#SBATCH --cpus-per-task=8

git submodule update --init --recursive
echo "Building sac2c"
cd sac2c
make -j8
'''

BATCH_INFO = '''
#SBATCH --job-name=info
#SBATCH --time=00:10:00

#SBATCH --gres=gpu:1
#SBATCH --cpus-per-gpu=1
#SBATCH --mem-per-gpu=8G

echo "[ HOSTNAME ]"
hostname

echo "[ LS ]"
ls -la

module load cuda/12.4
echo "Allocated GPU(s): $SLURM_JOB_GPUS"
echo "[ NVIDIA-SMI ]"
nvidia-smi
'''

def batches(verbose=False):
	for name, value in globals().items():
		if name.startswith('BATCH_'):
				print(f"[ {name} ]")
				if verbose: print(value, '\n')

if __name__ == "__main__":
	batches(True)
