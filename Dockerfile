# Build with `docker build -t qcm-artifact .`
# Run with `docker run -it --rm qcm-artifact bash`

FROM ocaml/opam:debian-11-ocaml-5.0

USER root
RUN apt-get install -y python3

USER opam
RUN opam update -q \
    && opam install -y dune core menhir ppx_deriving \
    && echo 'eval $(opam env)' >> /home/opam/.bashrc

WORKDIR /home/opam/
RUN curl -L -O https://github.com/psg-mit/qcm-artifact/archive/refs/heads/master.zip \
    && unzip master.zip \
    && mv qcm-artifact-master qcm-artifact

WORKDIR /home/opam/qcm-artifact/
RUN eval $(opam env) && make
