open Core

type reg = Symbol.t [@@deriving show, eq, sexp_of]
type offset = int [@@deriving show, eq, sexp_of]

type unary =
  | Zero
  | NotZero
[@@deriving show, eq, sexp_of]

type binary =
  | Equal
  | NotEqual
  | Greater
  | Less
  | GreaterEqual
  | LessEqual
[@@deriving show, eq, sexp_of]

type unitary =
  | H
  | X
  | Y
  | Z
[@@deriving show, eq, sexp_of]

type arg =
  | Reg of reg
  | Imm of int
  [@@deriving show, eq, sexp_of]

type inst =
  | Nop
  | U of unitary * reg
  | RU of unitary * reg
  | Swap of reg * reg
  | Get of arg * reg * reg
  | RGet of arg * reg * reg
  | Add of reg * arg
  | RAdd of reg * arg
  | Mul of reg * arg
  | RMul of reg * arg
  | Jmp of offset
  | RJmp of offset
  | JumpIf of unary * reg * offset
  | RJumpIf of unary * reg * offset
  | JumpIf2 of binary * reg * reg * offset
  | RJumpIf2 of binary * reg * reg * offset
  | JumpInd of reg
  | RJumpInd of reg
[@@deriving show, eq, sexp_of]
