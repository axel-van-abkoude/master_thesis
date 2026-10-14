#!/usr/bin/env -S python3
if __name__ != "__main__":
	exit()

# Parser
import argparse
p = argparse.ArgumentParser(prog='cli')
g = p.add_mutually_exclusive_group()

g.add_argument("-m", "--make", choices=["sac2c","stdlib",".env"])
g.add_argument("-s", "--status", action="store_true")
g.add_argument("-rc", "--run-comp-node", type=str)
g.add_argument("-rh", "--run-head-node", type=str)
args = p.parse_args()

from cluster import *
import make

# Status
if args.status:
	queue()
	acct()

# Make
elif args.make == "sac2c": make.sac2c()
elif args.make == "stdlib": make.stdlib()
elif args.make == ".env": make.env()


# Running on different nodes
# comp -> compute node managed by slurm
# head -> head node used for logging in and editing
elif not args.run_comp_node == None: comp_node(body=args.run_comp_node)
elif not args.run_head_node == None: head_node(body=args.run_head_node)

else: p.print_help()

