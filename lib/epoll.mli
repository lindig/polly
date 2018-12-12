module Events : sig
  type t

  val empty : t
  val inp : t
  val pri : t
  val out : t
  val rdnorm : t
  val rdband : t
  val wrnorm : t
  val wrband : t
  val msg : t
  val err : t
  val hup : t
  val rdhup : t
  val exclusive : t
  val wakeup : t
  val oneshot : t
  val et : t

  val ( lor ) : t -> t -> t

  val ( land ) : t -> t -> t

  val lnot : t -> t

  val test : t -> t -> bool
  val to_string : t -> string
end

val create : unit -> Unix.file_descr

val add : Unix.file_descr -> Unix.file_descr -> Events.t -> unit

val upd : Unix.file_descr -> Unix.file_descr -> Events.t -> unit

val del : Unix.file_descr -> Unix.file_descr -> unit

val wait :
     Unix.file_descr
  -> int
  -> int
  -> (Unix.file_descr -> Unix.file_descr -> Events.t -> unit)
  -> int
