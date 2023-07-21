open Js_of_ocaml

let cy = ref 0.
let cv = ref 0.
let scene = ref []
let score = ref 0

let display_system_message msg =
  let area = Dom_html.document##getElementById (Js.string "system-message") in
  match Js.Opt.to_option area with
    | None -> print_endline "Fatal error: div[id=system-message] is not found."
    | Some area -> area##.innerText := Js.string msg

let fail msg = display_system_message msg; assert false

let load name k =
  let img = Dom_html.createImg Dom_html.document in
  img##.src := Js.string name;
  img##.onload := Dom_html.handler (fun _ -> k img; Js._false)

let start _ =
  (*Dirty.hide_address_bar ();*)
  match Dom_html.getElementById_coerce "canvas-main" Dom_html.CoerceTo.canvas with
    | None -> fail "Fatal error: Canvas did not exist."
    | Some canvas ->
      let cw = canvas##.clientWidth in
      let ch = canvas##.clientHeight in
      print_endline (Printf.sprintf "css size: %d, %d" cw ch);
      canvas##.width := cw;
      canvas##.height := ch;
      let ctx = canvas##getContext Dom_html._2d_ in
      load "./img/wcc.png" (fun wcc ->
      load "./img/bg.jpg" (fun bg ->
        let bg_sprite = Sprite.{
          img=bg;
          frames=[|((0., 0.), (1018., 600.))|];
          idx=0;
        } in
        let chin = Sprite.{
          img=wcc;
          frames=[|((0., 0.), (436., 304.))|];
          idx=0
        } in
        scene := [(0., 0., bg_sprite); (Float.of_int cw, 0., bg_sprite)];
        let render () =
          let render_alfie () =
            let scale = 100. in
            let aw, ah = Sprite.size_of chin in
            let a = ah /. aw in
            let w = scale in
            let h = a *. w in
            let x = 30. in
            let y = (Float.of_int ch) -. h -. !cy in
            Sprite.render_full ctx chin x y w h;
          in
          ctx##clearRect 0. 0. (Float.of_int cw) (Float.of_int ch);
          List.iter (fun (x, y, sprite) -> Sprite.render_full ctx sprite x y (Float.of_int cw) (Float.of_int ch)) !scene;
          render_alfie ();
          ctx##.font := Js.string "48px serif";
          ctx##fillText (Js.string (Printf.sprintf "Score: %d" !score)) 20. 20.
        in
        let update () =
          scene := List.map (fun (x, y, sprite) -> (x -. 1., y, sprite)) !scene;
          scene := List.filter (fun (x, _, _) -> x >= (Float.of_int (-cw))) !scene;
          if List.length !scene <= 1 then scene := !scene @ [(Float.of_int cw, 0., bg_sprite)];
          if !cy > 0. then cv := !cv -. 5.;
          cy := Float.max (!cy +. !cv) 0.;
        in
        let frame () = begin
          update ();
          render ()
        end in
        Dom_html.addEventListener canvas (Dom_html.Event.touchend) (Dom_html.handler (fun _ ->
          print_endline @@ Printf.sprintf "v: %f, y: %f" !cv !cy;
          if !cy = 0. then cv := 40.;
          Js._false
        )) Js._false |> ignore;
        Dom_html.window##setInterval (Js.wrap_callback frame) 100. |> ignore
      ));
      Js._false

let () = Dom_html.window##.onload := Dom_html.handler start
