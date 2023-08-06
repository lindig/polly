#
# This Makefile is not called from Opam but only used for
# convenience during development
#

PROFILE = dev

.PHONY: all install test clean format lint release test utop

all:
	dune build --profile=$(PROFILE)

install:
	dune install --profile=$(PROFILE)

clean:
	dune clean

format:
	dune build @fmt --auto-promote
	indent -linux lib/polly_stubs.c

utop:
	dune utop

lint: 	format
	opam lint polly.opam
	opam lint --normalise polly.opam > polly.tmp && mv polly.tmp polly.opam

test:
	opam exec -- dune runtest

release:
	dune-release tag
	dune-release distrib
	dune-release opam pkg
	echo 'use "dune-release opam submit" to release on Opam'

# vim:ts=8:noet:
