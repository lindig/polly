#
# This Makefile is not called from Opam but only used for
# convenience during development
#

DUNE 		= dune
SRC   	= find . -not \( -path ./_build -prune \) -type f -name '*.ml*'
PROFILE = dev

.PHONY: all install test clean

all:
	$(DUNE) build --profile=$(PROFILE)

install:
	$(DUNE) install --profile=$(PROFILE)

clean:
	$(DUNE) clean

format:
	$(SRC) | xargs ocamlformat -i

