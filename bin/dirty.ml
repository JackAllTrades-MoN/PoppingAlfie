open Js_of_ocaml

let hide_address_bar () =
  Dom_html.window##setTimeout (Js.wrap_callback (fun () ->
    let e =
      Dom_html.document##getElementsByTagName (Js.string "body")
      |> Dom.list_of_nodeList
      |> fun ls -> List.nth ls 0 in
    e##.style##.minHeight := Js.string "2000px";
    Dom_html.window##setTimeout (Js.wrap_callback (fun () ->
      Dom_html.window##scroll 0 1;
      Dom_html.window##setTimeout (Js.wrap_callback (fun () ->
        let i = Dom_html.window##.innerHeight in
        e##.style##.minHeight := Js.string (Printf.sprintf "%dpx" i);
      )) 500. |> ignore
    )) 500. |> ignore
  )) 500. |> ignore
