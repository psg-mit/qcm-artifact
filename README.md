# Quantum Control Machine

This repository contains the simulator for the quantum control machine.

## Building

This project requires OCaml 5.0.0 and Dune, along with the OPAM packages `core`, `menhir`, and `ppx_deriving`, which can be installed with:

```bash
opam install core menhir ppx_deriving
```

Afterward, you can build the project by running:

```bash
make
```

## Running

You can test the project by running:

```bash
make check
```

To see examples of programs and invocations, see the `test/` directory and the `Makefile`.
To see the full list of options, run:

```bash
./qcm --help
```

## Limitations

- The simulator currently only supports the following gates: `H`, `X`, `Y`, and `Z`.
- It does not currently support named labels (`l1:`), but does support explicit line offsets (`$+3`).
