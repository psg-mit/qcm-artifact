# Quantum Control Machine

This directory contains the source code for the quantum control machine simulator in OCaml. The source code is organized as follows.

The main sources of the simulator are in `src/`:

- `dune` specifies OCaml build dependencies and flags.
- `parser.mly` and `lexer.mll` are a Menhir lexer/parser for the syntax of the assembly language.
- `main.ml` is the entry point of the assembly interpreter.

The `lib/` subdirectory includes the modules of the simulator:

- `ast/` defines the language abstract syntax tree and utility functions.
- `interp/` implements the assembly interpreter.
- `symbol/` implements the symbol table.
- `args.ml` defines command-line flags.

Other files are OCaml interface files and dependent modules of the above components of the simulator.
