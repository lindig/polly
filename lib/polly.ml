module Events = struct
  type t = int

  include Constants.Epoll

  let empty = 0

  let all =
    [
      (inp, "in")
    ; (pri, "pri")
    ; (out, "out")
    ; (rdnorm, "rdnorm")
    ; (rdband, "rdband")
    ; (wrnorm, "wrnorm")
    ; (wrband, "wrband")
    ; (msg, "msg")
    ; (err, "err")
    ; (hup, "hup")
    ; (rdhup, "rdhup") (*  ; (exclusive, "exclusive") *)
    ; (wakeup, "wakeup")
    ; (oneshot, "oneshot")
    ; (et, "et")
    ]

  let ( lor ) = ( lor )

  let ( land ) = ( land )

  let lnot = lnot

  let to_string t =
    let add result (event, str) =
      if t land event <> empty then str :: result else result
    in
    List.fold_left add [] all |> String.concat " "

  let test x y = x land y <> empty
end

type t = Unix.file_descr (* epoll fd *)

external caml_polly_add : t -> Unix.file_descr -> Events.t -> unit
  = "caml_polly_add"

external caml_polly_del : t -> Unix.file_descr -> Events.t -> unit
  = "caml_polly_del"

external caml_polly_mod : t -> Unix.file_descr -> Events.t -> unit
  = "caml_polly_mod"

external caml_polly_create1 : unit -> t = "caml_polly_create1"

external caml_polly_wait :
     t (* epoll fd *)
  -> int (* max number of fds handled *)
  -> int (* timeout in ms *)
  -> (Unix.file_descr -> Unix.file_descr -> Events.t -> unit)
  -> int (* actual number of ready fds; 0 = timeout *) = "caml_polly_wait"

external caml_polly_wait_fold :
     t (* epoll fd *)
  -> int (* max number of fds handled *)
  -> int (* timeout in ms *)
  -> 'a (* initial value *)
  -> (Unix.file_descr -> Unix.file_descr -> Events.t -> 'a -> 'a)
  -> 'a (* final value *) = "caml_polly_wait_fold"

let create = caml_polly_create1

let close t = Unix.close t

let add = caml_polly_add

let del t fd = caml_polly_del t fd Events.empty

let upd = caml_polly_mod

let wait = caml_polly_wait

let wait_fold = caml_polly_wait_fold

module EventFD = struct
  type t = Unix.file_descr

  type flags = int

  external create : int -> flags -> t = "caml_polly_eventfd"

  include Constants.EventFD

  let empty = 0

  let close = Unix.close

  let all =
    [(cloexec, "cloexec"); (nonblock, "nonblock"); (semaphore, "semaphore")]

  let ( lor ) = ( lor )

  let ( land ) = ( land )

  let lnot = lnot

  let to_string t =
    let add result (event, str) =
      if t land event <> empty then str :: result else result
    in
    List.fold_left add [] all |> String.concat " "

  let test x y = x land y <> empty

  let fail fmt = Printf.ksprintf failwith fmt

  let read : Unix.file_descr -> int64 =
   fun eventfd ->
    let buf = Bytes.create 8 in
    let __FUNCTION__ = "Polly.EventFD.read" in
    if Unix.read eventfd buf 0 8 <> 8 then
      fail "%s: Unix.read failed" __FUNCTION__ ;
    Bytes.get_int64_ne buf 0

  let add : Unix.file_descr -> int64 -> unit =
   fun eventfd n ->
    let buf = Bytes.create 8 in
    let __FUNCTION__ = "Polly.EventFD.add" in
    Bytes.set_int64_ne buf 0 n ;
    if Unix.single_write eventfd buf 0 8 <> 8 then
      fail "%s: Unix.single_write failed" __FUNCTION__
end
