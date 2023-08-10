open Js_of_ocaml

let sprites = Hashtbl.create 2

let get_scene =
  let scene: (module Scene.SceneType) option ref = ref None in
  fun () ->
    let open Scene in
    let next = !next_scene
    |> Option.map (function
    | Title -> (module Title.Make (): Scene.SceneType)
    | Popping -> (module Popping.Make ())
    | GameOver -> (module Gameover.Make ())) in
    if Option.is_some next then begin
      scene := next;
      next_scene := None
    end;
    Option.get !scene

let update () =
  let module M = (val get_scene (): Scene.SceneType) in
  M.update ()

let render () =
  let module M = (val get_scene (): Scene.SceneType) in
  let ctx = Global.context () in
  let cw, ch = Global.canvas_size in
  ctx##clearRect 0. 0. (float_of_int cw) (float_of_int ch);
  M.render sprites

let frame _ = update (); render ()

let start _ =
  let canvas = Global.canvas () in
  let w, h = Global.canvas_size in
  canvas##.width := w;
  canvas##.height := h;
  Dom_html.addEventListener canvas (Dom_html.Event.touchstart) (Dom_html.handler (fun e ->
    let module M = (val get_scene (): Scene.SceneType) in
    M.on_touch_start e;
    Js._false
  )) Js._false |> ignore;
  Dom_html.addEventListener canvas (Dom_html.Event.touchend) (Dom_html.handler (fun e ->
    let module M = (val get_scene (): Scene.SceneType) in
    M.on_touch_end e;
    Js._false
  )) Js._false |> ignore;
  Sprite.load "./img/bg.jpg" ~frames: [|((0., 0.), (1018., 600.))|] (fun background ->
  Sprite.load "./img/wcc.png" ~frames: [|((0., 0.), (436., 304.)); ((483., 0.), (583., 354.))|] (fun alfie ->
    Hashtbl.add sprites "alfie" alfie;
    Hashtbl.add sprites "background" background;
    ignore @@ Dom_html.window##setInterval (Js.wrap_callback frame) 15.
  ));
  Js._false

let () = Dom_html.window##.onload := Dom_html.handler start

