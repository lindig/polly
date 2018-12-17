#
# This Makefile is not called from Opam but only used for
# convenience during development
#

DUNE 		= dune
SRC   	= find . -not \( -path ./_build -prune \) -type f -name '*.ml*'
PROFILE = dev

.PHONY: all install test clean format lint release

all:
	$(DUNE) build --profile=$(PROFILE)

install:
	$(DUNE) install --profile=$(PROFILE)

clean:
	$(DUNE) clean

format:
	$(SRC) | xargs ocamlformat -i
	indent -linux lib/epoll_stubs.c

lint:
	opam lint polly.opam
	opam lint --normalise polly.opam > polly.tmp && mv polly.tmp polly.opam

release:
	dune-release tag
	dune-release distrib
	dune-release opam pkg

