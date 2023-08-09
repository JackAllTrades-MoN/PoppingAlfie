
type t = {
  score: int;
  alfie: Alfie.t;
  background: Background.t;
}

let init sprites =
  let alfie = Alfie.create (Hashtbl.find sprites "alfie") in
  let background = Background.create (Hashtbl.find sprites "background") in
  { score=0; alfie; background }

