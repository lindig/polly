module Events = struct
  type t = int

  external epoll_ERR : unit -> t = "caml_epoll_EPOLLERR"
  external epoll_ET : unit -> t = "caml_epoll_EPOLLET"
  external epoll_HUP : unit -> t = "caml_epoll_EPOLLHUP"
  external epoll_IN : unit -> t = "caml_epoll_EPOLLIN"
  external epoll_ONESHOT : unit -> t = "caml_epoll_EPOLLONESHOT"
  external epoll_OUT : unit -> t = "caml_epoll_EPOLLOUT"
  external epoll_PRI : unit -> t = "caml_epoll_EPOLLPRI"
  external epoll_RDHUP : unit -> t = "caml_epoll_EPOLLRDHUP"

  let empty = 0
  let err = epoll_ERR ()
  let et = epoll_ET ()
  let hup = epoll_HUP ()
  let inp = epoll_IN ()
  let oneshot = epoll_ONESHOT ()
  let out = epoll_OUT ()
  let pri = epoll_PRI ()
  let rdhup = epoll_RDHUP ()

  let all =
    [ (err, "err")
    ; (et, "et")
    ; (hup, "hup")
    ; (inp, "in")
    ; (oneshot, "oneshot")
    ; (out, "out")
    ; (pri, "pri")
    ; (rdhup, "rdhup") ]

  let ( lor ) = ( lor )
  let ( land ) = ( land )

  let to_string t =
    let add result (event, str) =
      if t land event <> empty then str :: result else result
    in
    List.fold_left add [] all |> String.concat " "
end

external caml_epoll_add :
  Unix.file_descr -> Unix.file_descr -> Events.t -> unit
  = "caml_epoll_add"

external caml_epoll_del :
  Unix.file_descr -> Unix.file_descr -> Events.t -> unit
  = "caml_epoll_del"

external _caml_epoll_mod :
  Unix.file_descr -> Unix.file_descr -> Events.t -> unit
  = "caml_epoll_mod"

external caml_epoll_create1 : unit -> Unix.file_descr = "caml_epoll_create1"

external caml_epoll_wait :
     Unix.file_descr (* epoll fd *)
  -> int (* max number of fds handled *)
  -> int (* timeout in ms *)
  -> (Unix.file_descr -> Unix.file_descr -> Events.t -> unit)
  -> int (* actual number of ready fds; 0 = timeout *)
  = "caml_epoll_wait"

let create = caml_epoll_create1
let add = caml_epoll_add
let del t fd = caml_epoll_del t fd Events.empty
let wait = caml_epoll_wait
