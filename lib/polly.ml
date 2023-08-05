let assert_eq x y =
  if x <> y then (
    Printf.eprintf "0x%x != 0x%x = 0o%o\n%!" x y y ;
    assert false
  )

module Events = struct
  type t = int

  external polly_IN : unit -> t = "caml_polly_EPOLLIN"

  external polly_PRI : unit -> t = "caml_polly_EPOLLPRI"

  external polly_OUT : unit -> t = "caml_polly_EPOLLOUT"

  external polly_RDNORM : unit -> t = "caml_polly_EPOLLRDNORM"

  external polly_RDBAND : unit -> t = "caml_polly_EPOLLRDBAND"

  external polly_WRNORM : unit -> t = "caml_polly_EPOLLWRNORM"

  external polly_WRBAND : unit -> t = "caml_polly_EPOLLWRBAND"

  external polly_MSG : unit -> t = "caml_polly_EPOLLMSG"

  external polly_ERR : unit -> t = "caml_polly_EPOLLERR"

  external polly_HUP : unit -> t = "caml_polly_EPOLLHUP"

  external polly_RDHUP : unit -> t = "caml_polly_EPOLLRDHUP"

  external polly_WAKEUP : unit -> t = "caml_polly_EPOLLWAKEUP"

  external polly_ONESHOT : unit -> t = "caml_polly_EPOLLONESHOT"

  external polly_ET : unit -> t = "caml_polly_EPOLLET"

  (* external polly_EXCLUSIVE : unit -> t = "caml_polly_EPOLLEXCLUSIVE" *)

  let inp = 0x001

  let _ = assert_eq inp (polly_IN ())

  let pri = 0x002

  let _ = assert_eq pri (polly_PRI ())

  let out = 0x004

  let _ = assert_eq out (polly_OUT ())

  let rdnorm = 0x040

  let _ = assert_eq rdnorm (polly_RDNORM ())

  let rdband = 0x080

  let _ = assert_eq rdband (polly_RDBAND ())

  let wrnorm = 0x100

  let _ = assert_eq wrnorm (polly_WRNORM ())

  let wrband = 0x200

  let _ = assert_eq wrband (polly_WRBAND ())

  let msg = 0x400

  let _ = assert_eq msg (polly_MSG ())

  let err = 0x008

  let _ = assert_eq err (polly_ERR ())

  let hup = 0x010

  let _ = assert_eq hup (polly_HUP ())

  let rdhup = 0x2000

  let _ = assert_eq rdhup (polly_RDHUP ())

  (* let exclusive = 1 lsl 28
     let _ = assert_eq exclusive (polly_EXCLUSIVE ()) *)

  let wakeup = 1 lsl 29

  let _ = assert_eq wakeup (polly_WAKEUP ())

  let oneshot = 1 lsl 30

  let _ = assert_eq oneshot (polly_ONESHOT ())

  let et = 1 lsl 31

  let _ = assert_eq et (polly_ET ())

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

  external efd_cloexec : unit -> flags = "caml_polly_EFD_CLOEXEC"

  external efd_nonblock : unit -> flags = "caml_polly_EFD_NONBLOCK"

  external efd_semaphore : unit -> flags = "caml_polly_EFD_SEMAPHORE"

  let cloexec : flags = 0o2000000

  let _ = assert_eq cloexec (efd_cloexec ())

  let nonblock : flags = 0o0004000

  let _ = assert_eq nonblock (efd_nonblock ())

  let semaphore : flags = 0o0000001

  let _ = assert_eq semaphore (efd_semaphore ())

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
