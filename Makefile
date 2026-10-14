# Familiar build script for the tooling of the project

.PHONY: help book repl sync check update-submodules

help:
	@echo TODO

book:
	cd book && quarto preview

repl:
	cd local && ipython3 -i lib.py

check:
	rsync -V | head -1
	ssh -V
	python3 -V

pull:
	git submodule update --init --recursive

