#!/usr/bin/env -S python3
from pathlib import Path
from helpers import yn
import subprocess
import os

def gen_env(env_file: Path):
	if not env_file.exists():
		print(f'The env file ({env_file}) does not exist, want to create this file?')
		if not yn(): return
		env_file.touch()
	else:
		print(f'Replace following env? ({env_file})')
		print(env_file.read_text())
		if not yn(): return
	
	print("No 's needed around inputs")
	remote_user = input('REMOTE_USER = ')
	remote_server = input('REMOTE_SERVER = ')
	remote_partition = input('REMOTE_PARTITION = ')

	local_root = os.path.normpath(os.path.dirname(os.path.abspath(__file__))+'/..')
	remote_root = '~'

	env_content = f'''
REMOTE_USER = '{remote_user}'
REMOTE_SERVER = '{remote_server}'
REMOTE_ADDRESS = '{remote_user}@{remote_server}'
REMOTE_PARTITION = '{remote_partition}'

LOCAL_ROOT = '{local_root}'
REMOTE_ROOT = '{remote_sync_root}'
'''
	env_file.write_text(env_content)
	print(f'Resulting env: ({env_file})')
	print(env_file.read_text())

if __name__ == "__main__":
	gen_env(Path('env.py'))
	import env
	subprocess.run(['ssh-copy-id', env.REMOTE_ADDRESS])
