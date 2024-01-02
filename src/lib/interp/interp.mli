type state =
  { pc : int
  ; br : int
  ; reg : int Core.Int.Map.t
  }

val print : (Complex.t * state) list -> unit
val is_synchronized : (Complex.t * state) list -> bool

val interp
  :  (string * int) list list
  -> string list
  -> Ast.inst list
  -> int
  -> (Complex.t * state) list
