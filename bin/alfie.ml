
type t = {
  score: int;
  velocity: float;
  position: float;
  sprite: Sprite.t;
  cnt: int;
}

let create sprite = {
  score=0;
  velocity=0.;
  position=0.;
  sprite=sprite;
  cnt=0;
}

let is_on_the_ground (alfie: t) = alfie.position = 0.
let accelerate (alfie: t) = {alfie with velocity = alfie.velocity +. 15.}
let stop (alfie: t) = {alfie with velocity = 0.}

let render _canvas_width canvas_height (alfie: t) ctx () =
  let ch = Float.of_int canvas_height in
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

