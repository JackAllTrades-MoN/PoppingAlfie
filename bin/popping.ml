open Js_of_ocaml
open Scene

module Make(): SceneType = struct
  let _ = Js.Unsafe.js_expr "document.getElementById('bgm').play()"
  let cnt = ref 0
  let sec = ref 0
  let already_spawn = ref false
  let score = ref 0
  let alfie = ref Alfie.init
  let bg = ref Background.init
  let floors = ref []

  let update_floors () =
    floors := List.filter (fun floor -> not Floor.(is_staled floor)) !floors;
    floors := List.map (fun floor -> Floor.update floor) !floors;
    if !sec mod 3 = 0 && not !already_spawn then begin
      floors := (Floor.gen ())::!floors;
      already_spawn := true
    end else if !sec mod 3 <> 0 then already_spawn := false

  let update_counter () =
    cnt := (!cnt + 1) mod Int.max_int;
    if !cnt mod 60 = 0 then sec := (!sec + 1) mod Int.max_int

  let update () =
    update_counter ();
    alfie := Alfie.update !alfie;
    bg := Background.update !bg;
    let ax, ay = Alfie.feet_at !alfie in
    if List.exists (fun floor -> Floor.is_hit ax ay floor) !floors
    then print_endline "hit";
    update_floors ()

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