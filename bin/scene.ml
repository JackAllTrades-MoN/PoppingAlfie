open Js_of_ocaml

type scene_name =
  | Title
  | Popping
  | GameOver

module type SceneType = sig
  val render : (string, Sprite.t) Hashtbl.t -> unit
  val update : unit -> unit
  val on_touch_start: Dom_html.touchEvent Js.t -> unit
  val on_touch_end: Dom_html.touchEvent Js.t -> unit
end

let next_scene = ref (Some Title)

let start_scene name = next_scene := Some name
