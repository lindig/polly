module C = Cmdliner

let timeout = 2000

let buf = Bytes.make 20 '@'

let process fd events =
  Printf.eprintf "events = %s\n" (Epoll.Events.to_string events);
  if Epoll.Events.(events land inp <> empty) then begin
    let n = Unix.read fd buf 0 20 in
    Unix.write Unix.stdout buf 0 n |> ignore
  end else if Epoll.Events.(events land out <> empty) then begin
    Unix.write_substring fd "hello\n" 0 6 |> ignore
  end


let hello name =
  let io = Unix.openfile name [Unix.O_RDONLY] 0 in
  let rwx     = Epoll.Events.(inp lor out) in
  let epoll   = Epoll.create () in
  let add fd  = Epoll.add epoll fd rwx in
  let _       = List.iter add [ Unix.stdin; io ] in
  let rec loop = function
    | 0 -> ()
    | n ->
      let ready = Epoll.wait epoll 10 timeout process in
      Printf.eprintf "Epoll.wait = %d\n" ready;
      loop (n-1)
  in 
    loop 10

module Command = struct
  let help =
    [ `P "These options are common to all commands."
    ; `S "MORE HELP"
    ; `P "Use `$(mname) $(i,COMMAND) --help' for help on a single command."
    ; `S "BUGS"
    ; `P "Check bug reports at https://github.com/lindig/hello/issues" ]

  let name' =
    C.Arg.(
      value & pos 0 string "world"
      & info [] ~docv:"NAME"
          ~doc:"Name of person to greet; the default is 'world'.")

  let hello =
    let doc = "Say hello to someone" in
    C.Term.(const hello $ name', info "hello" ~doc ~man:help)
end

let main () =
  try
    match C.Term.eval Command.hello ~catch:false with
    | `Error _ -> exit 1
    | _ -> exit 0
  with exn ->
    Printf.eprintf "error: %s\n" (Printexc.to_string exn) ;
    exit 1

let () = if !Sys.interactive then () else main ()
