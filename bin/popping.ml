open Js_of_ocaml
open Scene

module Make(): SceneType = struct
  let _ = Js.Unsafe.js_expr "document.getElementById('bgm').play()"
  let score = ref 0
  let alfie = ref Alfie.init
  let bg = ref Background.init
  let floors = ref [Floor.create 800. 150.; Floor.create 900. 250.; Floor.create 1000. 400.]

  let update () =
    alfie := Alfie.update !alfie;
    bg := Background.update !bg;
    floors := List.filter (fun floor -> not Floor.(is_staled floor)) !floors;
    floors := List.map (fun floor -> Floor.update floor) !floors

  let render_score () =
    let ctx = Global.context () in
    ctx##save;
    ctx##.textBaseline := Js.string "top";
    ctx##.fillStyle := Js.string "rgb(0, 0, 0)";
    ctx##.font := Js.string "30px 'Mochiy Pop One', sans-serif";
    ctx##fillText (Js.string (Printf.sprintf "Score: %d" !score)) 0. 0.;
    ctx##restore

  let render sprites =
    Background.render sprites !bg;
    Alfie.render sprites !alfie;
    List.iter (fun floor -> Floor.render sprites floor) !floors;
    render_score ()

  let on_touch_start _ =
    alfie := Alfie.start_jump !alfie

  let on_touch_end _ =
    alfie := Alfie.stop_jump !alfie

end