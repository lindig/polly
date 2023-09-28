(lang dune 2.0)

(generate_opam_files true)

(source
 (github lindig/polly))

(license MIT)

(authors "Christian Lindig <christian.lindig@cloud.com>")

(maintainers "Christian Lindig <christian.lindig@cloud.com>")

(package
 (name polly)
 (synopsis "Bindings for the Linux epoll system call")
 (description
  "Bindings for the Linux epoll system call. The binding avoids\nmost allocation in the event loop by iterating over all file\ndescriptors that are reported as ready.\n")
 (depends
  (ocaml
   (>= 4.08.0))
  (cmdliner
   (>= 1.1.0))
  base-unix
  conf-linux-libc-dev))
