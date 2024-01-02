# OOPSLA 2024 Artifact: Quantum Control Machine

This artifact is being submitted to support the OOPSLA'24 paper "Quantum Control Machine: The Limits of Control Flow in Quantum Programming" by Charles Yuan, Agnes Villanyi, and Michael Carbin. The artifact contains:

- `README.md`, this document
- `artifact.tgz`, a Docker image containing source code, pre-built binaries, and tests
- A `Dockerfile` that generates the above image from scratch
- The directory `qcm-artifact`, a copy of the contents of the Docker image, containing the source code of the simulator (`src/`) and the tests (`test/`)

The contents of this artifact are also available on [GitHub](https://github.com/psg-mit/qcm-artifact).

## Kick-the-Tires: Getting Started with the Artifact

First, import `artifact.tgz` into Docker. In our testing, we used Docker Engine 24.0.6 on macOS Sonoma. The image may be loaded using the following commands:

```shell
$ docker load < artifact.tgz
Loaded image: qcm-artifact:latest
$ docker run -it --rm qcm-artifact bash
opam@502e0da78017:~/qcm-artifact$
```

The artifact is in the `qcm-artifact/` directory inside the user home directory. To quickly check that the artifact is functional, execute the following command and check that the output displays `state is synchronized`:

```shell
$ cd ~/qcm-artifact/
$ ./qcm -r "x=3,y=0" -t 5 test/addition.qcm
(1.000000 + 0.000000i) |pc:7,br:1,x:3,y:3>
state is synchronized
```

## Functionality: Validating the Paper's Claims

This artifact supports the following claim from Section 6 of the paper:

> We have implemented a simulator for the quantum control machine, which accepts a program, input, and runtime _t_, and outputs the machine state after _t_ steps. Implementations of all case study examples as executable programs are also packaged with the simulator.

The easiest way to validate the claim is to do the following in the `qcm-artifact/` directory. First, ensure the simulator `./qcm` is present. If it is not, rebuild it from source by invoking `make` (for more instructions, see "Detailed Build Instructions" below).

Second, execute the simulator on all provided test programs by invoking `make check`. This operation should take about one second to complete.

Finally, check that the output of `make check` is identical to the contents of the file `expected_output`. Specifically, the message `state is synchronized` should appear for all programs except `test/exponentiation-nosync.qcm`, which should output `state is not synchronized`.

Each example program for the quantum control machine presented in the paper corresponds to a program in the `test/` directory:

- Figure 2 in the paper corresponds to `test/addition.qcm`.
- Figure 6 in the paper corresponds to `test/exponentiation-nosync.qcm`.
- Figure 7 in the paper corresponds to `test/exponentiation.qcm`.
- Figure 8 in the paper corresponds to `test/hadamard.qcm`.
- Figure 10 in the paper corresponds to `test/majorana.qcm`.

As a technical note, the paper presents each program using named labels (e.g. `l1:`). By contrast, the formal language specification in Table 1 of the paper, as well as this artifact, use explicit line offsets (e.g. `$+3`) rather than labels.
For each program, we have provided the version with named labels as seen in the paper in a file suffixed `-labels`, e.g. `test/addition-labels.qcm`. We have also provided a simple script `label2offset.py` that can be used to convert named labels to explicit line offsets. One may convert `test/addition-labels.qcm` to `test/addition.qcm` by running:

```shell
./label2offset.py < test/addition-labels.qcm > test/addition.qcm
```

## Reusability: Writing Programs

The simulator included in the artifact makes it possible to write new programs and extend the functionality of the simulator.
The file `src/README.md` describes the organization of the simulator sources, should you wish to modify the code.

To execute a program, supply it as an argument to the simulator, for example:

```shell
$ ./qcm -r "x=3,y=0" -t 5 test/addition.qcm
(1.000000 + 0.000000i) |pc:7,br:1,x:3,y:3>
state is synchronized
$ ./qcm -r "res=0,r1=0,x=2,y=1" -r "res=0,r1=0,x=2,y=2" -t 10 test/exponentiation-nosync.qcm
(0.707107 + 0.000000i) |pc:5,br:1,res:4,r1:1,y:2,x:2> + (0.707107 + 0.000000i) |pc:8,br:1,res:2,r1:0,y:1,x:2>
state is not synchronized
```

The `-t` flag specifies the number of steps to execute.
The `-r` flag specifies the initial register state, a comma-separated list of variable names and values separated by `=`. Specifying multiple instances of `-r` initializes the register state to the uniform superposition of the specified states.

The output of the simulator is the final state of the machine, which is a complex vector of amplitudes and register states. The simulator also outputs whether the state is synchronized or not, i.e. whether the values of `pc` and `br` are equal across all states in the final superposition.

To see examples of programs and invocations, see the `test/` directory and the `Makefile`.
To see the full list of options, run:

```bash
./qcm --help
```

## Detailed Build Instructions

In the provided image, simply run `make` within `qcm-artifact` to build the simulator from source.

To build the simulator outside of the image, first install OCaml version 5.0.0 with `dune` and the libraries `core`, `menhir`, and `ppx_deriving`.
The recommended way to install OCaml and the dependent libraries is via [OPAM](http://opam.ocaml.org).
Then, to build the simulator `./qcm`, simply run `make`.
