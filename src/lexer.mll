{
  open Core
  open Lib
  open Parser
  exception Lexical_error of string
}

let newline = ('\010' | '\013' | "\013\010")
let letter = ['A'-'Z' 'a'-'z']
let identchar = ['A'-'Z' 'a'-'z' '_' '\'' '0'-'9']
let tick = '\''

let digit = ['0'-'9']
let int = '0' | ['1'-'9'] digit*
let hex = "0x" digit+
let bin = "0b" ['0'-'1']+

rule token sbuff = parse
| eof { EOF }
| "nop" { NOP }
| "u" { U }
| "ru" { RU }
| "swap" { SWAP }
| "get" { GET }
| "rget" { RGET }
| "add" { ADD }
| "radd" { RADD }
| "mul" { MUL }
| "rmul" { RMUL }
| "jmp" { JMP }
| "rjmp" { RJMP }
| "jz" { JZ }
| "rjz" { RJZ }
| "jnz" { JNZ }
| "rjnz" { RJNZ }
| "je" { JE }
| "rje" { RJE }
| "jne" { JNE }
| "rjne" { RJNE }
| "jg" { JG }
| "rjg" { RJG }
| "jge" { JGE }
| "rjge" { RJGE }
| "jl" { JL }
| "rjl" { RJL }
| "jle" { JLE }
| "rjle" { RJLE }
| "jmp*" { JMP_STAR }
| "rjmp*" { RJMP_STAR }
| "H" { H }
| "X" { X }
| "Y" { Y }
| "Z" { Z }
| [' ' '\t']
    { token sbuff lexbuf }
| newline
    { Lexing.new_line lexbuf; token sbuff lexbuf }
| letter identchar*
    { let s = Lexing.lexeme lexbuf in
      IDENT (Symbol.get_sym s) }
| "$" ("+" | "-")? (int | hex | bin)
    { let s = Lexing.lexeme lexbuf in INT (Int.of_string (String.drop_prefix s 1)) }
| ";"
    { comment lexbuf; token sbuff lexbuf }
| _
    { raise (Lexical_error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }

and comment = parse
  | newline
      { Lexing.new_line lexbuf }
  | _
      { comment lexbuf }
