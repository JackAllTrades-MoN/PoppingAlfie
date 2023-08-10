open Js_of_ocaml

type t = {
  x: float;
  y: float;
  w: float;
  h: float;
}

let create x y = {x; y; w=100.; h=10.}

let render _sprite (t: t) =
  let ctx = Global.context () in
  let cw, ch = Global.canvas_size in
  let _, ch = float_of_int cw, float_of_int ch in
  ctx##save;
  ctx##.fillStyle := Js.string "brown";
  ctx##fillRect t.x (ch -. t.y -. t.h) t.w t.h;
  ctx##restore

let update (t: t) = {t with x = t.x -. 1.}

let is_staled (t: t) = t.x +. t.w < 0.