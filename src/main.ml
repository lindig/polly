module C = Cmdliner

let timeout = 2000
let run = ref true

let buf = Bytes.make 20 '@'


let process fd events =
  Printf.eprintf "events = %s\n%!" (Epoll.Events.to_string events) ;
  if Epoll.Events.(events land inp <> empty) then
    let n = Unix.read fd buf 0 20 in
    Unix.write Unix.stdout buf 0 n |> ignore
  else if Epoll.Events.(events land out <> empty) then
    Unix.write_substring fd "hello\n" 0 6 |> ignore

let polly files =
  let epoll = Epoll.create () in
  let fds = files |> List.map (fun x -> Unix.openfile x [Unix.O_RDONLY] 0) in
  let add fd = Epoll.add epoll fd Epoll.Events.(inp) in
  let _ = List.iter add fds in
  while !run do
    Epoll.wait epoll 10 timeout process |> ignore
  done

module Command = struct
  let help =
    [ `P "These options are common to all commands."
    ; `S "MORE HELP"
    ; `P "Use `$(mname) $(i,COMMAND) --help' for help on a single command."
    ; `S "BUGS"
    ; `P "Check bug reports at https://github.com/lindig/polly/issues" ]

  let files =
    C.Arg.(
      non_empty & pos_all file []
      & info [] ~docv:"FILE" ~doc:"Socket to read from")

  let polly =
    let doc = "Read from multiple sockets" in
    C.Term.(const polly $ files, info "polly" ~doc ~man:help)
end

let main () =
  try
    match C.Term.eval Command.polly ~catch:false with
    | `Error _ -> exit 1
    | _ -> exit 0
  with exn ->
    Printf.eprintf "error: %s\n" (Printexc.to_string exn) ;
    exit 1

let () = if !Sys.interactive then () else main ()
