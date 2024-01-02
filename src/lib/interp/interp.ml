open Core

type state =
  { pc : int
  ; br : int
  ; reg : int Int.Map.t
  }
[@@deriving sexp_of]

let state_to_string state =
  let reg =
    Map.to_alist state.reg
    |> List.map ~f:(fun (k, v) -> sprintf "%s:%d" (Symbol.name k) v)
    |> String.concat ~sep:","
  in
  sprintf "pc:%d,br:%d,%s" state.pc state.br reg
;;

let return_one state = [ Complex.one, state ]

let interp_inst state = function
  | Ast.Nop -> return_one state
  | Swap (r1, r2) ->
    let reg = Map.(change state.reg r1 ~f:(fun _ -> find state.reg r2)) in
    let reg = Map.(change reg r2 ~f:(fun _ -> find state.reg r1)) in
    return_one { state with reg }
  | Get (r1, r2, r3) ->
    let r1v =
      match r1 with
      | Reg r1 -> Map.find_exn state.reg r1
      | Imm r1 -> r1
    in
    let r3v = Map.find_exn state.reg r3 in
    let reg =
      Map.change state.reg r2 ~f:(fun _ ->
        Some Int.(bit_and 1 (shift_right_logical r3v r1v)))
    in
    let reg =
      Map.change reg r3 ~f:(fun _ ->
        Some Int.(bit_and r3v (bit_not (Int.shift_left 1 r1v))))
    in
    return_one { state with reg }
  | RGet (r1, r2, r3) ->
    let r1v =
      match r1 with
      | Reg r1 -> Map.find_exn state.reg r1
      | Imm r1 -> r1
    in
    let r2v = Map.find_exn state.reg r2 in
    let reg =
      Map.change state.reg r3 ~f:(fun r3 ->
        let r3v = Option.value_exn r3 in
        Some (if r2v = 1 then Int.(bit_or (shift_left 1 r1v)) r3v else r3v))
    in
    let reg = Map.change reg r2 ~f:(fun _ -> Some 0) in
    return_one { state with reg }
  | Add (r1, r2) ->
    let r2v =
      match r2 with
      | Reg r2 -> Map.find_exn state.reg r2
      | Imm r2 -> r2
    in
    let reg = Map.change state.reg r1 ~f:(fun r1 -> Some (Option.value_exn r1 + r2v)) in
    return_one { state with reg }
  | RAdd (r1, r2) ->
    let r2v =
      match r2 with
      | Reg r2 -> Map.find_exn state.reg r2
      | Imm r2 -> r2
    in
    let reg = Map.change state.reg r1 ~f:(fun r1 -> Some (Option.value_exn r1 - r2v)) in
    return_one { state with reg }
  | Mul (r1, r2) ->
    let r2v =
      match r2 with
      | Reg r2 -> Map.find_exn state.reg r2
      | Imm r2 -> r2
    in
    let reg = Map.change state.reg r1 ~f:(fun r1 -> Some (Option.value_exn r1 * r2v)) in
    return_one { state with reg }
  | RMul (r1, r2) ->
    let r2v =
      match r2 with
      | Reg r2 -> Map.find_exn state.reg r2
      | Imm r2 -> r2
    in
    let reg = Map.change state.reg r1 ~f:(fun r1 -> Some (Option.value_exn r1 / r2v)) in
    return_one { state with reg }
  | Jmp p -> return_one { state with br = state.br + (p - 1) }
  | RJmp p -> return_one { state with br = state.br - (p - 1) }
  | JumpIf (c, r1, p) ->
    let br =
      if match c with
         | Zero -> Map.find_exn state.reg r1 = 0
         | NotZero -> Map.find_exn state.reg r1 <> 0
      then state.br + (p - 1)
      else state.br
    in
    return_one { state with br }
  | RJumpIf (c, r1, p) ->
    let br =
      if match c with
         | Zero -> Map.find_exn state.reg r1 = 0
         | NotZero -> Map.find_exn state.reg r1 <> 0
      then state.br - (p - 1)
      else state.br
    in
    return_one { state with br }
  | JumpIf2 (c, r1, r2, p) ->
    let r1, r2 = Map.find_exn state.reg r1, Map.find_exn state.reg r2 in
    let br =
      if match c with
         | Equal -> r1 = r2
         | NotEqual -> r1 <> r2
         | Greater -> r1 > r2
         | Less -> r1 < r2
         | GreaterEqual -> r1 >= r2
         | LessEqual -> r1 <= r2
      then state.br + (p - 1)
      else state.br
    in
    return_one { state with br }
  | RJumpIf2 (c, r1, r2, p) ->
    let r1, r2 = Map.find_exn state.reg r1, Map.find_exn state.reg r2 in
    let br =
      if match c with
         | Equal -> r1 = r2
         | NotEqual -> r1 <> r2
         | Greater -> r1 > r2
         | Less -> r1 < r2
         | GreaterEqual -> r1 >= r2
         | LessEqual -> r1 <= r2
      then state.br - (p - 1)
      else state.br
    in
    return_one { state with br }
  | JumpInd r -> return_one { state with br = state.br + Map.find_exn state.reg r }
  | RJumpInd r -> return_one { state with br = state.br - Map.find_exn state.reg r }
  | U (u, r1) | RU (u, r1) ->
    let r1v = Map.find_exn state.reg r1 in
    (match u with
     | X ->
       let reg = Map.(change state.reg r1 ~f:(fun _ -> Some (1 - r1v))) in
       return_one { state with reg }
     | Y ->
       let reg = Map.(change state.reg r1 ~f:(fun _ -> Some (1 - r1v))) in
       [ (if r1v = 0 then Complex.i else Complex.neg Complex.i), { state with reg } ]
     | Z -> [ (if r1v = 0 then Complex.one else Complex.neg Complex.one), state ]
     | H ->
       [ ( Complex.(div one (sqrt (add one one)))
         , { state with reg = Map.change state.reg r1 ~f:(fun _ -> Some 0) } )
       ; ( Complex.(mul (if r1v = 0 then one else neg one) (div one (sqrt (add one one))))
         , { state with reg = Map.change state.reg r1 ~f:(fun _ -> Some 1) } )
       ])
