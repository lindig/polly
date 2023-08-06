
![Build Status](https://github.com/lindig/polly/actions/workflows/workflow.yml/badge.svg)

# Polly

Polly is an [OCaml] binding for the Linux [epoll] system call:

* Small, simple, and self-contained
* Avoids most allocation in the event loop
* MIT licensed

Note that [epoll] is specific to Linux and that this library won't
compile on macOS, for example.

## Installation

As of version 0.2.2, Polly is now in [Opam] and can be installed from
there:

```
opam install polly
```

Most recently version 0.4.1 was [submitted] to [Opam].

## Using inside utop

* `make utop` or
* `dune utop`

launches a utop toplevel that has the library loaded for interactive
use.


## Other Epoll Bindings

* [OCaml Backpack](https://github.com/jimenezrick/ocaml-backpack/)
* [Jane Street Core](https://github.com/janestreet/core)

## Contribute

If you find this useful, please contribute back by raising pull
requests for improvements you made.

[OCaml]:  https://www.ocaml.org/
[epoll]:  http://man7.org/linux/man-pages/man2/epoll_wait.2.html
[Opam]:   http://opam.ocaml.org/
[submitted]: https://github.com/ocaml/opam-repository/pull/24212

