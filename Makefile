# For reliability everything assumes bash as shell. 
# Provide own path to bash if not located at /bin/bash
SHELL ?=/bin/bash
.ONESHELL:
.PHONY: status login cancel listen check *.sh sync
include .env
export
REMOTE_ADDR :=$(REMOTE_USER)@$(REMOTE_HOST)

status:
	@ssh "$(REMOTE_ADDR)" "bash -s" << 'END_REMOTE'
	@squeue --partition=$(SLURM_PARTITION) --format="%.10j %.10T %.10M %.10u %.16S %.8v %R"
	@sacct --allocations --format=jobname,state,elapsed,exitcode,alloctres%50
	@END_REMOTE

login:
	@$(MAKE) status
	@ssh -t "$(REMOTE_ADDR)" "cd $(REMOTE_ROOT) && bash -l"

cancel:
	@ssh "$(REMOTE_ADDR)" "scancel --me"

listen:
	@ssh "$(REMOTE_ADDR)" "tail --lines 50 --follow $(REMOTE_ROOT)/log"

check:
	@rsync -V | head -1
	@ssh -V
	@cat .env
	@$(MAKE) status

*.sh:
	$(MAKE) sync
	@ssh "$(REMOTE_ADDR)" "bash -s" << 'END_REMOTE'
	@cd $(REMOTE_ROOT)
	sbatch \
	--partition $(SLURM_PARTITION) \
	--job-name=$* \
	--output=log \
	--parsable \
	$@
	@END_REMOTE
	@ssh "$(REMOTE_ADDR)" "bash -s" << 'END_REMOTE'
	while squeue -h -n $* -t PENDING | grep -q .; do
	squeue --partition=$(SLURM_PARTITION) --format="%.10j %.10T %.10M %.10u %.16S %.8v %R"
	sleep 5
	done
	END_REMOTE
	@$(MAKE) listen

sync:
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
