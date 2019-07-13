type value = int

type avltree =
  | Empty
  | Node of value * avltree * avltree

let rec count p = function
    | Empty -> 0
    | Node(v, l, r) ->
      if p v then
        count p l + count p r + 1
      else
        count p l + count p r

(* generate next row from current row *)
let next_row row =
  List.map2 (+) ([0] @ row) (row @ [0])

(* returns the first n rows *)
let pascal n =
  let rec loop i row =
    if i = n then []
    else row :: loop (i+1) (next_row row)
  in loop 0 [1]
