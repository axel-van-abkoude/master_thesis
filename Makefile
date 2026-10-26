SHELL ?= /bin/bash
THIS_FILE := $(realpath $(firstword $(MAKEFILE_LIST)))
.PHONY: options check status login cancel listen *.sh sync
.ONESHELL:
include .env
export
REMOTE_ADDR := $(REMOTE_USER)@$(REMOTE_HOST)
LOCAL_ROOT := $(dir $(THIS_FILE))

options:
	@echo "Options for: $(THIS_FILE)"
	@grep -E '^[A-Z_]+[[:space:]]*\?=.*##|^[a-zA-Z0-9_-]+:.*##' $(THIS_FILE)

check: ## Check dependencies
	@rsync -V | head -1 || echo "rsync not installed"
	@ssh -V || echo "ssh not installed"
	@cat .env || echo ".env not created, read README.md"
	@$(MAKE) -f Makefile status

status: ## Queue and Accounting on Remote
	@ssh "$(REMOTE_ADDR)" "bash -s" << 'END_REMOTE'
	@squeue --partition=$(SLURM_PARTITION) --format="%.10j %.10T %.10M %.10u %.16S %.8v %R"
	@sacct --allocations --format=jobname,state,elapsed,exitcode,alloctres%50
	@END_REMOTE

login: ## Login on remote via SSH
	@$(MAKE) status
	@ssh -t "$(REMOTE_ADDR)" "cd $(REMOTE_ROOT) && bash -l"

cancel: ## Cancel all jobs
	@ssh "$(REMOTE_ADDR)" "scancel --me"

listen: ## Listen on the remote log file
	@ssh "$(REMOTE_ADDR)" "tail --lines 50 --follow $(REMOTE_ROOT)/log"

*.sh:
	$(MAKE) sync
	@ssh "$(REMOTE_ADDR)" "bash -s" << 'END_REMOTE'
	@cd $(REMOTE_ROOT)
	@sbatch \
	--partition $(SLURM_PARTITION) \
	--job-name=$* \
	--output=log \
	--parsable \
	$@
	@END_REMOTE
	@ssh "$(REMOTE_ADDR)" "bash -s" << 'END_REMOTE'
	@while squeue -h -n $* -t PENDING | grep -q .; do
	@squeue --partition=$(SLURM_PARTITION) --format="%.10j %.10T %.10M %.10u %.16S %.8v %R"
	@sleep 5
	@done
	@END_REMOTE
	@$(MAKE) listen

sync: ## Send local non git ignored files and get remote log and build files
	@local=$(LOCAL_ROOT)/
	@remote=$(REMOTE_ADDR):$(REMOTE_ROOT)
	@echo "Sending local files to remote ..."
	@echo "> ($${local} -> $${remote})"
	@rsync -avz \
		--delete \
		--exclude-from=.gitignore \
		"$${local}" \
		"$${remote}"
	@echo "----"
	@echo "Retreiving remote log file ..."
	@echo "> ($${remote}/log -> $${local})"
	@rsync -avz \
		"$${remote}/log" \
		"$${local}" \
		|| echo "No log file found on $${remote}"
