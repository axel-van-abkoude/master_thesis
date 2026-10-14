from dotenv import set_key, get_key, dotenv_values, find_dotenv
from os.path import normpath, dirname, abspath
from util import yn
import cluster
import subprocess

def env():
	env_path = find_dotenv()
	set_key(env_path,"LOCAL_ROOT", dirname(env_path))
	keys = [
		"REMOTE_USER",
		"REMOTE_SERVER",
		"REMOTE_PARTITION",
		"REMOTE_ROOT",
	]
	for key in keys:
		print(f'Edit {key} = {get_key(env_path,key)} ? ', end='')
		if yn(): set_key(env_path,key,input(key+" = "))

	env = dotenv_values()
	set_key(
		env_path,
		"REMOTE_ADDRESS",
		f"{env["REMOTE_USER"]}@{env["REMOTE_SERVER"]}"
	)
	cluster.is_up()
	subprocess.run(['ssh-copy-id', env["REMOTE_ADDRESS"]])

def stdlib():
	cluster.comp_node('''
#SBATCH --job-name=build_lib
#SBATCH --time=0-01:00:00
#SBATCH --cpus-per-task=8

git submodule update --init --recursive
echo "Building stdlib"
cd stdlib

mkdir build
cd build
cmake \
  -DTARGETS=cuda \
  -DSAC2C_EXEC=../../bin/sac2c \
  ..
make -j8
''')

def sac2c():
	cluster.comp_node('''
#SBATCH --job-name=build_sac
#SBATCH --time=0-00:30:00
#SBATCH --cpus-per-task=8

git submodule update --init --recursive
echo "Building sac2c"
cd sac2c
make -j8
''')
