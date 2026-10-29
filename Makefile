SHELL ?= /bin/bash
LOCAL_ROOT := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

options:
	@echo "Options: Makefile"
	@grep -E '^[A-Z_]+[[:space:]]*\?=.*##|^[a-zA-Z0-9_-]+:.*##' Makefile
	@echo ""
	@echo "Options: Makefile.local"
	@grep -E '^[A-Z_]+[[:space:]]*\?=.*##|^[a-zA-Z0-9_-]+:.*##' Makefile.local
	@echo ""
	@echo "Options: Makefile.remote"
	@grep -E '^[A-Z_]+[[:space:]]*\?=.*##|^[a-zA-Z0-9_-]+:.*##' Makefile.remote

check:
	@rsync -V | head -1 || echo "rsync not installed"
	@ssh -V || echo "ssh not installed"
	@cat .env || echo ".env not created, read README.md"

ifdef $(SLURM_JOB_ID) # Ran under SLURM
TARGET ?= cuda ## Default SLURM target
include Makefile.local

else # Ran locally
TARGET ?= seq ## Default Local target
include Makefile.local
include Makefile.remote
endif

