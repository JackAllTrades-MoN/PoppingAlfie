open Js_of_ocaml

let canvas () =
  try
    Option.get @@
      Dom_html.getElementById_coerce "canvas-main" Dom_html.CoerceTo.canvas
  with Invalid_argument _ ->
    failwith @@ Printf.sprintf "Fatal error: canvas[id='canvas-main'] did not exist"

let context =
  let _ctx = ref None in
  let inner () =
    if Option.is_none !_ctx then _ctx := Some ((canvas ())##getContext Dom_html._2d_);
    Option.get !_ctx
  in inner

let canvas_size = (800, 600)

let final_score = ref 0
