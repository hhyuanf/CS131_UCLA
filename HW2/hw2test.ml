type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num | Char

let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
	  [N Char; N Expr];
	  [N Term]]
     | Term ->
	 [[N Num; N Expr];
	  [N Num];
	  [N Incrop; N Lvalue];
	  [N Lvalue; N Incrop];
	  [N Char; N Lvalue];
	  [T"("; N Term; N Expr; T")"]]
     | Lvalue ->
	 [[T"$"; N Expr]]
     | Incrop ->
	 [[T"++"];
	  [T"--"]]
     | Binop ->
	 [[T"+"];
	  [T"-"]]
     | Char ->
	 [[T"A"]; [T"B"]; [T"C"]; [T"D"]; [T"E"]; 
	  [T"F"]; [T"E"]; [T"F"]; [T"G"]; [T"H"];
          [T"I"]; [T"J"]; [T"K"]; [T"L"]; [T"M"];
          [T"N"]; [T"O"]; [T"P"]; [T"Q"]; [T"R"];
	  [T"S"]; [T"T"]; [T"U"]; [T"V"]; [T"W"]]
     | Num ->
	 [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
	  [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])

let accept_all derivation string = Some (derivation, string)
let accept_empty_suffix derivation = function
   | [] -> Some (derivation, [])
   | _ -> None

let test0 =
  ((parse_prefix awkish_grammar accept_all ["CS131"]) = None)

let test1 =
  ((parse_prefix awkish_grammar accept_all ["C"; "S"; "1"; "3"; "1"]) 
  = Some
 ([(Expr, [N Char; N Expr]); (Char, [T "C"]); (Expr, [N Char; N Expr]);
   (Char, [T "S"]); (Expr, [N Term]); (Term, [N Num; N Expr]);
   (Num, [T "1"]); (Expr, [N Term]); (Term, [N Num; N Expr]); (Num, [T "3"]);
   (Expr, [N Term]); (Term, [N Num]); (Num, [T "1"])],
  []))

let test2 = 
  ((parse_prefix awkish_grammar accept_empty_suffix ["("; "C"; "$"; "+"; ")"])
   = None)

let test3 = 
  ((parse_prefix awkish_grammar accept_all ["("; "A"; "$"; "S"; "("; "4"; "9"; ")"; "$"; "0"; "-"; "D"; "$"; "("; "7"; "2"; ")"; "++"; "$"; "("; "6"; "B"; "7"; ")"; "--"; "6"; "-"; "5"; "6"; "("; "0"; "6"; ")"]) = None)

let test4 = 
  ((parse_prefix awkish_grammar accept_all ["("; "("; "A"; "$"; "D"; "3"; "9"; "+"; "C"; "$"; "7"; ")"; "("; "8"; "K"; "$"; "5"; ")"; ")"]) 
  = Some
 ([(Expr, [N Term]); (Term, [T "("; N Term; N Expr; T ")"]);
   (Term, [T "("; N Term; N Expr; T ")"]); (Term, [N Char; N Lvalue]);
   (Char, [T "A"]); (Lvalue, [T "$"; N Expr]); (Expr, [N Char; N Expr]);
   (Char, [T "D"]); (Expr, [N Term]); (Term, [N Num]); (Num, [T "3"]);
   (Expr, [N Term; N Binop; N Expr]); (Term, [N Num]); (Num, [T "9"]);
   (Binop, [T "+"]); (Expr, [N Term]); (Term, [N Char; N Lvalue]);
   (Char, [T "C"]); (Lvalue, [T "$"; N Expr]); (Expr, [N Term]);
   (Term, [N Num]); (Num, [T "7"]); (Expr, [N Term]);
   (Term, [T "("; N Term; N Expr; T ")"]); (Term, [N Num]); (Num, [T "8"]);
   (Expr, [N Term]); (Term, [N Char; N Lvalue]); (Char, [T "K"]);
   (Lvalue, [T "$"; N Expr]); (Expr, [N Term]); (Term, [N Num]);
   (Num, [T "5"])],
  []))
