type t = int [@@deriving show, eq, sexp_of]

val get_sym : string -> t
val name : t -> string
val nonce : unit -> t