;;

let merge states =
  List.sort_and_group states ~compare:(fun (_, state1) (_, state2) ->
    let c1 = Int.compare state1.pc state2.pc in
    if c1 <> 0
    then c1
    else (
      let c2 = Int.compare state1.br state2.br in
      if c2 <> 0 then c2 else Map.compare_direct Int.compare state1.reg state2.reg))
  |> List.map ~f:(fun states ->
    ( List.map ~f:fst states |> List.fold ~init:Complex.zero ~f:Complex.add
    , List.hd_exn states |> snd ))
;;

let print state =
  state
  |> List.map ~f:(fun ((amp : Complex.t), state) ->
    Format.sprintf "(%f + %fi) |%s>" amp.re amp.im (state_to_string state))
  |> String.concat ~sep:" + "
  |> print_endline
;;

let is_synchronized state =
  state
  |> List.map ~f:(fun (_, state) -> state.pc, state.br)
  |> List.dedup_and_sort ~compare:(fun (pc1, br1) (pc2, br2) ->
    let c1 = Int.compare pc1 pc2 in
    if c1 <> 0 then c1 else Int.compare br1 br2)
  |> List.length
  = 1
;;

let interp regs uniforms insts t =
  let insts = Array.of_list insts in
  let rec loop i state =
    if i = t
    then state
    else (
      let state' =
        List.concat_map state ~f:(fun (amp, state) ->
          interp_inst state insts.(state.pc)
          |> List.map ~f:(fun (amp', state) ->
            Complex.mul amp amp', { state with pc = state.pc + state.br }))
      in
      loop (i + 1) (merge state'))
  in
  let add_regs regs =
    List.fold regs ~init:Int.Map.empty ~f:(fun acc (key, data) ->
      Map.add_exn acc ~key:(Symbol.get_sym key) ~data)
  in
  let reg = List.map ~f:add_regs regs in
  let reg = if List.is_empty reg then [ Int.Map.empty ] else reg in
  let add_uniforms reg =
    List.fold uniforms ~init:[ reg ] ~f:(fun acc key ->
      List.concat_map acc ~f:(fun reg ->
        List.init (1 lsl !Args.word_size) ~f:(fun data ->
          Map.add_exn reg ~key:(Symbol.get_sym key) ~data)))
  in
  let regs = List.concat_map ~f:add_uniforms reg in
  let state =
    let re = 1.0 /. sqrt (float_of_int (List.length regs)) in
    List.map regs ~f:(fun reg -> Complex.{ re; im = 0.0 }, { pc = 0; br = 1; reg })
  in
  loop 0 state
;;
