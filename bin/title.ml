open Js_of_ocaml
open Scene

module Make (): SceneType = struct
  let update () = ()

  let render_at_center (ctx: Dom_html.canvasRenderingContext2D Js.t) text x y =
    ctx##save;
    ctx##.textBaseline := Js.string "top";
    ctx##.textAlign := Js.string "center";
    ctx##fillText (Js.string text) x y;
    ctx##restore

  let render_background sprites =
    let cw, ch = Global.canvas_size in
    let cw, ch = float_of_int cw, float_of_int ch in
    let background = Hashtbl.find sprites "background" in
    Sprite.render_full background 0. 0. cw ch

  let render sprites =
    let cw, ch = Global.canvas_size in
    let cw, ch = float_of_int cw, float_of_int ch in
    let ctx = Global.context () in
    render_background sprites;
    ctx##.fillStyle := Js.string "rgb(0, 0, 0)";
    ctx##.font := Js.string "80px 'Mochiy Pop One', sans-serif";
    render_at_center ctx "Popping Alfie" (cw /. 2.) (ch /. 2. -. 100.);
    ctx##.font := Js.string "30px 'Mochiy Pop One', sans-serif";
    render_at_center ctx "touch to start" (cw /. 2.) (ch /. 2.)

  let on_touch_start _ = ()

  let on_touch_end _ = start_scene Popping

end