# For reliability everything assumes bash as shell
SHELL := /bin/bash

default: sync

.PHONY: check sync login clean
check:
	rsync -V | head -1
	ssh -V
	$(MAKE) login

sync:
	@source .env && \
		rsync -avz \
		--delete \
		--exclude-from=.gitignore \
		"$$LOCAL_ROOT/" \
		"$$REMOTE_USER@$$REMOTE_SERVER:$$REMOTE_ROOT"
	$(MAKE) login

login:
	@source .env && \
		ssh -t "$$REMOTE_USER@$$REMOTE_SERVER" \
		"cd $$REMOTE_ROOT; squeue -p $$SLURM_PARTITION; sacct; bash -l"

clean:
	rm -rf build
	rm -rf tmp

build:
	cd build && cmake -DCMAKE_BUILD_TYPE=RELEASE ../sac2c
	$(MAKE) -C build

