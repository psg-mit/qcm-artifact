open Core
open Format
open Lib

exception Error of string

let print_position _ lexbuf =
  let open Lexing in
  let pos = lexbuf.lex_curr_p in
  sprintf "%s:%d:%d" pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)
;;

let parse parsing_fun lexing_fun source_name =
  let ic = In_channel.create source_name in
  let lexbuf = Lexing.from_channel ic in
  lexbuf.Lexing.lex_curr_p
    <- { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = source_name };
  try
    let p = parsing_fun lexing_fun lexbuf in
    In_channel.close ic;
    p
  with
  | Lexer.Lexical_error err ->
    In_channel.close ic;
    raise (Error (sprintf "%a: %s\n" print_position lexbuf err))
  | Parser.Error ->
    In_channel.close ic;
    raise (Error (sprintf "%a: Syntax error.\n" print_position lexbuf))
;;

let insts = ref []

let load file =
  let d = parse Parser.program (Lexer.token ()) file in
  insts := d
;;

let () =
  let desc =
    Format.sprintf
      "The simulator for the quantum control machine.\n\
       Usage: %s <options> [program] \n\
       Options are:"
      (Sys.get_argv ()).(0)
  in
  try
    Arg.parse Args.speclist load desc;
    if !Args.time <= 0
    then raise (Error "Must provide positive time with -t.")
    else (
      let parse_regs regs =
        String.split ~on:',' regs
        |> List.map ~f:(fun s ->
             String.strip s
             |> String.split ~on:'='
             |> fun l -> List.hd_exn l, Int.of_string (List.last_exn l))
      in
      let regs = List.map ~f:parse_regs !Args.regs in
      let uniforms =
        String.split ~on:',' !Args.uniforms
        |> List.map ~f:String.strip
        |> List.filter ~f:(fun s -> not (String.is_empty s))
      in
      let state = Interp.interp regs uniforms !insts !Args.time in
      Interp.print state;
      Format.printf
        "state is %ssynchronized\n%!"
        (if Interp.is_synchronized state then "" else "not "))
  with
  | Error s ->
    fprintf std_formatter "%s" s;
    exit 1
;;
