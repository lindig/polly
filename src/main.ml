module C = Cmdliner
module Epoll = Polly.Epoll

let timeout = 2000

let run = ref true

let buf = Bytes.make 20 '@'

let create_socket path =
  let sock = Unix.(socket PF_UNIX SOCK_STREAM 0) in
  let addr = Unix.ADDR_UNIX path in
  Unix.bind sock addr;
  Unix.listen sock 10;
  sock

let accept epoll sock =
  let fd, _ = Unix.accept sock in
  Epoll.add epoll fd Epoll.Events.(inp)

let ( +++ ) = Epoll.Events.( lor )

let ready = Epoll.Events.(inp +++ hup)

let other = Epoll.Events.(lnot ready)

let process sock epoll fd events =
  if fd = sock && Epoll.Events.(test events inp) then accept epoll sock
  else (
    ( if Epoll.Events.(test events ready) then
      match Unix.read fd buf 0 20 with
      | 0 -> Unix.close fd
      | n -> Unix.write Unix.stdout buf 0 n |> ignore );
    if Epoll.Events.(test events other) then Unix.close fd )

let polly path =
  let epoll = Epoll.create () in
  let sock = create_socket path in
  let clean () = try Unix.unlink path with _ -> () in
  at_exit clean;
  Epoll.add epoll sock Epoll.Events.(inp);
  while !run do
    match Epoll.wait epoll 10 timeout (process sock) with
    | _ -> ()
    | exception Unix.Unix_error (Unix.EINTR, _, _) -> ()
  done

module Command = struct
  let help =
    [
      `S "BUGS";
      `P "Check bug reports at https://github.com/lindig/polly/issues";
    ]

  let path =
    C.Arg.(
      value & pos 0 string "polly.sock"
      & info [] ~docv:"FILE" ~doc:"Socket to read from")

  let polly =
    let doc = "Read from multiple connections, write to stdout" in
    C.Term.(const polly $ path, info "polly" ~doc ~man:help)
end

let main () =
  let signal _ = exit 1 in
  Sys.set_signal Sys.sigterm (Sys.Signal_handle signal);
  Sys.set_signal Sys.sigint (Sys.Signal_handle signal);
  match C.Term.eval Command.polly ~catch:false with
  | `Error _      -> exit 1
  | _             -> exit 0
  | exception exn ->
      Printf.eprintf "error: %s\n" (Printexc.to_string exn);
      exit 1

let () = if !Sys.interactive then () else main ()
