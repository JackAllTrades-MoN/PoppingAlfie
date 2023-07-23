open Js_of_ocaml

type pos = float * float
type size = float * float

type t = {
  img: Dom_html.imageElement Js.t;
  frames: (pos * size) Array.t;
  idx: int;
}

let render ctx (sprite: t) x y =
  let (sx, sy), (sw, sh) = sprite.frames.(sprite.idx) in
  ctx##drawImage_full sprite.img sx sy sw sh x y sw sh

let render_full ctx (sprite: t) x y w h =
  let (sx, sy), (sw, sh) = sprite.frames.(sprite.idx) in
  ctx##drawImage_full sprite.img sx sy sw sh x y w h

let size_of (sprite: t) = sprite.frames.(sprite.idx) |> snd

let update_idx idx (sprite: t) = {sprite with idx = idx}
