# Runtime GPU Memory Model Adaptation
Looking into the tradeoffs of switching the CUDA memory model at runtime

## ENV
```
REMOTE_ROOT=/path/to/folder/on/the/remote
REMOTE_USER=remote_username
REMOTE_HOST=remote.hostname.org
SLURM_PARTITION=partition_name
```

## Building
See Makefile for options

Check requirements with: ``` make check```

Remote options: ``` make```

Local options: ``` make -f Makefile.local```

## Layout
book/ -> Information, Documentation, Analysis

sac2c/ -> Forked sac2c compiler

bin/ -> Sac2c compiler build

build/ -> build and output files for sac programs

log -> stdout/stderr of batch jobs
