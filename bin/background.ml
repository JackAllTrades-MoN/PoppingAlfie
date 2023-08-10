
type t = {
  positions: (float * float) list
}

let init = {positions=[(0., 0.)]}

let render sprites (bg: t) =
  let sprite = Hashtbl.find sprites "background" in
  List.iter (fun (x, y) ->
    Sprite.render sprite x y
  ) bg.positions

let update (t: t) =
  let w, _ = Global.canvas_size in
  let positions =
    t.positions
    |> List.map (fun (x, y) -> (x -. 1., y))
    |> List.filter (fun (x, _) -> Int.of_float x > -w)
  in
  let positions =
    if List.length positions <= 1
    then positions @ [(Float.of_int w, 0.)]
    else positions
  in
  {positions}

(*
type t = {
  sprites: Sprite.t;
  positions: (float * float) list
}

let create sprites = {sprites; positions=[(0., 0.)]}

let render (ctx: Dom_html.canvasRenderingContext2D Js.t) t =
  List.iter (fun (x, y) ->
    Sprite.render ctx t.sprites x y
  ) t.positions

let update t =
  let w, _ = Global.canvas_size in
  let positions =
    t.positions
    |> List.map (fun (x, y) -> (x -. 1., y))
    |> List.filter (fun (x, _) -> Int.of_float x > -w)
  in
  let positions =
    if List.length positions <= 1
    then positions @ [(Float.of_int w, 0.)]
    else positions
  in
  {t with positions}
*)