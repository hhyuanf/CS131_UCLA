let subset_test0 = subset [] []
let subset_test1 = not (subset [1;1;3] [1;2])
let subset_test2 = subset [2;3;5;7] [1;2;3;4;5;7;6;0]

let proper_subset_test0 = not (proper_subset [] [])
let proper_subset_test1 = proper_subset [1;2] [1;1;2;3;3]

let equal_sets_test0 = equal_sets [] []
let equal_sets_test1 = not (equal_sets [1;2;3] [1;2;3;4])

let set_diff_test0 = equal_sets (set_diff [] [1;2;3]) []
let set_diff_test1 = equal_sets (set_diff [1;2;3;4] [1;3;5]) [2;4]
let set_diff_test2 = not (equal_sets (set_diff [1;2;3;4] []) [2;9])
let set_diff_test3 = not (proper_subset (set_diff [1;2;3] [2]) [1;3])

let computed_fixed_point_test0 = 
  computed_fixed_point (=) (fun x -> x *. 3.) 0. = 0.
let computed_fixed_point_test1 = 
  computed_fixed_point (=) (fun x -> x *. x) 2. = infinity
let computed_fixed_point_test2 =
  ((computed_fixed_point (fun x y -> (x +. y) < 1.) (fun x -> x /. 5.) 5.) = 0.2)

let computed_periodic_point_test0 =
  computed_periodic_point (=) (fun x -> x *. x -. 2. *. x +. 1.) 2 1. = 1.
let computed_periodic_point_test1 =
  computed_periodic_point (=) sqrt 0 10. = 10.

type awksub_nonterminals =
  | Crystalys | Scroll | DivineRapler | Yasha | Dagon

let awksub_rules = 
[Scroll, [T "$"];
 Dagon, [N Dagon; N Scroll];
 Dagon, [N Scroll; T "NullTalisman"; T "StaffofWizardry"];
 Crystalys, [T "Blades of Attack"; N Scroll; T "Broadsword"];
 DivineRapler, [T "Demon Edge"; T "Sacred Relic"];
 Yasha, [T "BandofElvenskin"; T "BladeofAlacrity"; N Scroll]]

let awksub_grammar = Dagon, awksub_rules

let awksub_test0 =
 filter_blind_alleys awksub_grammar = awksub_grammar
let awksub_test1 =
 filter_blind_alleys (Dagon, tl awksub_rules) = (Dagon, [(DivineRapler, [T "Demon Edge"; T "Sacred Relic"])])
