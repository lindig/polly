module C = Cmdliner

let timeout = 2000

let run = ref true

let buf = Bytes.make 20 '@'

let create_socket path =
  let sock = Unix.(socket PF_UNIX SOCK_STREAM 0) in
  let addr = Unix.ADDR_UNIX path in
  Unix.bind sock addr ; Unix.listen sock 10 ; sock

let accept epoll sock =
  let fd, _ = Unix.accept sock in
  Polly.add epoll fd Polly.Events.(inp)

let ( +++ ) = Polly.Events.( lor )

let ready = Polly.Events.(inp +++ hup)

let other = Polly.Events.(lnot ready)

let process sock epoll fd events count =
  if fd = sock && Polly.Events.(test events inp) then (
    accept epoll sock ; count
  ) else (
    ( if Polly.Events.(test events ready) then
        match Unix.read fd buf 0 20 with
        | 0 ->
            Unix.close fd
        | n ->
            Unix.write Unix.stdout buf 0 n |> ignore
    ) ;
    if Polly.Events.(test events other) then Unix.close fd ;
    count + 1
  )

let polly path =
  let epoll = Polly.create () in
  let sock = create_socket path in
  let clean () = try Unix.unlink path with _ -> () in
  at_exit clean ;
  Polly.add epoll sock Polly.Events.(inp) ;
  while !run do
    match Polly.wait_fold epoll 10 timeout 0 (process sock) with
    | _ ->
        ()
    | exception Unix.Unix_error (Unix.EINTR, _, _) ->
        ()
  done

module Command = struct
  let help =
    [
      `S "BUGS"; `P "Check bug reports at https://github.com/lindig/polly/issues"
    ]

  let path =
    C.Arg.(
      value
      & pos 0 string "polly.sock"
      & info [] ~docv:"FILE" ~doc:"Socket to read from"
    )

  let polly =
    let doc = "Read from multiple connections, write to stdout" in
    let info = C.Cmd.info "polly" ~doc ~man:help in
    C.(Cmd.v info Term.(const polly $ path))
end

let main () =
  let signal _ = exit 1 in
  Sys.set_signal Sys.sigterm (Sys.Signal_handle signal) ;
  Sys.set_signal Sys.sigint (Sys.Signal_handle signal) ;
  C.Cmd.eval Command.polly

let () = if !Sys.interactive then () else main () |> exit
