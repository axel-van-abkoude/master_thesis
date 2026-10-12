import subprocess
from helpers import yn
from batches import *
from env import *

def queue(): head_node(f'squeue --format="%.8i %.8j %.8u %.8T %.8L %.8M %.16S %.8v %R" --partition {REMOTE_PARTITION}')
def cancel(): head_node(f'scancel --me --partition {REMOTE_PARTITION}')
def acct(): head_node('sacct --format=jobid,state,elapsed,exitcode,alloccpu,alloctres,workdir')
def info(): compute_node(BATCH_INFO)
def out(): head_node(f'cat out')
def err(): head_node(f'cat err')

def compute_node(body='/bin/hostname'):
	'''
	Run a script as a slurm sbatch with parameters
	'''
	# The batch template
	batch = f'''#!/bin/sh
#SBATCH --output=out
#SBATCH --error=err
#SBATCH --partition={REMOTE_PARTITION}
#SBATCH --parsable
{body}
'''

	# Ask if we want to run
	print(f'[RUN on {REMOTE_ADDRESS}]\n{batch}')
	if not yn(): return

	# Run batch
	sync()
	head_node(body='sbatch', stdin=batch)
	queue()

def head_node(
		body='sacct',
		stdin='',
	):
	'''
	Executes commands on the head node
	'''
	subprocess.run(
		['ssh', REMOTE_ADDRESS, f'cd {REMOTE_ROOT}/remote && {body}'],
		input=stdin,
		text=True,
		check=True,
	)

def sync():
	'''
	Syncs a local directory with a directory on the host
	'''

	src = f'{LOCAL_ROOT}/'
	dst = f'{REMOTE_ADDRESS}:{REMOTE_ROOT}/'

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
