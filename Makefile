# Familiar build script for the tooling of the project

.PHONY: help book repl sync check update-submodules

help:
	@echo TODO

book:
	cd book && quarto preview

local/env.py:
	cd local && ./setup.py

repl: local/env.py
	cd local && ipython3 -i __main__.py

sync: local/env.py
	cd local && ./cli.py --sync

check:
	rsync -V | head -1
	ssh -V
	python3 -V
	$(MAKE) local/env.py

pull:
	git submodule update --init --recursive

