open Js_of_ocaml

let display_system_message msg =
  let area = Dom_html.document##getElementById (Js.string "system-message") in
  match Js.Opt.to_option area with
    | None -> print_endline "Fatal error: div[id=system-message] is not found."
    | Some area -> area##.innerText := Js.string msg

let fail msg = display_system_message msg; assert false