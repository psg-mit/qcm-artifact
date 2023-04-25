%{
  open Lib.Ast
  module Hashtbl = Core.Hashtbl
%}

%token <Lib.Symbol.t> IDENT
%token <int> INT
%token EOF

%token H
%token X
%token Y
%token Z

%token NOP
%token U
%token RU
%token SWAP
%token GET
%token RGET
%token ADD
%token RADD
%token MUL
%token RMUL
%token JMP
%token RJMP
%token JZ
%token RJZ
%token JNZ
%token RJNZ
%token JE
%token RJE
%token JNE
%token RJNE
%token JG
%token RJG
%token JGE
%token RJGE
%token JL
%token RJL
%token JLE
%token RJLE
%token JMP_STAR
%token RJMP_STAR

%start <inst list> program

%%

program:
| p = list(inst) EOF
  { p }

inst:
| NOP
  { Nop }
| U u = unitary ra = IDENT
  { U (u, ra) }
| RU u = unitary ra = IDENT
  { RU (u, ra) }
| SWAP ra = IDENT rb = IDENT
  { Swap (ra, rb) }
| GET ra = IDENT rb = IDENT rc = IDENT
  { Get (Reg ra, rb, rc) }
| RGET ra = IDENT rb = IDENT rc = IDENT
  { RGet (Reg ra, rb, rc) }
| ADD ra = IDENT rb = IDENT
  { Add (ra, Reg rb) }
| RADD ra = IDENT rb = IDENT
  { RAdd (ra, Reg rb) }
| MUL ra = IDENT rb = IDENT
  { Mul (ra, Reg rb) }
| RMUL ra = IDENT rb = IDENT
  { RMul (ra, Reg rb) }
| GET ra = INT rb = IDENT rc = IDENT
  { Get (Imm ra, rb, rc) }
| RGET ra = INT rb = IDENT rc = IDENT
  { RGet (Imm ra, rb, rc) }
| ADD ra = IDENT rb = INT
  { Add (ra, Imm rb) }
| RADD ra = IDENT rb = INT
  { RAdd (ra, Imm rb) }
| MUL ra = IDENT rb = INT
  { Mul (ra, Imm rb) }
| RMUL ra = IDENT rb = INT
  { RMul (ra, Imm rb) }
| JMP p = INT
  { Jmp p }
| RJMP p = INT
  { RJmp p }
| JZ p = INT ra = IDENT
  { JumpIf (Zero, ra, p) }
| RJZ p = INT ra = IDENT
  { RJumpIf (Zero, ra, p) }
| JNZ p = INT ra = IDENT
  { JumpIf (NotZero, ra, p) }
| RJNZ p = INT ra = IDENT
  { RJumpIf (NotZero, ra, p) }
| JE p = INT ra = IDENT rb = IDENT
  { JumpIf2 (Equal, ra, rb, p) }
| RJE p = INT ra = IDENT rb = IDENT
  { RJumpIf2 (Equal, ra, rb, p) }
| JNE p = INT ra = IDENT rb = IDENT
  { JumpIf2 (NotEqual, ra, rb, p) }
| RJNE p = INT ra = IDENT rb = IDENT
  { RJumpIf2 (NotEqual, ra, rb, p) }
| JG p = INT ra = IDENT rb = IDENT
  { JumpIf2 (Greater, ra, rb, p) }
| RJG p = INT ra = IDENT rb = IDENT
  { RJumpIf2 (Greater, ra, rb, p) }
| JL p = INT ra = IDENT rb = IDENT
  { JumpIf2 (Less, ra, rb, p) }
| RJL p = INT ra = IDENT rb = IDENT
  { RJumpIf2 (Less, ra, rb, p) }
| JGE p = INT ra = IDENT rb = IDENT
  { JumpIf2 (GreaterEqual, ra, rb, p) }
| RJGE p = INT ra = IDENT rb = IDENT
  { RJumpIf2 (GreaterEqual, ra, rb, p) }
| JLE p = INT ra = IDENT rb = IDENT
  { JumpIf2 (LessEqual, ra, rb, p) }
| RJLE p = INT ra = IDENT rb = IDENT
  { RJumpIf2 (LessEqual, ra, rb, p) }
| JMP_STAR ra = IDENT
  { JumpInd ra }
| RJMP_STAR ra = IDENT
  { RJumpInd ra }

unitary:
| H { H }
| X { X }
| Y { Y }
| Z { Z }