(*
let update () =
  state := Option.map (fun state ->
    let alfie = Alfie.update Game.(state.alfie |> Alfie.jump_higher) in
    let background = Background.update Game.(state.background) in
    {state with alfie; background}
  ) !state

let render_score ctx state =
  let score = Game.(state.score) in
  ctx##.font := Js.string "48px serif";
  ctx##fillText (Js.string (Printf.sprintf "Score: %d" score)) 0. 0.

let render () =
  Option.iter (fun state ->
    let ctx = Global.context () in
    Background.render ctx Game.(state.background);
    Alfie.render ctx Game.(state.alfie);
    render_score ctx state
  ) !state

let frame _ = update (); render ()

let start _ =
  let canvas = Global.canvas () in
  let w, h = Global.canvas_size in
  canvas##.width := w;
  canvas##.height := h;
  Dom_html.addEventListener canvas (Dom_html.Event.touchstart) (Dom_html.handler (fun _ ->
    let _ = Js.Unsafe.js_expr "document.getElementById('bgm').play()" in
    state := !state |> Option.map (fun state ->
      print_endline "touch_start";
      let alfie = Game.(state.alfie) in
      let alfie =
        if Alfie.is_on_the_ground alfie
        then Alfie.start_jump alfie
        else alfie
      in
      {state with alfie}
    );
    Js._false
  )) Js._false |> ignore;
  Dom_html.addEventListener canvas (Dom_html.Event.touchend) (Dom_html.handler (fun _ ->
    state := !state |> Option.map (fun state ->
      let alfie = Game.(state.alfie) |> Alfie.end_jump in
      {state with alfie}
    );
    Js._false
  )) Js._false |> ignore;
  Sprite.load "./img/bg.jpg" ~frames: [|((0., 0.), (1018., 600.))|] (fun background ->
  Sprite.load "./img/wcc.png" ~frames: [|((0., 0.), (436., 304.)); ((483., 0.), (583., 354.))|] (fun alfie ->
    let sprites = Hashtbl.create 2 in
    Hashtbl.add sprites "alfie" alfie;
    Hashtbl.add sprites "background" background;
    state := Some (Game.init sprites);
    ignore @@ Dom_html.window##setInterval (Js.wrap_callback frame) 15.
  ));
  Js._false

let () = Dom_html.window##.onload := Dom_html.handler start

(*

let jump_strength = ref 0
let touch_margin = 2



let update () =
  Background.update ();
  if !jump_strength > 0 then begin
    if !jump_strength < touch_margin * maximum_level - 1 then jump_strength := !jump_strength + 1
    else release_jump ()
  end;
  alfie := Alfie.update !alfie

let render_score ctx =
  ctx##.font := Js.string "48px serif";
  ctx##fillText (Js.string (Printf.sprintf "Score: %d" !score)) 0. 0.

let render () =
  let ctx = Global.context () in
  let cw, ch = Global.canvas_size in
  ctx##clearRect 0. 0. (Float.of_int cw) (Float.of_int ch);
  Background.render ctx;
  Alfie.render !cw !ch !alfie ctx ();
  render_score ctx


let frame _ =
  update ();
  render ()

let start _ =
  let canvas = Global.canvas () in
  let w, h = Global.canvas_size in
  canvas##.width := w;
  canvas##.height := h;
  Sprite.load "background" "./img/bg.jpg" ~frames: [|((0., 0.), (1018., 600.))|] (fun _ ->
  Sprite.load
    "alfie"
    "./img/wcc.png"
    ~frames: [|((0., 0.), (436., 304.)); ((483., 0.), (583., 354.))|] (fun _ ->
    ignore @@ Dom_html.window##setInterval (Js.wrap_callback frame) 15.;
  ));
  Js._false
  (*Dirty.hide_address_bar ();*)
  match Dom_html.getElementById_coerce "canvas-main" Dom_html.CoerceTo.canvas with
    | None -> System.fail "Fatal error: Canvas did not exist."
    | Some canvas ->
      let cw = ref canvas##.clientWidth in
      let ch = ref canvas##.clientHeight in
      let update_canvas_size () =
        cw := canvas##.clientWidth;
        ch := canvas##.clientHeight;
        canvas##.width := !cw;
        canvas##.height := !ch;
      in
      print_endline (Printf.sprintf "css size: %d, %d" !cw !ch);
      let ctx = canvas##getContext Dom_html._2d_ in
      load "./img/wcc.png" (fun wcc ->
      load "./img/bg.jpg" (fun bg ->
        let alfie = ref (Alfie.create Sprite.{
          img=wcc;
          frames=[|
            ((0., 0.), (436., 304.)); (* Running-A *)
            ((483., 0.), (583., 354.)); (* Running-B *)
          |];
          idx=0
        }) in
        let bg_sprite = Sprite.{
          img=bg;
          frames=[|((0., 0.), (1018., 600.))|];
          idx=0;
        } in
        scene := [(0., 0., bg_sprite); (Float.of_int !cw, 0., bg_sprite)];
        let render () =
          ctx##clearRect 0. 0. (Float.of_int !cw) (Float.of_int !ch);
          List.iter (fun (x, y, sprite) -> Sprite.render_full ctx sprite x y (Float.of_int !cw) (Float.of_int !ch)) !scene;
          Alfie.render !cw !ch !alfie ctx ();
          ctx##.font := Js.string "48px serif";
          ctx##fillText (Js.string (Printf.sprintf "Score: %d" !score)) 20. 20.
        in
        let jump_strength = ref 0 in
        let touch_margin = 2 in
        let maximum_level = 6 in
        let release_jump () =
          alfie := Alfie.stop !alfie;
          for _ = 0 to !jump_strength / touch_margin do
            alfie := Alfie.accelerate !alfie
          done;
          jump_strength := 0
        in
        let update () =
          if !jump_strength > 0 then begin
            if !jump_strength < touch_margin * maximum_level - 1 then jump_strength := !jump_strength + 1
            else release_jump ()
          end;
          scene := List.map (fun (x, y, sprite) -> (x -. 1., y, sprite)) !scene;
          scene := List.filter (fun (x, _, _) -> x >= (Float.of_int (-(!cw)))) !scene;
          if List.length !scene <= 1 then scene := !scene @ [(Float.of_int !cw, 0., bg_sprite)];
          alfie := Alfie.update !alfie
        in
        let frame () = begin
          update_canvas_size ();
          update ();
          render ()
        end in
        Dom_html.addEventListener canvas (Dom_html.Event.touchstart) (Dom_html.handler (fun _ ->
          print_endline "touch_start";
          if Alfie.is_on_the_ground !alfie then jump_strength := 1;
          Js._false
        )) Js._false |> ignore;
        Dom_html.addEventListener canvas (Dom_html.Event.touchend) (Dom_html.handler (fun _ ->
          if !jump_strength > 0 then
            begin
              print_endline @@ Printf.sprintf "touch_end: Jump level=%d" (!jump_strength / touch_margin);
              release_jump ()
            end;
          Js._false
        )) Js._false |> ignore;
        Dom_html.window##setInterval (Js.wrap_callback frame) 15. |> ignore
      ));
      Js._false

let () = Dom_html.window##.onload := Dom_html.handler start

*)*)