# Runtime GPU Memory Model Adaptation
Looking into the tradeoffs of switching the CUDA memory model at runtime

## Building
See Makefile for options
Quick and dirty: ``` make build -j8```
Check requirements with ``` make check```

## Layout
./book -> Information, Documentation, Analysis
./sac2c -> Forked sac2c compiler
./build -> compiler build
./tmp -> build, input and output files for sac programs

