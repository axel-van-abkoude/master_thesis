import subprocess
from dotenv import dotenv_values
from util import yn

def queue(part=dotenv_values()["REMOTE_PARTITION"]):
	head_node(f'squeue --format="%.8i %.8j %.8u %.8T %.8L %.8M %.16S %.8v %R" --partition {part}')
def cancel():
	head_node(f'scancel --me')
def acct():
	head_node('sacct --format=jobid,state,elapsed,exitcode,alloccpu,alloctres,workdir')
def info():
	comp_node('''
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
''')

def out(): head_node(f'cat out')
def err(): head_node(f'cat err')

def is_up(server=dotenv_values()["REMOTE_SERVER"]):
	try:
		subprocess.run(["ping", "-c1", server], check=True)
	except:
		print(f"No response when pinging {server}")
		exit()

def comp_node(body='/bin/hostname'):
	'''
	Run a script as a slurm sbatch with parameters
	'''

	e = dotenv_values()
	part = e["REMOTE_PARTITION"]
	addr = e["REMOTE_ADDRESS"]

	# The batch template
	batch = f'''#!/bin/sh
#SBATCH --output=out
#SBATCH --error=err
#SBATCH --partition={part}
#SBATCH --parsable
{body}
'''

	# Ask if we want to run
	print(f'[RUN on {addr}]\n{batch}')
	if not yn(): return

	# Run batch
	sync()
	_ = head_node(body='sbatch', stdin=batch)
	queue()

def head_node(
		body='sacct',
		stdin='',
	):
	'''
	Executes commands on the head node
	'''
	is_up()
	e = dotenv_values()

	ret = subprocess.run(
		['ssh', e["REMOTE_ADDRESS"], f'cd {e["REMOTE_ROOT"]}/remote && {body}'],
		input=stdin,
		capture_output=True,
	)
	print(ret.stdout.decode("utf-8"))
	return ret

def sync():
	'''
	Syncs a local directory with a directory on the host
	'''
	is_up()
	e = dotenv_values()

	src = e["LOCAL_ROOT"]+'/'
	dst = e["REMOTE_ADDRESS"]+':'+e["REMOTE_ROOT"]+'/'

	cmd = ['rsync', '-avz',
		'--exclude', 'book',
		'--exclude', 'local',
		'--exclude', 'remote/build',
		'--exclude', 'remote/sac2c/build_p',
		'--exclude', 'remote/sac2c/build_d',
		'--exclude', 'remote/sac2c/ext/SHRAYonUCX',
		src, dst
	]
	subprocess.run(cmd)
