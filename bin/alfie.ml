
type t = {
  jump_level: int;
  velocity: float;
  position: float;
  sprite: Sprite.t;
  cnt: int;
}

let maximum_level = 6

let create sprite = {
  jump_level=0;
  velocity=0.;
  position=0.;
  sprite=sprite;
  cnt=0;
}

let is_on_the_ground (alfie: t) = alfie.position = 0.
let accelerate (alfie: t) = {alfie with velocity = alfie.velocity +. 15.}

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

