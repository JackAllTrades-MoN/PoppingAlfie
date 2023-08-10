
type mode = Default | Rising of int | Falling

type t = {
  mode: mode;
  ground_level: int;
  gravity: float;
  velocity: float;
  y_position: float;
}

let jump_max = 9
let acceleration = 10.

let init = {
  mode = Default;
  ground_level = 0;
  gravity = 5.;
  velocity = 0.;
  y_position = 0.;
}

let str_of_mode = function
  | Default -> "Default"
  | Rising level -> Printf.sprintf "Rising(%d)" level
  | Falling -> "Falling"

let str_of (alfie: t) =
  let mode = str_of_mode alfie.mode in
  Printf.sprintf "{mode=%s, velocity=%f, y_position=%f}" mode alfie.velocity alfie.y_position

let is_on_the_ground (alfie: t) = alfie.y_position = 0.

let sprite_index_of (alfie: t) =
  match alfie.mode with
  | Default -> 0
  | Rising _ -> 1
  | Falling -> 1

let render_size sprite_w sprite_h _canvas_w canvas_h =
  let h = canvas_h /. 6. in
  let a = sprite_w /. sprite_h in
  let w = a *. h in
  (w, h)

let render sprites (alfie: t) =
  let idx = sprite_index_of alfie in
  let sprite_alfie = Hashtbl.find sprites "alfie" in
  let cw, ch = Global.canvas_size in
  let cw, ch = float_of_int cw, float_of_int ch in
  let sw, sh = Sprite.size_of ~idx sprite_alfie in
  let (w, h) = render_size sw sh cw ch in
  let x = 30. in
  let y = ch -. h -. alfie.y_position in
  Sprite.render_full ~idx sprite_alfie x y w h

let apply_gravity (alfie: t) =
  let velocity = if alfie.y_position > 0. then alfie.velocity -. alfie.gravity else alfie.velocity in
  let y_position = Float.max (alfie.y_position +. velocity) 0. in
  let velocity = if y_position = 0. then 0. else velocity in
  {alfie with velocity; y_position}

let apply_jump (alfie: t) =
  match alfie.mode with
    | Rising level when level < jump_max ->
      let velocity = alfie.velocity +. acceleration in
      let mode = Rising (level + 1) in
      {alfie with velocity; mode}
    | Rising _ -> {alfie with mode = Falling}
    | Falling when is_on_the_ground alfie -> {alfie with mode = Default}
    | _ -> alfie

let update (alfie: t) =
  let _ = print_endline "update" in
  let _ = print_endline @@ str_of alfie in
  alfie |> apply_jump |> apply_gravity
  |> (fun alfie -> print_endline @@ str_of alfie; alfie)

let start_jump (alfie: t) =
  match alfie.mode with
  | Default -> {alfie with mode = Rising 0}
  | _ -> alfie

let stop_jump (alfie: t) = match alfie.mode with
  | Rising _ -> {alfie with mode = Falling}
  | _ -> alfie


(*
type t = {
  jump_level: int;
  velocity: float;
  position: float;
  sprite: Sprite.t;
  cnt: int;
}

let maximum_level = 12

let create sprite = {
  jump_level=0;
  velocity=0.;
  position=0.;
  sprite=sprite;
  cnt=0;
}

let is_on_the_ground (alfie: t) = alfie.position = 0.
let accelerate (alfie: t) = {alfie with velocity = alfie.velocity +. 7.5}

let start_jump (alfie: t) = {alfie with jump_level = 1} |> accelerate
let end_jump (alfie: t) = {alfie with jump_level = 0}
let jump_higher (alfie: t) =
  if 0 < alfie.jump_level && alfie.jump_level < maximum_level
  then {alfie with jump_level = alfie.jump_level + 1} |> accelerate
  else end_jump alfie

let stop (alfie: t) = {alfie with velocity = 0.}

let render ctx (alfie: t) =
  let _, ch = Global.canvas_size in
  let ch = Float.of_int ch in
  let sprite = alfie.sprite in
  let h = ch /. 6. in
  let aw, ah = Sprite.size_of sprite in
  let a = aw /. ah in
  let w = a *. h in
  let x = 30. in
  let y = ch -. h -. alfie.position in
  Sprite.render_full ctx sprite x y w h

let update (alfie: t) =
  let cnt = (alfie.cnt + 1) mod 1000 in
  let sprite =
    if not (is_on_the_ground alfie) then Sprite.update_idx 1 alfie.sprite
    else if cnt mod 8 = 0 then Sprite.update_idx ((alfie.sprite.idx + 1) mod 1) alfie.sprite
    else alfie.sprite
  in
  let velocity = if alfie.position > 0. then alfie.velocity -. 5. else alfie.velocity in
  let position = Float.max (alfie.position +. velocity) 0. in
  {alfie with cnt; sprite; velocity; position}

*)