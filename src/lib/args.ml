open Core

let verbose = ref false
let time = ref 0
let regs = ref []
let uniforms = ref ""
let word_size = ref 4

let speclist =
  [ "-v", Arg.Set verbose, "Run in verbose mode."
  ; "-t", Arg.Set_int time, "Number of execution steps"
  ; ( "-r"
    , Arg.String (fun r -> regs := r :: !regs)
    , "Comma-separated list of reg=value. May provide multiple times." )
  ; ( "-u"
    , Arg.Set_string uniforms
    , "Comma-separated list of registers to be assigned to uniform superposition" )
  ; "-w", Arg.Set_int word_size, "Word size in bits"
  ]
;;
