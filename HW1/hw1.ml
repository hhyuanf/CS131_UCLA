type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

open List;;
let rec subset a b =
match a with
[] -> true
| first :: rest -> (mem first b) && (subset rest b);;

let rec proper_subset a b =
if (subset a b) && (subset b a) then false
else subset a b;;

let rec equal_sets a b =
if (subset a b) && (subset b a) then true
else false;;

let rec set_diff a b =
match a with
[] -> a
| first :: rest -> if (not (mem first b)) then first :: (set_diff rest b) else set_diff rest b;;

let rec computed_fixed_point eq f x = 
if eq (f x) x then x
else computed_fixed_point eq f (f x);;

let compose f g x = f (g x);;

let rec power f n = 
if n=1 then f
else compose f (power f (n-1));;

let rec computed_periodic_point eq f p x =
if p = 0 then x
else if eq (power f p x) x then x 
else computed_periodic_point eq f p (f x);;

let eql a b c = equal_sets a c;;

let rec fixed_point eq f x y = 
if eql (f x y) x y then y else fixed_point eq f x (f x y);;

let check_terminals_symbol first terminals= 
match first with 
T s -> true
| N s -> mem s terminals;;

let rec check_terminals_rule rhs terminals = 
match rhs with
[] -> true
| first::rest -> if check_terminals_symbol first terminals then check_terminals_rule rest terminals
else false;;

let rec set_order a b =
match a with
[] -> []
| s::t-> match s with
_,p -> if check_terminals_rule p b then [s]@set_order t b 
else set_order t b;;

let rec filter b terminals =
match b with
[] -> terminals
| (lhs,rhs)::t-> if check_terminals_rule rhs terminals then 
if mem lhs terminals then filter t terminals 
else filter t (lhs::terminals)
else filter t terminals;;

let filter_blind_alleys g =
match g with
| (a, b) -> (a, set_order b (fixed_point eql filter b []));;
