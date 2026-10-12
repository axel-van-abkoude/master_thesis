#!/usr/bin/env -S python3
import argparse
from cluster import *
from batches import *

def cli():
	# Parse Arguments
	p = argparse.ArgumentParser()
	g = p.add_mutually_exclusive_group()
	g.add_argument("-q", "--queue", action="store_true")
	g.add_argument("-s", "--sync", action="store_true")
	g.add_argument("-m", "--make", action="store_true")
	g.add_argument("-b", "--batch", type=str)
	args = p.parse_args()

	# Actions
	## Look at slurm queue
	if args.queue:
		queue()
		acct()

	## Sync with remote
	elif args.sync:
		sync()

	## Build the compiler
	elif args.make:
		compute_node(
			body=BATCH_BUILD_SAC2C,
		)

	## Run a batch script
	elif not args.batch == None:
		compute_node(body=args.batch)
	else:
		p.print_help()

if __name__ == "__main__":
	cli()
