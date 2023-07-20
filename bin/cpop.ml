open Js_of_ocaml

let cy = ref 0.
let cv = ref 0.
let scene = ref []

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
  match Dom_html.getElementById_coerce "canvas-main" Dom_html.CoerceTo.canvas with
    | None -> fail "Fatal error: Canvas did not exist."
    | Some canvas ->
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
        scene := [(0., 0., bg_sprite); (1018., 0., bg_sprite)];
        let render () =
          ctx##clearRect 0. 0. 800. 600.;
          List.iter (fun (x, y, sprite) -> Sprite.render ctx sprite x y) !scene;
          Sprite.render_full ctx chin 30. (520. -. !cy) 50. 50.
        in
        let update () =
          scene := List.map (fun (x, y, sprite) -> (x -. 1., y, sprite)) !scene;
          scene := List.filter (fun (x, _, _) -> x >= -1018.) !scene;
          if List.length !scene <= 1 then scene := !scene @ [(1018., 0., bg_sprite)];
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

      (*
let init _ =
  let canvas = Dom_html.getElementById_coerce "canvas-main" Dom_html.CoerceTo.canvas in
  match canvas with
    | None -> display_system_message "Fatal error: Canvas did not exist."
    | Some canvas ->
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
        scene := [(0., 0., bg_sprite); (1018., 0., bg_sprite)];
        let render () =
          ctx##clearRect 0. 0. 800. 600.;
          List.iter (fun (x, y, sprite) -> Sprite.render ctx sprite x y) !scene;
          if !cy > 0. then cy := !cy -. 1.;
          Sprite.render_full ctx chin 30. (520. -. !cy) 50. 50.
        in
        let register_event () =
          Dom_html.addEventListener canvas (Dom_html.Event.touchend) (Dom_html.handler (fun _ ->
            print_endline "touched";
            if !cy <= 0. then cy := !cy +. 10.;
            Js._false
          )) Js._false |> ignore;
          Dom_html.document##.onkeydown := Dom_html.handler (fun e ->
            match e##.keyCode with
              | 39 ->
                scene := List.map (fun (x, y, sprite) -> (x -. 1., y, sprite)) !scene;
                scene := List.filter (fun (x, _, _) -> x >= -1018.) !scene;
                if List.length !scene <= 1 then scene := !scene @ [(1018., 0., bg_sprite)];
                render();
                Js._false
              | _ -> Js._false
          )
        in
        render ();
        register_event ();
        Js._false
      );Js._false)

let init x = init x; Js._false

let () = Dom_html.window##.onload := Dom_html.handler init
*)