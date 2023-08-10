
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
  alfie |> apply_jump |> apply_gravity

let start_jump (alfie: t) =
  match alfie.mode with
  | Default -> {alfie with mode = Rising 0}
  | _ -> alfie

let stop_jump (alfie: t) = match alfie.mode with
  | Rising _ -> {alfie with mode = Falling}
  | _ -> alfie
