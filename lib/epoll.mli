module Events : sig
  type t

  val empty : t
  val err : t
  val et : t
  val hup : t
  val inp : t
  val oneshot : t
  val out : t
  val pri : t
  val rdhup : t

  val ( lor ) : t -> t -> t
  val ( land ) : t -> t -> t

  val to_string : t -> string
end

val create : unit -> Unix.file_descr

val add : Unix.file_descr -> Unix.file_descr -> Events.t -> unit

val del : Unix.file_descr -> Unix.file_descr -> Events.t -> unit

val wait :
  Unix.file_descr -> int -> int -> (Unix.file_descr -> Events.t -> unit) -> int
