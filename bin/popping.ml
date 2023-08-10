open Js_of_ocaml
open Scene

module Make(): SceneType = struct
  let _ = Js.Unsafe.js_expr "document.getElementById('bgm').play()"
  let score = ref 0
  let alfie = ref Alfie.init
  let bg = ref Background.init

  let update () =
    alfie := Alfie.update !alfie;
    bg := Background.update !bg

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
    render_score ()

  let on_touch_start _ =
    alfie := Alfie.start_jump !alfie
(*
  state := !state |> Option.map (fun state ->
      print_endline "touch_start";
      let alfie = Game.(state.alfie) in
      let alfie =
        if Alfie.is_on_the_ground alfie
        then Alfie.start_jump alfie
        else alfie
      in
      {state with alfie}
    );*)
  let on_touch_end _ =
    alfie := Alfie.stop_jump !alfie
    (*
    state := !state |> Option.map (fun state ->
      let alfie = Game.(state.alfie) |> Alfie.end_jump in
      {state with alfie}
    );
    Js._false *)
end